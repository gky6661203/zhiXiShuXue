<template>
  <div class="assignment-detail">
    <div class="page-header">
      <h2>{{ viewMode ? '答题结果' : '在线答题' }}</h2>
      <p>{{ assignmentTitle }}</p>
    </div>
    
    <el-card class="gradient-card" v-loading="loading">
      <template #header>
        <div class="card-header">
          <span>题目列表</span>
          <div v-if="!viewMode">
            <el-button type="primary" @click="submitAnswers" :loading="submitting">
              提交答案
            </el-button>
          </div>
        </div>
      </template>
      
      <div v-for="(question, index) in questions" :key="question.id" class="question-item">
        <div class="question-header">
          <span class="question-number">第{{ index + 1 }}题</span>
          <el-tag>{{ getTypeText(question.type) }}</el-tag>
          <el-tag type="info">{{ question.score }}分</el-tag>
        </div>
        
        <div class="question-content">{{ question.content }}</div>
        
        <!-- 选择题 -->
        <div v-if="question.type === 'choice'" class="question-options">
          <el-radio-group v-model="answers[question.id]" :disabled="viewMode">
            <el-radio
              v-for="(opt, optIndex) in question.options"
              :key="optIndex"
              :label="String.fromCharCode(65 + optIndex)"
              class="option-item"
            >
              {{ String.fromCharCode(65 + optIndex) }}. {{ opt }}
            </el-radio>
          </el-radio-group>
        </div>
        
        <!-- 填空题 -->
        <div v-else-if="question.type === 'fill'" class="question-fill">
          <el-input
            v-model="answers[question.id]"
            placeholder="请输入答案"
            :disabled="viewMode"
          />
        </div>
        
        <!-- 简答题 -->
        <div v-else class="question-short">
          <el-input
            v-model="answers[question.id]"
            type="textarea"
            :rows="4"
            placeholder="请输入答案"
            :disabled="viewMode"
          />
        </div>
        
        <!-- 答题结果 -->
        <div v-if="viewMode && hasResult(question.id)" class="answer-result">
          <div :class="['result-item', getResultCorrect(question.id) ? 'correct' : 'wrong']">
            <span>你的答案：{{ getAnswer(question.id) }}</span>
            <el-icon v-if="getResultCorrect(question.id)"><Check /></el-icon>
            <el-icon v-else><Close /></el-icon>
          </div>
          <div class="correct-answer" v-if="!getResultCorrect(question.id)">
            正确答案：{{ getCorrectAnswer(question.id) }}
          </div>
          <div class="score">得分：{{ getScore(question.id) }}分</div>
        </div>
      </div>
      
      <el-empty v-if="questions.length === 0 && !loading" description="暂无题目" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import api from '@/utils/api'

var route = useRoute()
var router = useRouter()
var loading = ref(false)
var submitting = ref(false)

var assignment = ref(null)
var questions = ref([])
var answers = reactive({})
var results = reactive({})

var viewMode = computed(function() {
  return route.query.view === 'result'
})

var assignmentTitle = computed(function() {
  if (!assignment.value || !assignment.value.title) {
    return '加载中...'
  }
  return assignment.value.title
})

function hasResult(questionId) {
  return results[questionId] !== undefined
}

function getResultCorrect(questionId) {
  var result = results[questionId]
  return result ? result.correct : false
}

function getAnswer(questionId) {
  var answer = answers[questionId]
  return answer || '未作答'
}

function getCorrectAnswer(questionId) {
  var result = results[questionId]
  return result ? result.correctAnswer : ''
}

function getScore(questionId) {
  var result = results[questionId]
  return result ? result.score : 0
}

onMounted(function() {
  loadAssignment()
})

function loadAssignment() {
  var assignmentId = route.params.id
  if (!assignmentId) return
  
  loading.value = true
  
  api.get('/student/assignments/' + assignmentId + '/questions').then(function(res) {
    if (res.success) {
      assignment.value = res.data.assignment
      questions.value = res.data.questions
      
      // 如果是查看结果模式，加载答题结果
      if (viewMode.value) {
        loadResults()
      }
    }
  }).catch(function(error) {
    ElMessage.error('加载作业失败')
  }).finally(function() {
    loading.value = false
  })
}

function loadResults() {
  // 这里应该从后端加载答题结果
  // 暂时模拟
}

function submitAnswers() {
  var answeredCount = 0
  var answerKeys = Object.keys(answers)
  for (var i = 0; i < answerKeys.length; i++) {
    if (answers[answerKeys[i]]) {
      answeredCount++
    }
  }
  
  if (answeredCount === 0) {
    ElMessage.warning('请至少回答一道题目')
    return
  }
  
  ElMessageBox.confirm('确定提交答案吗？已答' + answeredCount + '/' + questions.value.length + '题', '提示').then(function() {
    submitting.value = true
    
    api.post('/student/assignments/' + route.params.id + '/submit', {
      answers: answers
    }).then(function(res) {
      if (res.success) {
        ElMessage.success('提交成功')
        // 显示结果
        var questionResults = res.data.questionResults || []
        for (var i = 0; i < questionResults.length; i++) {
          var r = questionResults[i]
          results[r.questionId] = r
        }
        
        // 跳转到结果页
        router.replace('/student/assignment/' + route.params.id + '?view=result')
      }
    }).catch(function(error) {
      ElMessage.error('提交失败')
    }).finally(function() {
      submitting.value = false
    })
  }).catch(function() {
    // 取消
  })
}

function getTypeText(type) {
  var map = { choice: '选择题', fill: '填空题', shortAnswer: '简答题' }
  return map[type] || '未知'
}
</script>

<style scoped>
.question-item {
  margin-bottom: 24px;
  padding: 20px;
  background: #f5f7fa;
  border-radius: 8px;
}

.question-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.question-number {
  font-size: 16px;
  font-weight: bold;
}

.question-content {
  margin-bottom: 16px;
  line-height: 1.6;
}

.question-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.option-item {
  display: flex;
  padding: 12px;
  background: white;
  border-radius: 4px;
}

.answer-result {
  margin-top: 16px;
  padding: 16px;
  background: white;
  border-radius: 8px;
}

.result-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px;
  border-radius: 4px;
}

.result-item.correct {
  background: #f0f9ff;
  color: #67C23A;
}

.result-item.wrong {
  background: #fef0f0;
  color: #F56C6C;
}

.correct-answer {
  margin-top: 8px;
  color: #67C23A;
}

.score {
  margin-top: 8px;
  font-weight: bold;
}
</style>
