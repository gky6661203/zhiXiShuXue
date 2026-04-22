<template>
  <div class="ai-tutor-widget">
    <button
      v-if="!panelVisible"
      class="ai-tutor-fab"
      type="button"
      @click="panelVisible = true"
    >
      <span class="fab-badge">AI</span>
      <div class="fab-text">
        <strong>AI助教小智</strong>
        <span>初中数学思路辅导</span>
      </div>
    </button>

    <transition name="ai-tutor-panel-fade">
      <section v-if="panelVisible" class="ai-tutor-panel gradient-card">
        <header class="panel-header">
          <div>
            <div class="panel-title">AI助教小智</div>
            <div class="panel-subtitle">普通聊天更自然，题目模式仅提供思路与方法指导</div>
          </div>
          <button class="icon-btn" type="button" @click="panelVisible = false">×</button>
        </header>

        <div class="mode-switch-bar">
          <button
            type="button"
            :class="['mode-chip', activeMode === 'chat' ? 'is-active' : '']"
            @click="switchMode('chat')"
          >
            普通聊天
          </button>
          <button
            type="button"
            :class="['mode-chip', activeMode === 'problem' ? 'is-active' : '']"
            @click="switchMode('problem')"
          >
            题目提问
          </button>
        </div>

        <div class="scope-bar">
          <span>当前模式：</span>
          <el-tag size="small" :type="activeMode === 'chat' ? 'success' : 'warning'">
            {{ activeMode === 'chat' ? '普通聊天' : '题目提问' }}
          </el-tag>
          <el-tag size="small" type="primary">初中数学</el-tag>
          <el-tag v-if="activeMode === 'problem'" size="small" type="warning">不直接给答案</el-tag>
        </div>

        <div ref="messageListRef" class="message-list">
          <div v-for="(item, index) in messages" :key="index" :class="['message-item', item.role]">
            <div class="message-bubble">{{ item.content }}</div>
          </div>

          <div v-if="loading" class="message-item assistant">
            <div class="message-bubble is-loading">
              <span class="loading-dot"></span>
              <span class="loading-dot"></span>
              <span class="loading-dot"></span>
              <span class="loading-text">正在整理思路...</span>
            </div>
          </div>
        </div>

        <div v-if="validationMessage" class="validation-tip">{{ validationMessage }}</div>
        <div v-if="errorMessage" class="error-tip">{{ errorMessage }}</div>

        <footer class="panel-footer">
          <el-input
            v-model="inputValue"
            type="textarea"
            :rows="3"
            resize="none"
            maxlength="500"
            show-word-limit
            :placeholder="activeMode === 'chat' ? '可以聊数学概念、学习方法、易错点，例如：函数是什么意思？' : '请输入题目或解题困惑，例如：一元一次方程该怎么列式？'"
            @input="handleInput"
            @keyup.ctrl.enter="sendQuestion"
          />
          <div class="footer-actions">
            <span class="footer-hint">Ctrl + Enter 发送</span>
            <el-button type="primary" :loading="loading" :disabled="!canSend" @click="sendQuestion">
              发送
            </el-button>
          </div>
        </footer>
      </section>
    </transition>
  </div>
</template>

<script setup>
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import api from '@/utils/api'

var panelVisible = ref(false)
var loading = ref(false)
var activeMode = ref('chat')
var inputValue = ref('')
var validationMessage = ref('')
var errorMessage = ref('')
var messageListRef = ref(null)
var messages = ref([
  {
    role: 'assistant',
    content: '你好，我是AI助教小智。你可以切换“普通聊天”和“题目提问”两种模式；题目模式下我只会提供思路，不会直接给出答案。'
  }
])

function validateLocally(text, mode) {
  var value = String(text || '').trim()
  var keywords = ['数学', '方程', '不等式', '函数', '几何', '三角形', '圆', '统计', '概率', '有理数', '整式', '分式', '坐标', '勾股', '初中']
  var mathPattern = /[=><≤≥≠≈+\-×÷/\^√π%]|\d+|\b[xyzabc]\b/i
  var questionPattern = /(解|求|计算|证明|已知|若|如图|题目|方法|思路|步骤|怎么)/

  if (!value) return '请输入内容后再发送。'
  if (value.length > 500) return '问题请控制在 500 字以内。'

  if (mode === 'chat') {
    if (value.indexOf('作文') > -1 || value.indexOf('英语') > -1 || value.indexOf('历史') > -1 || value.indexOf('政治') > -1) {
      return '普通聊天也仅支持初中数学范围。'
    }
    return ''
  }

  var hasKeyword = keywords.some(function (item) {
    return value.indexOf(item) > -1
  })
  var looksMath = mathPattern.test(value) && questionPattern.test(value)
  if (!hasKeyword && !looksMath) {
    return '题目提问模式仅支持初中数学题目或知识点。'
  }

  return ''
}

function switchMode(mode) {
  activeMode.value = mode
  handleInput(inputValue.value)
}

var canSend = computed(function () {
  return !loading.value && !validateLocally(inputValue.value, activeMode.value)
})

function scrollToBottom() {
  nextTick(function () {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  })
}

function handleInput(value) {
  validationMessage.value = validateLocally(value, activeMode.value)
  errorMessage.value = ''
}

async function sendQuestion() {
  var question = String(inputValue.value || '').trim()
  validationMessage.value = validateLocally(question, activeMode.value)
  errorMessage.value = ''
  if (validationMessage.value) return

  messages.value.push({ role: 'user', content: question })
  inputValue.value = ''
  loading.value = true
  scrollToBottom()

  try {
    var history = messages.value.slice(-8, -1)
    var res = await api.student.askAiTutor({ question: question, history: history, mode: activeMode.value })
    if (res.success && res.data) {
      messages.value.push({ role: 'assistant', content: res.data.content })
      scrollToBottom()
      return
    }
    throw new Error(res.message || 'AI助教暂时不可用')
  } catch (error) {
    errorMessage.value = error && error.message ? error.message : '发送失败，请稍后重试'
    ElMessage.error(errorMessage.value)
  } finally {
    loading.value = false
    scrollToBottom()
  }
}

watch(panelVisible, function (visible) {
  if (visible) scrollToBottom()
})

onMounted(function () {
  handleInput('')
})
</script>

<style scoped>
.ai-tutor-widget {
  position: fixed;
  right: 20px;
  bottom: 28px;
  z-index: 1100;
}

.ai-tutor-fab {
  width: 92px;
  min-height: 92px;
  border: none;
  border-radius: 24px;
  padding: 14px 12px;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  color: #fff;
  box-shadow: 0 14px 30px rgba(64, 158, 255, 0.28);
  cursor: pointer;
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: center;
  justify-content: center;
}

.fab-badge {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
}

.fab-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 12px;
  line-height: 1.35;
}

.ai-tutor-panel {
  width: min(380px, calc(100vw - 24px));
  border-radius: 22px;
  overflow: hidden;
  box-shadow: 0 24px 48px rgba(64, 158, 255, 0.18);
  border: 1px solid rgba(121, 187, 255, 0.28);
  backdrop-filter: blur(10px);
}

.panel-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  padding: 18px 18px 12px;
  background: linear-gradient(135deg, rgba(64, 158, 255, 0.96), rgba(121, 187, 255, 0.92));
  color: #fff;
}

.panel-title {
  font-size: 18px;
  font-weight: 700;
}

.panel-subtitle {
  margin-top: 4px;
  font-size: 12px;
  opacity: 0.92;
  line-height: 1.5;
}

.icon-btn {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.18);
  color: #fff;
  font-size: 20px;
  cursor: pointer;
}

.scope-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding: 12px 18px;
  color: var(--text-regular);
  font-size: 12px;
  border-bottom: 1px solid rgba(220, 223, 230, 0.7);
}

.mode-switch-bar {
  display: flex;
  gap: 10px;
  padding: 12px 18px 0;
}

.mode-chip {
  border: 1px solid rgba(121, 187, 255, 0.45);
  background: #fff;
  color: var(--text-regular);
  border-radius: 999px;
  padding: 8px 14px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.mode-chip.is-active {
  color: #fff;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
  border-color: transparent;
}

.message-list {
  height: 380px;
  overflow-y: auto;
  padding: 16px 18px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: linear-gradient(180deg, rgba(255,255,255,0.95), rgba(230,240,255,0.55));
}

.message-item {
  display: flex;
}

.message-item.user {
  justify-content: flex-end;
}

.message-bubble {
  max-width: 88%;
  padding: 12px 14px;
  border-radius: 16px;
  line-height: 1.65;
  font-size: 14px;
  color: var(--text-primary);
  background: #fff;
  box-shadow: 0 8px 16px rgba(15, 23, 42, 0.06);
}

.message-item.user .message-bubble {
  color: #fff;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
}

.is-loading {
  display: flex;
  align-items: center;
  gap: 6px;
}

.loading-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--primary-color);
  animation: tutor-bounce 1.2s infinite ease-in-out;
}

.loading-dot:nth-child(2) { animation-delay: 0.15s; }
.loading-dot:nth-child(3) { animation-delay: 0.3s; }
.loading-text {
  margin-left: 4px;
  color: var(--text-secondary);
}

.validation-tip,
.error-tip {
  padding: 0 18px 10px;
  font-size: 12px;
}

.validation-tip {
  color: var(--warning-color);
}

.error-tip {
  color: var(--danger-color);
}

.panel-footer {
  padding: 14px 18px 18px;
  background: rgba(255, 255, 255, 0.88);
}

.footer-actions {
  margin-top: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.footer-hint {
  font-size: 12px;
  color: var(--text-secondary);
}

.ai-tutor-panel-fade-enter-active,
.ai-tutor-panel-fade-leave-active {
  transition: all 0.24s ease;
}

.ai-tutor-panel-fade-enter-from,
.ai-tutor-panel-fade-leave-to {
  opacity: 0;
  transform: translateY(12px) scale(0.98);
}

@keyframes tutor-bounce {
  0%, 80%, 100% { transform: scale(0.8); opacity: 0.6; }
  40% { transform: scale(1); opacity: 1; }
}

@media (max-width: 768px) {
  .ai-tutor-widget {
    right: 12px;
    bottom: 18px;
  }

  .ai-tutor-fab {
    width: 76px;
    min-height: 76px;
    border-radius: 20px;
  }

  .fab-text span {
    display: none;
  }

  .message-list {
    height: 50vh;
  }
}
</style>
