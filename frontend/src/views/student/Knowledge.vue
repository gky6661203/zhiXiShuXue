<template>
  <div class="knowledge-graph-page">
    <div class="page-header">
      <h2>知识图谱</h2>
      <p>用一张分层知识树，直观看到学生在初中数学各大类与核心知识点上的掌握情况。</p>
    </div>

    <div class="hero-strip">
      <div class="hero-card gradient-card">
        <div class="hero-kicker">JUNIOR MATH KNOWLEDGE TREE</div>
        <div class="hero-title">{{ studentDisplayName }} · 初中数学知识树</div>
        <div class="hero-desc">
          左侧展示一张初中数学知识树：先看 5 个大类，再点击展开细分知识点。绿色表示已掌握，黄色表示待巩固，红色表示薄弱，帮助老师快速定位问题。
        </div>
        <div class="hero-tags">
          <span class="hero-tag">知识树联动</span>
          <span class="hero-tag">当前页直接补练</span>
          <span class="hero-tag">自动批改</span>
          <span class="hero-tag">错题本同步</span>
          <span class="hero-tag">掌握度更新</span>
        </div>
      </div>

      <div class="stats-grid">
        <div class="stats-card gradient-card">
          <div class="stats-label">薄弱</div>
          <div class="stats-value">{{ masteryBreakdown.weak }}</div>
          <div class="stats-desc">与首页薄弱知识点实时同步</div>
        </div>
        <div class="stats-card gradient-card">
          <div class="stats-label">待巩固</div>
          <div class="stats-value">{{ masteryBreakdown.learning }}</div>
          <div class="stats-desc">与首页知识掌握概览实时同步</div>
        </div>
        <div class="stats-card gradient-card">
          <div class="stats-label">已掌握</div>
          <div class="stats-value">{{ masteryBreakdown.mastered }}</div>
          <div class="stats-desc">与首页知识掌握概览实时同步</div>
        </div>
        <div class="stats-card gradient-card">
          <div class="stats-label">当前聚焦</div>
          <div class="stats-value small">{{ selectedKnowledge.name }}</div>
          <div class="stats-desc">{{ getMasteryLabel(selectedKnowledge.masteryRate) }}</div>
        </div>
      </div>
    </div>

    <div class="top-layout">
      <div class="chart-column">
        <el-card class="gradient-card chart-card">
          <template #header>
            <div class="section-header">
              <div>
                <div class="section-title">初中数学知识树</div>
                <div class="section-desc">首屏只展示 5 个大类，点击后展开细分知识点；颜色直接反映掌握、待巩固、薄弱状态。</div>
              </div>
              <div class="legend-row">
                <span class="legend-item"><i class="legend-dot green"></i>已掌握</span>
                <span class="legend-item"><i class="legend-dot yellow"></i>待巩固</span>
                <span class="legend-item"><i class="legend-dot red"></i>薄弱</span>
              </div>
            </div>
          </template>
          <div ref="chartRef" class="tree-chart"></div>
        </el-card>

        <el-card class="gradient-card practice-card">
          <template #header>
            <div class="section-header compact">
              <div>
                <div class="section-title">个性化补练习题</div>
                <div class="section-desc">可在当前页直接作答、自动批改，并同步更新掌握状态。</div>
              </div>
              <el-tag type="warning">{{ selectedPracticeQuestions.length }} 题</el-tag>
            </div>
          </template>

          <div v-if="selectedPracticeQuestions.length" class="practice-question-list">
            <div
              v-for="(item, index) in selectedPracticeQuestions"
              :key="item.id || index"
              class="practice-question-item"
            >
              <div class="practice-main">
                <div class="practice-title-row">
                  <div class="practice-title">第 {{ index + 1 }} 题 · {{ getQuestionTypeLabel(item.type) }}</div>
                  <el-tag size="small" effect="plain">{{ getDifficultyLabel(item.difficulty) }}</el-tag>
                </div>

                <div class="practice-text">{{ item.content }}</div>

                <div v-if="item.options && item.options.length" class="practice-options">
                  <div
                    v-for="(option, optionIndex) in item.options"
                    :key="optionIndex"
                    class="practice-option"
                  >
                    {{ String.fromCharCode(65 + optionIndex) }}. {{ option }}
                  </div>
                </div>

                <div class="practice-meta">
                  <span>知识点：{{ selectedKnowledge.name }}</span>
                  <span>难度：{{ getDifficultyLabel(item.difficulty) }}</span>
                </div>
              </div>

              <el-input
                v-model="practiceAnswers[item.id]"
                type="textarea"
                :rows="item.type === 'shortAnswer' ? 4 : 2"
                placeholder="请输入你的答案"
                class="practice-answer-input"
              />

              <div
                v-if="practiceFeedbackMap[item.id]"
                :class="[
                  'practice-feedback',
                  practiceFeedbackMap[item.id].correct ? 'is-correct' : 'is-wrong'
                ]"
              >
                <div class="practice-feedback-title">
                  {{ practiceFeedbackMap[item.id].correct ? '回答正确' : '回答有误' }}
                </div>
                <div>正确答案：{{ practiceFeedbackMap[item.id].answer || '-' }}</div>
                <div v-if="practiceFeedbackMap[item.id].analysis">
                  解析：{{ practiceFeedbackMap[item.id].analysis }}
                </div>
              </div>
            </div>

            <div class="practice-submit-bar">
              <div class="practice-submit-text">
                已作答 {{ selectedPracticeAnsweredCount }} / {{ selectedPracticeQuestions.length }} 题
              </div>
              <div class="practice-submit-actions">
                <el-button @click="resetSelectedPracticeAnswers">清空答案</el-button>
                <el-button
                  type="primary"
                  :loading="selectedPracticeSubmitting"
                  @click="submitSelectedPractice"
                >
                  提交并同步状态
                </el-button>
                <el-button type="primary" plain @click="startPractice()">
                  进入独立补练页
                </el-button>
              </div>
            </div>
          </div>
          <el-empty
            v-else
            :description="getPracticeEmptyText()"
          />
        </el-card>
      </div>

      <div class="detail-column">
        <el-card class="gradient-card detail-card">
          <template #header>
            <div class="section-header compact">
              <div>
                <div class="section-title">知识点详情</div>
                <div class="section-desc">当前所选知识点的即时诊断与状态概览。</div>
              </div>
              <el-tag :type="getTagTypeByRate(selectedKnowledge.masteryRate)">
                {{ selectedKnowledge.masteryRate }}%
              </el-tag>
            </div>
          </template>

          <div class="focus-title">{{ selectedKnowledge.name }}</div>
          <div class="focus-meta">
            <span class="focus-pill">状态：{{ getMasteryLabel(selectedKnowledge.masteryRate) }}</span>
            <span class="focus-pill">错题 {{ selectedWrongQuestions.length }}</span>
            <span class="focus-pill">题目 {{ selectedKnowledge.totalQuestionCount || 0 }}</span>
            <span class="focus-pill">层级 {{ selectedKnowledge.depth ?? 0 }}</span>
          </div>

          <div class="focus-summary">
            <div class="summary-box">
              <div class="summary-label">当前掌握度</div>
              <div class="summary-value">{{ selectedKnowledge.masteryRate }}%</div>
            </div>
            <div class="summary-box">
              <div class="summary-label">题目总数</div>
              <div class="summary-value">{{ selectedKnowledge.totalQuestionCount || 0 }}</div>
            </div>
            <div class="summary-box">
              <div class="summary-label">薄弱后代</div>
              <div class="summary-value">{{ selectedKnowledge.descendantWeakCount || 0 }}</div>
            </div>
          </div>

          <div class="focus-diagnosis">
            <div class="diagnosis-block">
              <div class="diagnosis-label">知识点说明</div>
              <div class="diagnosis-text">{{ selectedKnowledge.description || '当前知识点暂无补充说明。' }}</div>
            </div>
            <div class="diagnosis-block" style="margin-top: 15px;">
              <el-button type="primary" size="small" @click="showAllQuestionsDialog = true">
                查看全部题目列表 ({{ selectedKnowledge.totalQuestionCount || 0 }})
              </el-button>
            </div>
            <div class="diagnosis-block">
              <div class="diagnosis-label">推荐策略</div>
              <div class="diagnosis-text">{{ selectedKnowledge.recommendationText || '建议先查看相关例题，再进行专项补练。' }}</div>
            </div>
            <div class="diagnosis-chip-group">
              <div class="diagnosis-chip-title">前置路径</div>
              <div class="diagnosis-chip-list">
                <span v-if="selectedKnowledge.ancestorNames && selectedKnowledge.ancestorNames.length" v-for="item in selectedKnowledge.ancestorNames" :key="'ancestor-' + item" class="path-chip">{{ item }}</span>
                <span v-else class="path-chip empty">当前为一级知识点</span>
              </div>
            </div>
            <div class="diagnosis-chip-group">
              <div class="diagnosis-chip-title">薄弱子节点</div>
              <div class="diagnosis-chip-list">
                <span v-if="selectedKnowledge.weakChildNames && selectedKnowledge.weakChildNames.length" v-for="item in selectedKnowledge.weakChildNames" :key="'weak-child-' + item" class="path-chip warning">{{ item }}</span>
                <span v-else class="path-chip empty">当前没有待处理子节点</span>
              </div>
            </div>
            <div class="diagnosis-chip-group">
              <div class="diagnosis-chip-title">需关注的薄弱后代</div>
              <div class="diagnosis-chip-list">
                <span v-if="selectedKnowledge.weakDescendantNames && selectedKnowledge.weakDescendantNames.length" v-for="item in selectedKnowledge.weakDescendantNames" :key="'weak-desc-' + item" class="path-chip danger">{{ item }}</span>
                <span v-else class="path-chip empty">当前没有扩散性薄弱点</span>
              </div>
            </div>
          </div>
        </el-card>

        <el-card class="gradient-card progress-card">
          <template #header>
            <div class="section-header compact">
              <div>
                <div class="section-title">补练结果统计</div>
                <div class="section-desc">补练正确率、知识点掌握度更新，可视化展示学习进步。</div>
              </div>
              <el-tag type="success">持续提升中</el-tag>
            </div>
          </template>

          <div class="progress-overview">
            <div class="progress-box">
              <div class="progress-label">补练正确率</div>
              <div class="progress-value">{{ overallPracticeAccuracy }}%</div>
            </div>
            <div class="progress-box">
              <div class="progress-label">掌握提升</div>
              <div class="progress-value">+{{ totalMasteryGain }}%</div>
            </div>
          </div>

          <div class="progress-bars">
            <div v-for="item in progressStats" :key="item.name" class="progress-item">
              <div class="progress-item-head">
                <span>{{ item.name }}</span>
                <span>{{ item.after }}%</span>
              </div>
              <div class="progress-track">
                <div class="progress-before" :style="{ width: item.before + '%' }"></div>
                <div class="progress-after" :style="{ width: item.after + '%' }"></div>
              </div>
              <div class="progress-meta">前：{{ item.before }}% → 后：{{ item.after }}%</div>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 侧边抽屉：知识点详情 -->
    <el-drawer
      v-model="showDetailDrawer"
      :title="detailData.name || '知识点详情'"
      size="450px"
      direction="rtl"
      destroy-on-close
    >
      <div v-loading="loadingDetail" class="drawer-content">
        <div v-if="detailData.id">
          <div class="drawer-section">
            <div class="section-title">近 30 日关联错题</div>
            <div v-if="detailData.wrongQuestions && detailData.wrongQuestions.length" class="wrong-list">
              <div v-for="q in detailData.wrongQuestions" :key="q.id" class="wrong-item">
                <div class="wrong-q-content">{{ q.content }}</div>
                <div class="wrong-ans-grid">
                  <div class="ans-box">
                    <span class="ans-label">你的答案:</span>
                    <span class="ans-value wrong">{{ q.userAnswer || '未填' }}</span>
                  </div>
                  <div class="ans-box">
                    <span class="ans-label">正确答案:</span>
                    <span class="ans-value correct">{{ q.answerDisplay || q.answer }}</span>
                  </div>
                </div>
                <div class="wrong-reason">
                  <el-tag size="small" type="danger" effect="plain">
                    {{ q.errorType || '计算错误' }}
                  </el-tag>
                  <span class="wrong-time">{{ formatDate(q.lastAnsweredAt || q.createdAt) }}</span>
                </div>
              </div>
            </div>
            <el-empty v-else description="近 30 日暂无错题记录" :image-size="60" />
          </div>

          <div class="drawer-section">
            <div class="section-title">系统推荐补练变式题</div>
            <div v-if="detailData.recommendedQuestions && detailData.recommendedQuestions.length" class="recommend-list">
              <div v-for="q in detailData.recommendedQuestions" :key="q.id" class="recommend-item">
                <div class="recommend-q-content">{{ q.content }}</div>
                <div class="recommend-footer">
                  <el-tag size="small">{{ getDifficultyLabel(q.difficulty) }}</el-tag>
                  <el-button type="primary" size="small" plain @click="addToPracticeQueue(q)">一键加入补练队列</el-button>
                </div>
              </div>
            </div>
            <el-empty v-else description="暂无推荐变式题" :image-size="60" />
          </div>
        </div>
      </div>
    </el-drawer>

    <!-- 全部题目列表弹窗 -->
    <el-dialog
      v-model="showAllQuestionsDialog"
      :title="selectedKnowledge.name + ' - 全部题目'"
      width="800px"
      destroy-on-close
    >
      <div v-loading="loadingAllQuestions" class="all-questions-list">
        <div v-if="allQuestions.length">
          <div v-for="(q, index) in allQuestions" :key="q.id" class="question-item">
            <div class="q-header">
              <span class="q-index">题目 {{ index + 1 }}</span>
              <el-tag size="small" :type="q.difficulty === 'hard' ? 'danger' : q.difficulty === 'medium' ? 'warning' : 'success'">
                {{ getDifficultyLabel(q.difficulty) }}
              </el-tag>
              <el-tag size="small" effect="plain" style="margin-left: 8px;">{{ getQuestionTypeLabel(q.type) }}</el-tag>
            </div>
            <div class="q-content">{{ q.content }}</div>
            <div v-if="q.options && q.options.length" class="q-options">
              <div v-for="(opt, optIdx) in q.options" :key="optIdx" class="q-option">
                {{ String.fromCharCode(65 + optIdx) }}. {{ opt }}
              </div>
            </div>
            <div class="q-footer">
              <el-collapse>
                <el-collapse-item title="查看答案与解析" :name="q.id">
                  <div class="q-answer"><strong>答案：</strong>{{ q.answerDisplay || q.answer }}</div>
                  <div v-if="q.analysis" class="q-analysis"><strong>解析：</strong>{{ q.analysis }}</div>
                </el-collapse-item>
              </el-collapse>
            </div>
          </div>
        </div>
        <el-empty v-else description="该知识点暂无题目" />
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import api from '@/utils/api'
import * as echarts from 'echarts'
import {
  MAJOR_CATEGORY_CONFIG,
  getMasteryStatus,
  getMasteryLabel as getUnifiedMasteryLabel,
  getMasteryTagType,
  inferMajorCategory
} from '@/utils/knowledge-meta'

const router = useRouter()

const userInfo = (() => {
  try {
    return JSON.parse(localStorage.getItem('user') || '{}')
  } catch (error) {
    return {}
  }
})()

const studentDisplayName = computed(() => userInfo.name || userInfo.username || '同学')

const chartRef = ref(null)
let chart = null

const weakPointList = ref([])
const wrongQuestionBook = ref([])
const selectedPracticeQuestions = ref([])
const practiceAnswers = ref({})
const practiceFeedbackMap = ref({})
const selectedPracticeSubmitting = ref(false)
const progressStats = ref([])
const selectedKnowledge = ref({ id: '', name: '未选择知识点', masteryRate: 100, parentId: '', childrenIds: [] })

// 详情抽屉相关
const showDetailDrawer = ref(false)
const loadingDetail = ref(false)
const detailData = ref({
  id: '',
  name: '',
  wrongQuestions: [],
  recommendedQuestions: []
})

function loadKnowledgeDetail(id) {
  loadingDetail.value = true
  showDetailDrawer.value = true
  api.get(`/student/knowledge-point/${id}/detail`)
    .then(res => {
      if (res.success) {
        detailData.value = res.data
      }
    })
    .finally(() => {
      loadingDetail.value = false
    })
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return `${date.getMonth() + 1}月${date.getDate()}日`
}

function addToPracticeQueue(q) {
  // 这里可以调用后端的“加入补练队列”接口，目前先模拟成功
  ElMessage.success(`题目已加入补练队列：${q.content.slice(0, 15)}...`)
}

// 全部题目弹窗相关
const showAllQuestionsDialog = ref(false)
const allQuestions = ref([])
const loadingAllQuestions = ref(false)

watch(showAllQuestionsDialog, (val) => {
  if (val && selectedKnowledge.value.id) {
    loadAllQuestions()
  }
})

function loadAllQuestions() {
  loadingAllQuestions.value = true
  api.get('/student/questions', { knowledgePointId: selectedKnowledge.value.id, all: true })
    .then(res => {
      if (res.success) {
        allQuestions.value = res.data || []
      }
    })
    .finally(() => {
      loadingAllQuestions.value = false
    })
}

const weakPointMap = computed(() => {
  const map = {}
  weakPointList.value.forEach(item => {
    map[item.id] = item
  })
  return map
})

const selectedWrongQuestions = computed(() =>
  wrongQuestionBook.value.filter(item => {
    return Array.isArray(item.knowledgePoints) && item.knowledgePoints.includes(selectedKnowledge.value.id)
  })
)

const selectedPracticeAnsweredCount = computed(() =>
  selectedPracticeQuestions.value.filter(item => String(practiceAnswers.value[item.id] || '').trim()).length
)

const leafNodes = computed(() => weakPointList.value.filter(item => item.isLeaf))

const masteryBreakdown = computed(() => {
  return weakPointList.value.reduce((acc, item) => {
    const status = getMasteryStatus(item.masteryRate)
    if (status === 'mastered') acc.mastered += 1
    else if (status === 'learning') acc.learning += 1
    else acc.weak += 1
    return acc
  }, { mastered: 0, learning: 0, weak: 0 })
})


const overallPracticeAccuracy = computed(() => {
  if (!progressStats.value.length) return 0
  return Math.round(progressStats.value.reduce((sum, item) => sum + item.after, 0) / progressStats.value.length)
})

const totalMasteryGain = computed(() => {
  return progressStats.value.reduce((sum, item) => sum + Math.max(0, item.after - item.before), 0)
})

function loadWeakPoints() {
  return api.get('/student/weak-points')
    .then((res) => {
      if (res.success) {
        weakPointList.value = res.data || []
        if (!selectedKnowledge.value.id && weakPointList.value.length) {
          const firstWeak = weakPointList.value.find(item => getMasteryStatus(item.masteryRate) === 'weak') || weakPointList.value[0]
          selectedKnowledge.value = firstWeak
        } else if (selectedKnowledge.value.id) {
          const matched = weakPointList.value.find(item => item.id === selectedKnowledge.value.id)
          if (matched) selectedKnowledge.value = matched
        }
      }
    })
    .catch((error) => {
      console.error('加载薄弱知识点失败:', error)
      ElMessage.error('加载薄弱知识点失败')
    })
}

function loadWrongQuestionBook() {
  return api.get('/student/wrong-questions')
    .then((res) => {
      if (res.success) wrongQuestionBook.value = res.data || []
    })
    .catch((error) => {
      console.error('加载错题本失败:', error)
      ElMessage.error('加载错题本失败')
    })
}

function loadSelectedPracticeQuestions() {
  if (!selectedKnowledge.value.id) {
    selectedPracticeQuestions.value = []
    practiceAnswers.value = {}
    practiceFeedbackMap.value = {}
    return Promise.resolve()
  }

  if (getMasteryStatus(selectedKnowledge.value.masteryRate) === 'mastered' && selectedKnowledge.value.isLeaf) {
    selectedPracticeQuestions.value = []
    practiceAnswers.value = {}
    practiceFeedbackMap.value = {}
    return Promise.resolve()
  }

  return api.get('/student/practice/' + selectedKnowledge.value.id)
    .then((res) => {
      if (res.success) {
        selectedPracticeQuestions.value = Array.isArray(res.data && res.data.questions) ? res.data.questions : []
        practiceAnswers.value = {}
        practiceFeedbackMap.value = {}
      }
    })
    .catch((error) => {
      console.error('加载补练题失败:', error)
      ElMessage.error('加载补练题失败')
    })
}

function buildPracticeAnalysis(question, isCorrect) {
  if (isCorrect) return '回答正确，说明你已经掌握了这道题的核心思路。'
  if (question.type === 'choice') return '选择题出错时，建议重点核对题干条件和各选项差异。'
  if (question.type === 'fill') return '填空题出错时，通常是公式、步骤或计算细节没有落实到位。'
  return '这道题还需要加强表达与步骤完整性，建议对照答案重新整理思路。'
}

function resetSelectedPracticeAnswers() {
  practiceAnswers.value = {}
  practiceFeedbackMap.value = {}
}

function getQuestionTypeLabel(type) {
  if (type === 'choice') return '选择题'
  if (type === 'fill') return '填空题'
  if (type === 'shortAnswer') return '简答题'
  return '未知题型'
}

function getDifficultyLabel(level) {
  if (level === 'easy') return '简单'
  if (level === 'medium') return '中等'
  if (level === 'hard') return '困难'
  return level || '未知'
}

function getPracticeEmptyText() {
  if (!selectedKnowledge.value.id) return '请先选择一个知识点'
  if (getMasteryStatus(selectedKnowledge.value.masteryRate) === 'mastered' && selectedKnowledge.value.isLeaf) {
    return '当前知识点已掌握，暂不生成个性化练习题'
  }
  return '当前知识点暂无可用练习题'
}

function submitSelectedPractice() {
  if (!selectedKnowledge.value.id) {
    ElMessage.warning('请先选择一个知识点再开始补练')
    return
  }

  const questionIds = selectedPracticeQuestions.value
    .map(item => item.id)
    .filter(id => String(practiceAnswers.value[id] || '').trim())

  if (!questionIds.length) {
    ElMessage.warning('请至少完成一道题后再提交')
    return
  }

  selectedPracticeSubmitting.value = true
  api.post('/student/practice/' + selectedKnowledge.value.id + '/submit', {
    answers: questionIds.reduce((acc, id) => {
      acc[id] = String(practiceAnswers.value[id]).trim()
      return acc
    }, {}),
    questionIds,
    mode: 'weak-point',
    title: selectedKnowledge.value.name + ' · 个性化补练'
  })
    .then((res) => {
      if (res.success) {
        const results = Array.isArray(res.data && res.data.questionResults) ? res.data.questionResults : []
        const nextFeedback = {}
        selectedPracticeQuestions.value.forEach((question) => {
          const result = results.find(item => item.questionId === question.id)
          if (result) {
            nextFeedback[question.id] = {
              correct: !!result.correct,
              answer: question.answerDisplay || question.answer || '-',
              analysis: buildPracticeAnalysis(question, !!result.correct)
            }
          }
        })
        practiceFeedbackMap.value = nextFeedback
        ElMessage.success(res.message || '提交成功')
        return Promise.all([loadWeakPoints(), loadWrongQuestionBook(), loadSelectedPracticeQuestions()]).then(() => {
          refreshProgressStatsFromWeakPoints()
          rebuildChart()
        })
      }
    })
    .catch((error) => {
      console.error('提交补练失败:', error)
      ElMessage.error('提交补练失败')
    })
    .finally(() => {
      selectedPracticeSubmitting.value = false
    })
}

function refreshProgressStatsFromWeakPoints() {
  progressStats.value = leafNodes.value
    .slice()
    .sort((a, b) => a.masteryRate - b.masteryRate)
    .slice(0, 6)
    .map(item => ({
      name: item.name,
      before: Math.max(0, item.directMasteryRate ? Math.min(item.directMasteryRate, item.masteryRate) - 10 : item.masteryRate - 10),
      after: item.masteryRate
    }))
}

function getMasteryLabel(score) {
  return getUnifiedMasteryLabel(score)
}

function getWrongQuestionMasteryRate(item) {
  const kpId = item && Array.isArray(item.knowledgePoints) && item.knowledgePoints.length ? item.knowledgePoints[0] : ''
  const matched = weakPointMap.value[kpId]
  if (matched) return parseInt(matched.masteryRate || 0, 10)
  return item.mastered ? 80 : 59
}

function getTagTypeByRate(score) {
  return getMasteryTagType(score)
}

function getMasteryStatusClass(score) {
  return getMasteryStatus(score)
}

function getPriorityText(score) {
  if (score < 40) return '高'
  if (score < 60) return '中'
  return '低'
}

function focusKnowledgePoint(knowledgePointId) {
  const matched = weakPointMap.value[knowledgePointId]
  if (!matched) return
  selectedKnowledge.value = matched
  loadSelectedPracticeQuestions()
  nextTick().then(() => {
    if (chart) {
      chart.dispatchAction({
        type: 'highlight',
        seriesIndex: 0,
        dataId: knowledgePointId
      })
    }
  })
}

function formatTreeLabel(name) {
  const text = String(name || '')
  if (text.length <= 8) return text
  if (text.length <= 12) return text.slice(0, 6) + '\n' + text.slice(6)
  return text.slice(0, 6) + '\n' + text.slice(6, 12)
}

function pickVisibleKnowledgePoints() {
  return weakPointList.value
    .filter(item => String(item.id || '').startsWith('kp-'))
    .sort((a, b) => a.depth - b.depth || a.order - b.order || a.name.localeCompare(b.name, 'zh-CN'))
}

function buildKnowledgeTree() {
  const visibleNodes = pickVisibleKnowledgePoints()
  const cloneMap = {}
  const orphanRoots = []

  visibleNodes.forEach(item => {
    cloneMap[item.id] = {
      ...item,
      children: [],
      masteryScore: parseInt(item.masteryRate || 0, 10),
      virtual: false
    }
  })

  Object.values(cloneMap).forEach(item => {
    if (item.parentId && cloneMap[item.parentId]) cloneMap[item.parentId].children.push(item)
    else orphanRoots.push(item)
  })

  const majorVirtualRoots = MAJOR_CATEGORY_CONFIG.map((item, index) => ({
    id: 'major-' + item.name,
    name: item.name,
    order: index + 1,
    children: [],
    virtual: true
  }))
  const majorVirtualMap = majorVirtualRoots.reduce((acc, item) => {
    acc[item.name] = item
    return acc
  }, {})

  orphanRoots.forEach((node) => {
    const majorName = inferMajorCategory(node, '数与式')
    if (majorVirtualMap[majorName]) {
      majorVirtualMap[majorName].children.push(node)
    } else {
      majorVirtualRoots[0].children.push(node)
    }
  })

  const enrich = (node, depth = 0) => {
    const children = node.children
      .sort((a, b) => a.order - b.order || a.name.localeCompare(b.name, 'zh-CN'))
      .map(child => enrich(child, depth + 1))

    const score = node.virtual
      ? (
        children.length
          ? Math.min(...children.map(item => typeof item.masteryScore === 'number' ? item.masteryScore : 100))
          : 100
      )
      : node.masteryScore
    const status = getMasteryStatus(score)

    return {
      id: node.id,
      name: node.name,
      depth,
      masteryScore: score,
      masteryLabel: getMasteryLabel(score),
      masteryStatus: status,
      value: score,
      symbol: 'roundRect',
      symbolSize: node.virtual ? [126, 46] : depth === 1 ? [98, 36] : [86, 30],
      itemStyle: {
        color: node.virtual
          ? '#1d4ed8'
          : status === 'weak' ? '#ef4444' : status === 'learning' ? '#f59e0b' : '#22c55e',
        borderColor: node.virtual
          ? '#1e40af'
          : status === 'weak' ? '#dc2626' : status === 'learning' ? '#d97706' : '#16a34a',
        borderWidth: node.virtual ? 3 : status === 'weak' ? 3 : 2,
        shadowBlur: node.virtual ? 16 : status === 'weak' ? 14 : 8,
        shadowColor: node.virtual ? 'rgba(37,99,235,0.28)' : status === 'weak' ? 'rgba(239,68,68,0.24)' : 'rgba(148,163,184,0.18)',
        borderRadius: 10
      },
      label: {
        color: '#ffffff',
        fontSize: node.virtual ? 15 : 12,
        fontWeight: node.virtual ? 900 : status === 'weak' ? 900 : 700,
        lineHeight: node.virtual ? 19 : 15,
        formatter: ({ name }) => formatTreeLabel(name)
      },
      lineStyle: {
        color: node.virtual ? 'rgba(37,99,235,0.72)' : status === 'weak' ? 'rgba(239,68,68,0.84)' : 'rgba(148,163,184,0.72)',
        width: node.virtual ? 2.2 : status === 'weak' ? 2.6 : 1.4,
        curveness: 0.12
      },
      children,
      collapsed: node.virtual ? true : depth >= 1
    }
  }

  return {
    id: 'root',
    name: '初中数学',
    depth: -1,
    masteryScore: 100,
    children: majorVirtualRoots
      .sort((a, b) => a.order - b.order || a.name.localeCompare(b.name, 'zh-CN'))
      .map(item => enrich(item, 0))
  }
}

function initChart() {
  if (!chartRef.value) return
  chart = echarts.init(chartRef.value)
  const data = buildKnowledgeTree()
  chart.setOption({
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      formatter(params) {
        const dataItem = params.data || {}
        const score = typeof dataItem.masteryScore === 'number' ? dataItem.masteryScore : null
        const totalCount = dataItem.totalQuestionCount || 0
        return `<div style="font-weight:700;margin-bottom:6px;">${dataItem.name}</div>
                <div>状态：${score !== null ? getMasteryLabel(score) : '未知'}</div>
                <div>掌握度：${score !== null ? score + '%' : '-'}</div>
                <div>题目数量：${totalCount} 题</div>
                <div style="margin-top:6px;color:#94a3b8;">点击节点可展开/收起并联动详情、练习。</div>`
      }
    },
    series: [{
      type: 'tree',
      data: [data],
      top: '5%',
      left: '4%',
      bottom: '5%',
      right: '18%',
      orient: 'LR',
      symbol: 'circle',
      symbolSize: 7,
      roam: true,
      expandAndCollapse: true,
      initialTreeDepth: 1,
      edgeShape: 'polyline',
      edgeForkPosition: '52%',
      animationDurationUpdate: 420,
      animationEasingUpdate: 'cubicOut',
      lineStyle: {
        width: 1.3,
        curveness: 0.06
      },
      label: {
        position: 'inside',
        verticalAlign: 'middle',
        align: 'center'
      },
      leaves: {
        label: {
          position: 'inside',
          align: 'center'
        }
      },
      emphasis: {
        focus: 'descendant'
      }
    }]
  })

  chart.on('click', function (params) {
    if (params && params.data && params.data.id && params.data.id !== 'root') {
      const matched = weakPointMap.value[params.data.id]
      if (matched) {
        selectedKnowledge.value = matched
        loadSelectedPracticeQuestions()
        // 点击节点弹出侧边抽屉
        loadKnowledgeDetail(params.data.id)
      }
    }
  })
}

function rebuildChart() {
  if (chart) {
    chart.dispose()
    chart = null
  }
  nextTick().then(() => initChart())
}

function handleResize() {
  if (chart) chart.resize()
}

function startPractice() {
  if (!selectedKnowledge.value.id) {
    ElMessage.warning('请先选择知识点')
    return
  }
  router.push({ path: '/student/practice', query: { kpId: selectedKnowledge.value.id } })
}

onMounted(async () => {
  await Promise.all([loadWeakPoints(), loadWrongQuestionBook()])
  await loadSelectedPracticeQuestions()
  refreshProgressStatsFromWeakPoints()
  await nextTick()
  initChart()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  if (chart) chart.dispose()
})
</script>

<style scoped>
.all-questions-list {
  max-height: 600px;
  overflow-y: auto;
  padding: 10px;
}

.question-item {
  border-bottom: 1px solid #eee;
  padding: 15px 0;
}

.question-item:last-child {
  border-bottom: none;
}

.q-header {
  margin-bottom: 10px;
  display: flex;
  align-items: center;
}

.q-index {
  font-weight: bold;
  margin-right: 15px;
  color: #333;
}

.q-content {
  font-size: 15px;
  line-height: 1.6;
  margin-bottom: 15px;
  color: #444;
}

.q-options {
  margin-bottom: 15px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.q-option {
  padding: 8px 12px;
  background: #f8fafc;
  border-radius: 6px;
  font-size: 14px;
}

.q-answer {
  color: #059669;
  margin-bottom: 8px;
}

.q-analysis {
  color: #64748b;
  font-size: 13px;
  line-height: 1.5;
}

.knowledge-graph-page {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 22px;
  --panel-bg: linear-gradient(145deg, rgba(255,255,255,0.96), rgba(247,250,255,0.95));
  --text-main: #0f172a;
  --text-sub: #64748b;
  --line-soft: #e2e8f0;
  --blue: #2563eb;
  --cyan: #0ea5e9;
  --navy: #0f172a;
}

.drawer-content {
  padding: 0 20px 20px;
}

.drawer-section {
  margin-bottom: 30px;
}

.drawer-section .section-title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 15px;
  padding-left: 10px;
  border-left: 4px solid #1d4ed8;
  color: #334155;
}

.wrong-item {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
  transition: all 0.2s;
}

.wrong-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.wrong-q-content {
  font-size: 14px;
  color: #475569;
  line-height: 1.6;
  margin-bottom: 12px;
}

.wrong-ans-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 12px;
}

.ans-box {
  background: #f8fafc;
  padding: 8px;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
}

.ans-label {
  font-size: 12px;
  color: #94a3b8;
  margin-bottom: 4px;
}

.ans-value {
  font-size: 14px;
  font-weight: bold;
}

.ans-value.wrong {
  color: #ef4444;
}

.ans-value.correct {
  color: #22c55e;
}

.wrong-reason {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.wrong-time {
  font-size: 12px;
  color: #94a3b8;
}

.recommend-item {
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 15px;
}

.recommend-q-content {
  font-size: 14px;
  color: #0369a1;
  line-height: 1.6;
  margin-bottom: 12px;
}

.recommend-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.hero-strip {
  display: grid;
  grid-template-columns: 1.15fr 0.85fr;
  gap: 18px;
}

.gradient-card {
  border: 1px solid rgba(148, 163, 184, 0.15);
  background: var(--panel-bg);
  box-shadow: 0 16px 40px rgba(15, 23, 42, 0.08);
  backdrop-filter: blur(14px);
}

.hero-card,
.stats-card,
.chart-card,
.detail-card,
.practice-card,
.example-card,
.report-card,
.route-card,
.wrong-book-card,
.progress-card {
  border-radius: 24px;
}

.hero-card {
  padding: 28px;
  background:
    radial-gradient(circle at top left, rgba(14, 165, 233, 0.18), transparent 34%),
    radial-gradient(circle at bottom right, rgba(37, 99, 235, 0.14), transparent 30%),
    linear-gradient(145deg, #ffffff, #f7fbff);
}

.hero-kicker {
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.18em;
  color: #2563eb;
}

.hero-title {
  margin-top: 10px;
  font-size: 30px;
  font-weight: 900;
  line-height: 1.3;
  color: var(--text-main);
}

.hero-desc {
  margin-top: 14px;
  font-size: 14px;
  line-height: 1.9;
  color: var(--text-sub);
}

.hero-tags {
  margin-top: 18px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.hero-tag {
  border-radius: 999px;
  padding: 7px 12px;
  font-size: 12px;
  font-weight: 700;
  color: #1d4ed8;
  background: rgba(37, 99, 235, 0.09);
}

.stats-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.stats-card {
  padding: 20px;
}

.stats-label {
  font-size: 13px;
  color: var(--text-sub);
  font-weight: 700;
}

.stats-value {
  margin-top: 10px;
  font-size: 32px;
  line-height: 1;
  font-weight: 900;
  color: var(--text-main);
}

.stats-value.small {
  font-size: 24px;
  line-height: 1.2;
}

.stats-desc {
  margin-top: 8px;
  color: var(--text-sub);
  line-height: 1.7;
  font-size: 13px;
}

.top-layout,
.bottom-layout {
  display: grid;
  grid-template-columns: minmax(0, 1.15fr) minmax(0, 0.85fr);
  gap: 18px;
}

.chart-card :deep(.el-card__body) {
  padding: 0 12px 18px;
}

.tree-chart {
  height: 760px;
  width: 100%;
  border-radius: 16px;
  background: linear-gradient(180deg, rgba(248, 250, 252, 0.9), rgba(241, 245, 249, 0.55));
}

.detail-column {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.section-header.compact {
  align-items: flex-start;
}

.section-title {
  font-size: 18px;
  font-weight: 800;
  color: var(--text-main);
}

.section-desc {
  margin-top: 6px;
  color: var(--text-sub);
  line-height: 1.7;
  font-size: 13px;
}

.legend-row {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  justify-content: flex-end;
}

.legend-item {
  font-size: 12px;
  color: var(--text-sub);
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
}

.legend-dot.green { background: #22c55e; }
.legend-dot.yellow { background: #fbbf24; }
.legend-dot.orange { background: #fb923c; }
.legend-dot.red { background: #ef4444; }

.focus-title {
  font-size: 24px;
  font-weight: 900;
  color: var(--text-main);
}

.focus-meta {
  margin-top: 14px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.focus-pill {
  border-radius: 999px;
  padding: 7px 12px;
  background: #eff6ff;
  color: #1d4ed8;
  font-size: 12px;
  font-weight: 700;
}

.focus-summary {
  margin-top: 18px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.focus-diagnosis {
  margin-top: 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.diagnosis-block,
.diagnosis-chip-group {
  padding: 16px;
  border-radius: 18px;
  background: rgba(37, 99, 235, 0.05);
  border: 1px solid rgba(37, 99, 235, 0.08);
}

.diagnosis-chip-group {
  background: rgba(248, 250, 252, 0.92);
  border-color: #e2e8f0;
}

.diagnosis-label,
.diagnosis-chip-title {
  font-size: 12px;
  font-weight: 800;
  color: #1d4ed8;
  margin-bottom: 8px;
}

.diagnosis-chip-title {
  color: var(--text-sub);
}

.diagnosis-text {
  color: var(--text-main);
  line-height: 1.8;
  font-size: 13px;
}

.diagnosis-chip-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.path-chip {
  display: inline-flex;
  align-items: center;
  border-radius: 999px;
  padding: 6px 10px;
  font-size: 12px;
  font-weight: 700;
  color: #1d4ed8;
  background: rgba(59, 130, 246, 0.1);
}

.path-chip.warning {
  color: #b45309;
  background: rgba(251, 191, 36, 0.16);
}

.path-chip.danger {
  color: #b91c1c;
  background: rgba(248, 113, 113, 0.14);
}

.path-chip.empty {
  color: #64748b;
  background: rgba(148, 163, 184, 0.12);
}

.summary-box,
.progress-box {
  padding: 16px;
  border-radius: 18px;
  background: rgba(37, 99, 235, 0.05);
  border: 1px solid rgba(37, 99, 235, 0.08);
}

.summary-label,
.progress-label {
  font-size: 13px;
  color: var(--text-sub);
  font-weight: 700;
}

.summary-value,
.progress-value {
  margin-top: 8px;
  font-size: 28px;
  font-weight: 900;
  color: var(--text-main);
}

.practice-question-list,
.example-list,
.route-list,
.wrong-list,
.progress-bars {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.practice-question-item,
.example-item,
.route-item,
.wrong-item,
.progress-item {
  border-radius: 18px;
  padding: 18px;
  background: linear-gradient(135deg, #ffffff, #f8fbff);
  border: 1px solid #e8eef8;
  box-shadow: 0 10px 24px rgba(31, 41, 55, 0.06);
}

.practice-title-row,
.progress-item-head,
.wrong-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}

.practice-title,
.example-title,
.wrong-title {
  font-size: 16px;
  font-weight: 800;
  color: var(--text-main);
}

.practice-text,
.example-question,
.example-answer,
.route-desc,
.wrong-text,
.wrong-note,
.report-text,
.progress-meta {
  margin-top: 10px;
  color: var(--text-sub);
  line-height: 1.85;
}

.practice-options {
  margin-top: 12px;
  display: grid;
  gap: 8px;
}

.practice-option {
  padding: 10px 12px;
  border-radius: 12px;
  background: #f8fafc;
  color: #334155;
}

.practice-meta {
  margin-top: 12px;
  display: flex;
  flex-wrap: wrap;
  gap: 14px;
  color: var(--text-sub);
  font-size: 13px;
}

.practice-answer-input {
  margin-top: 16px;
}

.practice-feedback {
  margin-top: 14px;
  border-radius: 14px;
  padding: 14px 16px;
}

.practice-feedback.is-correct {
  background: #f0fdf4;
  color: #166534;
}

.practice-feedback.is-wrong {
  background: #fff7ed;
  color: #9a3412;
}

.practice-feedback-title {
  font-weight: 800;
  margin-bottom: 8px;
}

.practice-submit-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  flex-wrap: wrap;
  margin-top: 8px;
}

.practice-submit-text {
  color: var(--text-sub);
  font-size: 13px;
}

.practice-submit-actions,
.wrong-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}

.route-item {
  display: flex;
  gap: 14px;
  align-items: flex-start;
}

.route-step {
  width: 36px;
  height: 36px;
  flex: 0 0 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2563eb, #0ea5e9);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
}

.route-title {
  font-size: 15px;
  font-weight: 800;
  color: var(--text-main);
}

.report-text p {
  margin: 0 0 10px;
}

.progress-overview {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 14px;
}

.progress-track {
  margin-top: 8px;
  width: 100%;
  height: 12px;
  border-radius: 999px;
  overflow: hidden;
  background: #e5e7eb;
  position: relative;
}

.progress-before {
  position: absolute;
  inset: 0 auto 0 0;
  background: rgba(148, 163, 184, 0.45);
}

.progress-after {
  position: absolute;
  inset: 0 auto 0 0;
  background: linear-gradient(90deg, #2563eb, #0ea5e9);
}

@media (max-width: 1200px) {
  .hero-strip,
  .top-layout,
  .bottom-layout {
    grid-template-columns: 1fr;
  }

  .tree-chart {
    height: 520px;
  }
}

@media (max-width: 768px) {
  .stats-grid,
  .focus-summary,
  .progress-overview {
    grid-template-columns: 1fr;
  }

  .hero-title {
    font-size: 24px;
  }
}


.weak-category-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.weak-category-item {
  border-radius: 18px;
  padding: 18px;
  background: linear-gradient(135deg, #ffffff, #f8fbff);
  border: 1px solid #e8eef8;
  box-shadow: 0 10px 24px rgba(31, 41, 55, 0.06);
}

.weak-category-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  cursor: pointer;
}

.weak-category-head-right {
  display: inline-flex;
  align-items: center;
  gap: 10px;
}

.category-toggle-text {
  color: var(--text-sub);
  font-size: 12px;
  font-weight: 700;
}

.weak-category-content {
  margin-top: 14px;
}

.weak-category-title {
  font-size: 16px;
  font-weight: 800;
  color: var(--text-main);
}

.weak-category-desc {
  margin-top: 8px;
  color: var(--text-sub);
  line-height: 1.8;
  font-size: 13px;
}

.weak-category-chips {
  margin-top: 14px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.weak-chip {
  display: inline-flex;
  align-items: center;
  border-radius: 999px;
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 800;
  cursor: pointer;
  transition: transform 0.18s ease, box-shadow 0.18s ease;
}

.weak-chip:hover {
  transform: translateY(-1px);
  box-shadow: 0 8px 18px rgba(15, 23, 42, 0.08);
}

.weak-chip.mastered {
  background: rgba(34, 197, 94, 0.12);
  color: #15803d;
}

.weak-chip.learning {
  background: rgba(251, 191, 36, 0.16);
  color: #b45309;
}

.weak-chip.weak {
  background: rgba(239, 68, 68, 0.14);
  color: #b91c1c;
}

.weak-sample {
  margin-top: 14px;
  padding: 14px 16px;
  border-radius: 14px;
  background: rgba(239, 68, 68, 0.06);
  border: 1px solid rgba(239, 68, 68, 0.12);
}

.weak-sample-label {
  font-size: 12px;
  font-weight: 800;
  color: #b91c1c;
}

.weak-sample-text {
  margin-top: 8px;
  color: var(--text-main);
  line-height: 1.8;
}

.practice-category-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.practice-category-item {
  border-radius: 18px;
  padding: 18px;
  background: linear-gradient(135deg, #ffffff, #f8fbff);
  border: 1px solid #e8eef8;
  box-shadow: 0 10px 24px rgba(31, 41, 55, 0.06);
}

.practice-category-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
  cursor: pointer;
}

.practice-category-content {
  margin-top: 14px;
}

.practice-task-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.practice-task-item {
  border-radius: 14px;
  border: 1px solid #e5edf8;
  background: #f8fbff;
  padding: 12px 14px;
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 10px;
}

.practice-task-main {
  flex: 1;
  min-width: 0;
}

.practice-task-title {
  font-size: 14px;
  font-weight: 800;
  color: var(--text-main);
}

.practice-task-desc {
  margin-top: 6px;
  font-size: 12px;
  line-height: 1.7;
  color: var(--text-sub);
}

.practice-task-side {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
</style>
