<template>
  <div class="assignment-management">
    <div class="page-header">
      <h2>作业发布</h2>
      <p>发布和管理作业任务</p>
    </div>
    
    <el-card class="gradient-card">
      <template #header>
        <div class="card-header">
          <span>作业列表</span>
          <el-button type="primary" @click="showAddDialog">
            <el-icon><Plus /></el-icon>
            发布作业
          </el-button>
        </div>
      </template>
      
      <el-table :data="assignments" style="width: 100%" v-loading="loading">
        <el-table-column prop="title" label="作业名称" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="scope">
            <el-tag>{{ scope.row.type === 'homework' ? '作业' : '考试' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="level" label="层次" width="100">
          <template #default="scope">
            <el-tag :type="getLevelType(scope.row.level)">
              {{ getLevelText(scope.row.level) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="deadline" label="截止时间" width="180">
          <template #default="scope">
            {{ scope.row.deadline ? formatDate(scope.row.deadline) : '未设置' }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag type="success">{{ scope.row.status === 'published' ? '已发布' : '草稿' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="scope">
            <el-button type="primary" link>查看</el-button>
            <el-button type="danger" link>删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 发布作业对话框 -->
    <el-dialog v-model="dialogVisible" title="发布作业" width="600px">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="作业名称" prop="title">
          <el-input v-model="form.title" placeholder="请输入作业名称" />
        </el-form-item>
        <el-form-item label="选择试卷" prop="paperId">
          <el-select v-model="form.paperId" placeholder="请选择试卷">
            <el-option v-for="p in papers" :key="p.id" :label="p.title" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="选择班级" prop="classId">
          <el-select v-model="form.classId" placeholder="请选择班级">
            <el-option v-for="c in classes" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="作业层次" prop="level">
          <el-radio-group v-model="form.level">
            <el-radio label="weak">薄弱层</el-radio>
            <el-radio label="normal">普通层</el-radio>
            <el-radio label="strong">优秀层</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="截止时间" prop="deadline">
          <el-date-picker v-model="form.deadline" type="datetime" placeholder="选择截止时间" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import api from '@/utils/api'
import dayjs from 'dayjs'

var loading = ref(false)
var dialogVisible = ref(false)
var formRef = ref(null)
var assignments = ref([])
var papers = ref([])
var classes = ref([])

var form = reactive({
  title: '',
  paperId: '',
  classId: '',
  level: 'normal',
  deadline: ''
})

var rules = {
  title: [{ required: true, message: '请输入作业名称', trigger: 'blur' }],
  paperId: [{ required: true, message: '请选择试卷', trigger: 'change' }],
  classId: [{ required: true, message: '请选择班级', trigger: 'change' }]
}

onMounted(function() {
  loadData()
})

function loadData() {
  loading.value = true
  
  Promise.all([
    api.get('/teacher/assignments'),
    api.get('/teacher/papers', { pageSize: 100 }),
    api.get('/teacher/classes')
  ])
  .then(function(results) {
    var assignmentRes = results[0]
    var paperRes = results[1]
    var classRes = results[2]
    
    if (assignmentRes.success) assignments.value = assignmentRes.data
    if (paperRes.success) papers.value = paperRes.data.data
    if (classRes.success) classes.value = classRes.data
  })
  .catch(function(error) {
    console.error('加载数据失败:', error)
  })
  .finally(function() {
    loading.value = false
  })
}

function showAddDialog() {
  form.title = ''
  form.paperId = ''
  form.classId = ''
  form.level = 'normal'
  form.deadline = ''
  dialogVisible.value = true
}

function submitForm() {
  formRef.value.validate()
    .then(function() {
      api.post('/teacher/assignments', form)
        .then(function(res) {
          if (res.success) {
            ElMessage.success('发布成功')
            dialogVisible.value = false
            loadData()
          }
        })
        .catch(function(error) {
          ElMessage.error('发布失败')
        })
    })
    .catch(function() {})
}

function getLevelType(level) {
  if (level === 'weak') return 'danger'
  if (level === 'normal') return 'warning'
  if (level === 'strong') return 'success'
  return 'info'
}

function getLevelText(level) {
  if (level === 'weak') return '薄弱层'
  if (level === 'normal') return '普通层'
  if (level === 'strong') return '优秀层'
  return '未知'
}

function formatDate(date) {
  return date ? dayjs(date).format('YYYY-MM-DD HH:mm') : '-'
}
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
