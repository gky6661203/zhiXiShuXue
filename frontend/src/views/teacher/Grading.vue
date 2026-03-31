<template>
  <div class="grading-center">
    <div class="page-header">
      <h2>批改中心</h2>
      <p>批改学生作业和试卷</p>
    </div>
    
    <el-card class="gradient-card">
      <template #header>
        <span>待批改列表</span>
      </template>
      
      <el-table :data="answers" style="width: 100%" v-loading="loading">
        <el-table-column prop="studentName" label="学生" width="120" />
        <el-table-column prop="assignmentTitle" label="作业名称" />
        <el-table-column prop="submittedAt" label="提交时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.submittedAt) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'graded' ? 'success' : 'warning'">
              {{ scope.row.status === 'graded' ? '已批改' : '待批改' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="totalScore" label="得分" width="100">
          <template #default="scope">
            {{ scope.row.totalScore !== undefined ? scope.row.totalScore : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="scope">
            <el-button type="primary" link @click="viewAnswer(scope.row)">查看</el-button>
            <el-button type="primary" link @click="gradeAnswer(scope.row)" v-if="scope.row.status !== 'graded'">
              批改
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 批改对话框 -->
    <el-dialog v-model="gradeDialogVisible" title="批改答题" width="800px">
      <div v-if="currentAnswer">
        <div v-for="(qr, index) in currentAnswer.questionResults" :key="index" style="margin-bottom: 20px; padding: 16px; background: #f5f7fa; border-radius: 8px;">
          <div style="margin-bottom: 12px;">
            <strong>第{{ index + 1 }}题</strong> ({{ qr.score }}分)
          </div>
          <div style="margin-bottom: 8px;">
            <span>学生答案：</span>{{ qr.answer }}
          </div>
          <div style="margin-bottom: 8px;">
            <span>正确答案：</span>{{ qr.correctAnswer }}
          </div>
          <el-input-number v-model="qr.score" :min="0" :max="10" label="得分" />
        </div>
      </div>
      <template #footer>
        <el-button @click="gradeDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitGrade">提交批改</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '@/utils/api'
import dayjs from 'dayjs'

var loading = ref(false)
var gradeDialogVisible = ref(false)
var answers = ref([])
var currentAnswer = ref(null)

onMounted(function() {
  loadAnswers()
})

function loadAnswers() {
  loading.value = true
  api.get('/teacher/answers')
    .then(function(res) {
      if (res.success) {
        var result = []
        for (var i = 0; i < res.data.length; i++) {
          var a = res.data[i]
          result.push({
            id: a.id,
            studentId: a.studentId,
            studentName: '学生' + a.studentId.slice(-3),
            assignmentTitle: a.assignmentTitle,
            submittedAt: a.submittedAt,
            status: a.status,
            totalScore: a.totalScore
          })
        }
        answers.value = result
      }
    })
    .catch(function(error) {
      console.error('加载失败:', error)
    })
    .finally(function() {
      loading.value = false
    })
}

function viewAnswer(row) {
  console.log('查看答题:', row)
}

function gradeAnswer(row) {
  api.get('/student/answers/' + row.id)
    .then(function(res) {
      if (res.success) {
        currentAnswer.value = res.data
        gradeDialogVisible.value = true
      }
    })
    .catch(function(error) {
      ElMessage.error('加载答题详情失败')
    })
}

function submitGrade() {
  var scores = {}
  var qrs = currentAnswer.value.questionResults
  for (var i = 0; i < qrs.length; i++) {
    scores[qrs[i].questionId] = qrs[i].score
  }
  
  api.post('/teacher/answers/' + currentAnswer.value.answer.id + '/grade', { scores: scores })
    .then(function(res) {
      if (res.success) {
        ElMessage.success('批改成功')
        gradeDialogVisible.value = false
        loadAnswers()
      }
    })
    .catch(function(error) {
      ElMessage.error('批改失败')
    })
}

function formatDate(date) {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}
</script>
