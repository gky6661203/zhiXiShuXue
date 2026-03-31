<template>
  <div class="class-analytics">
    <div class="page-header">
      <h2>班级学情分析</h2>
      <p>查看班级整体学习情况</p>
    </div>
    
    <el-row :gutter="20">
      <el-col :span="24">
        <el-card class="gradient-card">
          <template #header>
            <div class="card-header">
              <span>选择班级</span>
              <el-select v-model="selectedClassId" placeholder="选择班级" @change="loadAnalytics" style="width: 200px;">
                <el-option v-for="c in classes" :key="c.id" :label="c.name" :value="c.id" />
              </el-select>
            </div>
          </template>
          
          <el-row :gutter="20" v-if="analytics">
            <el-col :span="6">
              <div class="stat-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                <div class="stat-value">{{ analytics.avgScore || 0 }}</div>
                <div class="stat-label">平均分</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                <div class="stat-value">{{ analytics.studentCount || 0 }}</div>
                <div class="stat-label">学生人数</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                <div class="stat-value">{{ analytics.completedCount || 0 }}</div>
                <div class="stat-label">已完成作业</div>
              </div>
            </el-col>
            <el-col :span="6">
              <div class="stat-card" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);">
                <div class="stat-value">{{ avgScorePercent }}%</div>
                <div class="stat-label">平均正确率</div>
              </div>
            </el-col>
          </el-row>
        </el-card>
      </el-col>
    </el-row>
    
    <el-row :gutter="20" style="margin-top: 20px;">
      <el-col :span="12">
        <el-card class="gradient-card">
          <template #header>学生成绩排名</template>
          <el-table :data="studentScores" max-height="400">
            <el-table-column prop="studentName" label="学生" />
            <el-table-column prop="score" label="得分" width="100" />
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card class="gradient-card">
          <template #header>知识点掌握情况</template>
          <div id="knowledgeChart" style="height: 400px;"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import api from '@/utils/api'
import * as echarts from 'echarts'

var classes = ref([])
var selectedClassId = ref('')
var analytics = ref(null)
var chart = null

var studentScores = computed(function() {
  if (!analytics.value || !analytics.value.studentScores) {
    return []
  }
  return analytics.value.studentScores
})

var avgScorePercent = computed(function() {
  if (!analytics.value || !analytics.value.avgScore) {
    return 0
  }
  return Math.round(analytics.value.avgScore * 10) / 10
})

onMounted(function() {
  loadClasses()
})

function loadClasses() {
  api.get('/teacher/classes').then(function(res) {
    if (res.success) {
      classes.value = res.data
      if (res.data.length > 0) {
        selectedClassId.value = res.data[0].id
        loadAnalytics()
      }
    }
  }).catch(function(error) {
    console.error('加载班级失败:', error)
  })
}

function loadAnalytics() {
  if (!selectedClassId.value) return
  
  api.get('/teacher/analytics/class/' + selectedClassId.value).then(function(res) {
    if (res.success) {
      analytics.value = res.data
      return nextTick()
    }
  }).then(function() {
    renderChart()
  }).catch(function(error) {
    console.error('加载分析数据失败:', error)
  })
}

function renderChart() {
  var chartDom = document.getElementById('knowledgeChart')
  if (!chartDom) return
  
  if (chart) chart.dispose()
  chart = echarts.init(chartDom)
  
  var data = analytics.value && analytics.value.knowledgePointMastery ? analytics.value.knowledgePointMastery : {}
  var keys = Object.keys(data).slice(0, 10)
  
  var option = {
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', data: keys.map(function(k) { return k.slice(0, 6) + '...' }) },
    yAxis: { type: 'value', max: 100 },
    series: [{
      name: '掌握度',
      type: 'bar',
      data: keys.map(function(k) { return parseFloat(data[k]) }),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: '#83bff6' },
          { offset: 0.5, color: '#188df0' },
          { offset: 1, color: '#188df0' }
        ])
      }
    }]
  }
  
  chart.setOption(option)
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
