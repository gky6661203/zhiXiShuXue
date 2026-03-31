<template>
  <div class="student-analytics">
    <div class="page-header">
      <h2>学生学情分析</h2>
      <p>查看学生个人学习情况</p>
    </div>
    
    <el-card class="gradient-card">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <span>学生列表</span>
            <el-select v-model="selectedClassId" placeholder="选择班级" @change="loadStudents" style="width: 200px; margin-left: 20px">
              <el-option v-for="c in classes" :key="c.id" :label="c.name" :value="c.id" />
            </el-select>
          </div>
          <el-input
            v-model="searchQuery"
            placeholder="搜索学生姓名或学号"
            prefix-icon="Search"
            style="width: 300px"
          />
        </div>
      </template>
      
      <el-table :data="filteredStudents" style="width: 100%">
        <el-table-column prop="studentNo" label="学号" width="120" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="gender" label="性别" width="80">
          <template #default="scope">
            {{ scope.row.gender === 'male' ? '男' : '女' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button type="primary" link @click="viewStudentAnalytics(scope.row)">
              学情分析
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <el-card v-if="studentId" class="gradient-card" v-loading="loading" style="margin-top: 20px;">
      <template #header>
        <span>学生信息</span>
      </template>
      
      <el-descriptions :column="3" border v-if="studentInfo">
        <el-descriptions-item label="姓名">{{ studentInfo.name }}</el-descriptions-item>
        <el-descriptions-item label="学号">{{ studentInfo.studentNo }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ studentInfo.gender === 'male' ? '男' : '女' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>
    
    <el-row v-if="studentId" :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card class="gradient-card">
          <template #header>成绩趋势</template>
          <div id="scoreChart" style="height: 300px;"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card class="gradient-card">
          <template #header>知识点掌握</template>
          <div id="knowledgeChart" style="height: 300px;"></div>
        </el-card>
      </el-col>
    </el-row>
    
    <el-card v-if="studentId" class="gradient-card" style="margin-top: 20px;">
      <template #header>错题列表</template>
      <el-table :data="wrongQuestions" max-height="400">
        <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
        <el-table-column prop="correctAnswer" label="正确答案" width="120" />
        <el-table-column prop="studentAnswer" label="学生答案" width="120" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/utils/api'
import * as echarts from 'echarts'

var route = useRoute()
var router = useRouter()
var loading = ref(false)
var studentInfo = ref(null)
var analytics = ref(null)
var scoreChart = null
var knowledgeChart = null

// 学生列表相关
var students = ref([])
var searchQuery = ref('')
var classes = ref([])
var selectedClassId = ref('')

var studentId = computed(function() {
  return route.params.id
})

var wrongQuestions = computed(function() {
  if (!analytics.value || !analytics.value.wrongQuestions) {
    return []
  }
  return analytics.value.wrongQuestions
})

// 过滤后的学生列表
var filteredStudents = computed(function() {
  if (!searchQuery.value) {
    return students.value
  }
  var query = searchQuery.value.toLowerCase()
  return students.value.filter(function(student) {
    return student.name.toLowerCase().includes(query) || student.studentNo.toLowerCase().includes(query)
  })
})

onMounted(function() {
  loadClasses()
  loadAnalytics()
})

// 监听学生ID变化
watch(studentId, function(newId) {
  if (newId) {
    loadAnalytics()
  }
})

function loadClasses() {
  api.get('/teacher/classes').then(function(res) {
    if (res.success) {
      classes.value = res.data
      if (res.data.length > 0) {
        selectedClassId.value = res.data[0].id
        loadStudents()
      }
    }
  }).catch(function(error) {
    console.error('加载班级失败:', error)
  })
}

function loadStudents() {
  if (!selectedClassId.value) return
  
  api.get('/teacher/classes/' + selectedClassId.value + '/students').then(function(res) {
    if (res.success) {
      students.value = res.data
    }
  }).catch(function(error) {
    console.error('加载学生失败:', error)
  })
}

function loadAnalytics() {
  if (!studentId.value) return
  
  loading.value = true
  
  api.get('/teacher/analytics/student/' + studentId.value).then(function(res) {
    if (res.success) {
      studentInfo.value = res.data.student
      analytics.value = res.data
      return nextTick()
    }
  }).then(function() {
    renderCharts()
  }).catch(function(error) {
    console.error('加载失败:', error)
  }).finally(function() {
    loading.value = false
  })
}

function renderCharts() {
  // 成绩趋势图
  var scoreDom = document.getElementById('scoreChart')
  if (scoreDom) {
    if (scoreChart) scoreChart.dispose()
    scoreChart = echarts.init(scoreDom)
    
    var trend = analytics.value && analytics.value.scoreTrend ? analytics.value.scoreTrend : []
    var xData = []
    var yData = []
    for (var i = 0; i < trend.length; i++) {
      var t = trend[i]
      xData.push(t.date ? t.date.slice(5, 10) : '')
      yData.push(t.score)
    }
    
    scoreChart.setOption({
      tooltip: { trigger: 'axis' },
      xAxis: { type: 'category', data: xData },
      yAxis: { type: 'value' },
      series: [{
        name: '得分',
        type: 'line',
        data: yData,
        smooth: true,
        lineStyle: { color: '#409EFF' },
        areaStyle: { color: 'rgba(64, 158, 255, 0.1)' }
      }]
    })
  }
  
  // 知识点掌握图
  var knowledgeDom = document.getElementById('knowledgeChart')
  if (knowledgeDom) {
    if (knowledgeChart) knowledgeChart.dispose()
    knowledgeChart = echarts.init(knowledgeDom)
    
    var mastery = analytics.value && analytics.value.knowledgePointMastery ? analytics.value.knowledgePointMastery : {}
    var keys = Object.keys(mastery).slice(0, 8)
    
    var pieData = []
    for (var i = 0; i < keys.length; i++) {
      var k = keys[i]
      pieData.push({
        name: k.slice(0, 8),
        value: parseFloat(mastery[k].avgScore)
      })
    }
    
    knowledgeChart.setOption({
      tooltip: { trigger: 'item' },
      series: [{
        name: '掌握情况',
        type: 'pie',
        radius: ['40%', '70%'],
        data: pieData
      }]
    })
  }
}

function viewStudentAnalytics(student) {
  router.push('/teacher/analytics/student/' + student.id)
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-left {
  display: flex;
  align-items: center;
}
</style>
