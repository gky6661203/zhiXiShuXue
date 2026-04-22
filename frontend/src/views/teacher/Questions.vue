<template>
  <div class="question-management">
    <div class="page-header">
      <h2>题目管理</h2>
      <p>支持按知识点、难度、题型三维筛选题库</p>
    </div>

    <el-card class="gradient-card filter-card">
      <div class="filter-row">
        <el-input v-model="filters.keyword" placeholder="搜索题干" clearable style="width: 240px" @input="loadQuestions" />
        <el-select v-model="filters.knowledgePoint" clearable placeholder="知识点" style="width: 180px" @change="loadQuestions">
          <el-option v-for="item in knowledgeOptions" :key="item.id" :label="item.name" :value="item.id" />
        </el-select>
        <el-select v-model="filters.difficulty" clearable placeholder="难度" style="width: 140px" @change="loadQuestions">
          <el-option label="1级" :value="1" /><el-option label="2级" :value="2" /><el-option label="3级" :value="3" /><el-option label="4级" :value="4" /><el-option label="5级" :value="5" />
        </el-select>
        <el-select v-model="filters.type" clearable placeholder="题型" style="width: 140px" @change="loadQuestions">
          <el-option label="选择题" value="choice" /><el-option label="填空题" value="fill" /><el-option label="解答题" value="shortAnswer" />
        </el-select>
        <el-button type="primary" @click="showAddDialog">添加题目</el-button>
      </div>
    </el-card>

    <el-card class="gradient-card">
      <el-table :data="questions" style="width: 100%" v-loading="loading">
        <el-table-column prop="knowledgeNodeName" label="知识点" width="150" />
        <el-table-column prop="type" label="题型" width="100"><template #default="scope"><el-tag>{{ getTypeText(scope.row.type) }}</el-tag></template></el-table-column>
        <el-table-column prop="content" label="题目内容" show-overflow-tooltip />
        <el-table-column prop="difficultyLevel" label="难度" width="90"><template #default="scope"><el-tag>{{ scope.row.difficultyLevel || '-' }}</el-tag></template></el-table-column>
        <el-table-column prop="reviewStatus" label="审核状态" width="100" />
        <el-table-column prop="createdAt" label="创建时间" width="180"><template #default="scope">{{ formatDate(scope.row.createdAt) }}</template></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import api from '@/utils/api'
import dayjs from 'dayjs'

const loading = ref(false)
const questions = ref([])
const knowledgeOptions = ref([])
const filters = reactive({ keyword: '', knowledgePoint: '', difficulty: '', type: '' })

onMounted(function () {
  loadKnowledgeOptions()
  loadQuestions()
})

function loadKnowledgeOptions() {
  api.get('/admin/knowledge-points').then(function (res) {
    if (res.success) {
      const flat = []
      function walk(items) {
        ;(items || []).forEach(function (item) {
          flat.push({ id: item.id, name: item.name })
          walk(item.children)
        })
      }
      walk(res.data || [])
      knowledgeOptions.value = flat
    }
  })
}

function loadQuestions() {
  loading.value = true
  api.get('/admin/questions', {
    knowledgePoint: filters.knowledgePoint || undefined,
    difficulty: filters.difficulty || undefined,
    type: filters.type || undefined
  }).then(function (res) {
    if (res.success) {
      let data = res.data.data || []
      if (filters.keyword) data = data.filter(item => String(item.content || '').includes(filters.keyword))
      questions.value = data
    }
  }).finally(function () {
    loading.value = false
  })
}

function showAddDialog() {}
function getTypeText(type) { return type === 'choice' ? '选择题' : type === 'fill' ? '填空题' : '解答题' }
function formatDate(date) { return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-' }
</script>

<style scoped>
.filter-card { margin-bottom: 16px; }
.filter-row { display: flex; gap: 12px; flex-wrap: wrap; align-items: center; }
</style>
