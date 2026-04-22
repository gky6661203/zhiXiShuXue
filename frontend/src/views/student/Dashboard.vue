<template>
  <div class="student-dashboard">
    <div class="page-header">
      <h2>学习中心</h2>
      <p>今天是 {{ currentDate }}，继续保持学习节奏。</p>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="6">
        <div class="stat-card stat-card-purple">
          <el-icon :size="32"><Document /></el-icon>
          <div class="stat-value">{{ stats.pendingAssignments }}</div>
          <div class="stat-label">待完成作业</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card stat-card-blue">
          <el-icon :size="32"><TrendCharts /></el-icon>
          <div class="stat-value">{{ stats.avgScore }}%</div>
          <div class="stat-label">平均掌握度</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card weak-card">
          <el-icon :size="32"><WarningFilled /></el-icon>
          <div class="stat-value">{{ weakBreakdown.weak }}</div>
          <div class="stat-label">薄弱知识点</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card mastered-card">
          <el-icon :size="32"><CircleCheck /></el-icon>
          <div class="stat-value">{{ weakBreakdown.mastered }}</div>
          <div class="stat-label">已掌握知识点</div>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="main-row">
      <el-col :span="16">
        <el-card class="gradient-card" v-loading="loadingAssignments">
          <template #header>
            <div class="card-header">
              <span>待完成作业</span>
              <el-button class="dashboard-primary-btn" type="primary" text @click="goToAssignments">
                查看全部
              </el-button>
            </div>
          </template>
          <el-table :data="pendingAssignments" style="width: 100%">
            <el-table-column prop="title" label="作业名称" />
            <el-table-column prop="paperTitle" label="试卷" width="150" />
            <el-table-column prop="questionCount" label="题目数" width="80" />
            <el-table-column prop="deadline" label="截止时间" width="180">
              <template #default="scope">
                {{ formatDate(scope.row.deadline) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="scope">
                <el-button class="dashboard-primary-btn" type="primary" size="small" @click="startAssignment(scope.row)">
                  开始答题
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!loadingAssignments && pendingAssignments.length === 0" description="暂无待完成作业" />
        </el-card>
      </el-col>

      <el-col :span="8">
        <el-card class="gradient-card" v-loading="loadingWeakPoints">
          <template #header>
            <div class="card-header">
              <span>知识点掌握概览</span>
              <el-tag type="danger">薄弱 {{ weakBreakdown.weak }}</el-tag>
            </div>
          </template>
          <div class="mastery-breakdown">
            <div class="mastery-item is-weak">
              <span class="mastery-name">薄弱</span>
              <strong>{{ weakBreakdown.weak }}</strong>
              <small>{{ weakBreakdown.weakRatio }}%</small>
            </div>
            <div class="mastery-item is-middle">
              <span class="mastery-name">待巩固</span>
              <strong>{{ weakBreakdown.learning }}</strong>
              <small>{{ weakBreakdown.learningRatio }}%</small>
            </div>
            <div class="mastery-item is-strong">
              <span class="mastery-name">已掌握</span>
              <strong>{{ weakBreakdown.mastered }}</strong>
              <small>{{ weakBreakdown.masteredRatio }}%</small>
            </div>
          </div>
          <div id="knowledgeChart" class="knowledge-chart"></div>
        </el-card>

        <el-card class="gradient-card quick-entry-card">
          <template #header>快捷入口</template>
          <div class="quick-actions-grid">
            <el-button class="quick-action-btn quick-action-primary dashboard-primary-btn" type="primary" @click="goToKnowledge">
              <span class="quick-action-title">知识树</span>
              <span class="quick-action-subtitle">查看知识结构</span>
            </el-button>
            <el-button class="quick-action-btn quick-action-warning" type="warning" @click="goToWeakPoints">
              <span class="quick-action-title">薄弱补练</span>
              <span class="quick-action-subtitle">进入专项提升</span>
            </el-button>
            <el-button class="quick-action-btn quick-action-danger" type="danger" @click="goToWrongQuestions">
              <span class="quick-action-title">错题本</span>
              <span class="quick-action-subtitle">进入重做模式</span>
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { CircleCheck, Document, TrendCharts, WarningFilled } from '@element-plus/icons-vue'
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/utils/api'
import * as echarts from 'echarts'
import dayjs from 'dayjs'
import { getMasteryStatus } from '@/utils/knowledge-meta'

const router = useRouter()
let chart = null
const loadingAssignments = ref(false)
const loadingWeakPoints = ref(false)
const pendingAssignments = ref([])
const weakPointList = ref([])

const currentDate = computed(() => dayjs().format('YYYY年MM月DD日 dddd'))

const stats = reactive({
  pendingAssignments: 0,
  avgScore: 0
})

const weakBreakdown = computed(() => {
  const result = { mastered: 0, learning: 0, weak: 0, masteredRatio: 0, learningRatio: 0, weakRatio: 0 }
  weakPointList.value.forEach((item) => {
    const label = item.statusLabel || (getMasteryStatus(item.masteryRate) === 'mastered' ? '已掌握' : getMasteryStatus(item.masteryRate) === 'learning' ? '待巩固' : '薄弱')
    if (label === '已掌握') result.mastered += 1
    else if (label === '待巩固') result.learning += 1
    else result.weak += 1
  })
  const total = weakPointList.value.length || 1
  result.masteredRatio = Math.round(result.mastered / total * 100)
  result.learningRatio = Math.round(result.learning / total * 100)
  result.weakRatio = Math.round(result.weak / total * 100)
  return result
})

function loadAssignments() {
  loadingAssignments.value = true
  api.get('/student/assignments', { status: 'pending' })
    .then((res) => {
      if (res.success) {
        pendingAssignments.value = (res.data || []).slice(0, 5)
        stats.pendingAssignments = (res.data || []).length
      }
    })
    .catch(() => {
      pendingAssignments.value = []
      stats.pendingAssignments = 0
    })
    .finally(() => {
      loadingAssignments.value = false
    })
}

function loadWeakPoints() {
  loadingWeakPoints.value = true
  api.get('/student/weak-points')
    .then((res) => {
      if (res.success) {
        weakPointList.value = res.data || []
        stats.avgScore = getAverageMastery(weakPointList.value)
        return nextTick()
      }
      return null
    })
    .then(() => {
      renderChart()
    })
    .catch(() => {
      weakPointList.value = []
      stats.avgScore = 0
    })
    .finally(() => {
      loadingWeakPoints.value = false
    })
}

function getAverageMastery(list) {
  if (!list.length) return 0
  const total = list.reduce((sum, item) => sum + parseInt(item.masteryRate || 0, 10), 0)
  return Math.round(total / list.length)
}

function renderChart() {
  const chartDom = document.getElementById('knowledgeChart')
  if (!chartDom) return
  if (chart) chart.dispose()
  chart = echarts.init(chartDom)
  chart.setOption({
    tooltip: { trigger: 'item' },
    series: [{
      name: '掌握情况',
      type: 'pie',
      radius: ['50%', '70%'],
      data: [
        { value: Math.max(weakBreakdown.value.mastered, 1), name: '已掌握', itemStyle: { color: '#67C23A' } },
        { value: Math.max(weakBreakdown.value.learning, 1), name: '待巩固', itemStyle: { color: '#E6A23C' } },
        { value: Math.max(weakBreakdown.value.weak, 1), name: '薄弱', itemStyle: { color: '#F56C6C' } }
      ]
    }]
  })
}

function goToAssignments() {
  router.push('/student/assignments')
}

function goToKnowledge() {
  router.push('/student/knowledge')
}

function goToWeakPoints() {
  router.push('/student/weak-points')
}

function goToWrongQuestions() {
  router.push('/student/wrong-questions')
}

function startAssignment(row) {
  router.push('/student/assignment/' + row.id)
}

function formatDate(date) {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '未设置'
}

onMounted(() => {
  loadAssignments()
  loadWeakPoints()
  window.addEventListener('resize', renderChart)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', renderChart)
  if (chart) chart.dispose()
})
</script>

<style scoped>
.student-dashboard {
  padding: 24px;
}

.page-header {
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
  color: #111827;
}

.page-header p {
  margin: 6px 0 0;
  color: #6b7280;
}

.main-row {
  margin-top: 20px;
}

.stat-cards {
  margin-bottom: 4px;
}

.stat-card {
  border-radius: 20px;
  color: #fff;
  padding: 22px;
  min-height: 140px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 16px 36px rgba(15, 23, 42, 0.12);
}

.stat-card-purple {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card-blue {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.weak-card {
  background: linear-gradient(135deg, #f97316, #ef4444);
}

.mastered-card {
  background: linear-gradient(135deg, #22c55e, #16a34a);
}

.stat-value {
  font-size: 30px;
  font-weight: 800;
}

.stat-label {
  font-size: 14px;
  opacity: 0.95;
}

.gradient-card {
  border-radius: 22px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.dashboard-primary-btn {
  color: #ffffff !important;
}

.quick-entry-card {
  margin-top: 20px;
}

.quick-entry-card :deep(.el-card__body) {
  padding: 18px;
}

.quick-actions-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 14px;
}

.quick-action-btn {
  margin: 0;
  min-height: 72px;
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  gap: 6px;
  padding: 14px 18px;
  box-shadow: 0 12px 26px rgba(15, 23, 42, 0.1);
}

.quick-action-title,
.quick-action-subtitle {
  width: 100%;
  text-align: left;
}

.quick-action-title {
  font-size: 16px;
  font-weight: 700;
  color: #ffffff;
}

.quick-action-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.88);
}

.quick-action-primary {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
  border-color: #1d4ed8;
}

.quick-action-warning {
  background: linear-gradient(135deg, #f59e0b, #d97706);
  border-color: #d97706;
  color: #ffffff;
}

.quick-action-danger {
  background: linear-gradient(135deg, #ef4444, #dc2626);
  border-color: #dc2626;
  color: #ffffff;
}

.mastery-breakdown {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  margin-bottom: 14px;
}

.mastery-item {
  padding: 12px;
  border-radius: 14px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.mastery-item strong {
  font-size: 24px;
  color: #111827;
}

.mastery-item small {
  color: #64748b;
}

.is-weak {
  background: #fef2f2;
}

.is-middle {
  background: #fffbeb;
}

.is-strong {
  background: #f0fdf4;
}

.knowledge-chart {
  height: 220px;
}
</style>
