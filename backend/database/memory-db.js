/**
 * 内存数据库
 * 使用 JavaScript 对象模拟数据库操作
 */

const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');

// 内存存储
const db = {
  users: [],
  students: [],
  teachers: [],
  classes: [],
  papers: [],
  questions: [],
  assignments: [],
  answers: [],
  knowledgePoints: [],
  logs: [],
  settings: {}
};

// 初始化默认数据
function initializeData() {
  // 创建默认管理员
  const adminPassword = bcrypt.hashSync('admin123', 10);
  db.users.push({
    id: 'admin-001',
    username: 'admin',
    password: adminPassword,
    role: 'admin',
    name: '系统管理员',
    email: 'admin@example.com',
    phone: '13800138000',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });

  // 创建默认教师
  const teacherPassword = bcrypt.hashSync('teacher123', 10);
  const teacherId = 'teacher-001';
  db.users.push({
    id: teacherId,
    username: 'teacher',
    password: teacherPassword,
    role: 'teacher',
    name: '张老师',
    email: 'teacher@example.com',
    phone: '13800138001',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });
  db.teachers.push({
    id: teacherId,
    userId: teacherId,
    name: '张老师',
    subject: '数学',
    classes: [],
    createdAt: new Date().toISOString()
  });

  // 创建默认学生
  const studentPassword = bcrypt.hashSync('student123', 10);
  const studentId = 'student-001';
  db.users.push({
    id: studentId,
    username: 'student',
    password: studentPassword,
    role: 'student',
    name: '李明',
    email: 'student@example.com',
    phone: '13800138002',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });
  db.students.push({
    id: studentId,
    userId: studentId,
    name: '李明',
    studentNo: '20240001',
    classId: null,
    gender: 'male',
    createdAt: new Date().toISOString()
  });

  // 创建默认班级
  const classId = 'class-001';
  db.classes.push({
    id: classId,
    name: '七年级一班',
    grade: '七年级',
    teacherId: teacherId,
    students: [studentId],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  });

  // 更新教师和学生的班级信息
  db.teachers[0].classes.push(classId);
  db.students[0].classId = classId;

  // 初始化知识点体系（初中数学）
  const knowledgePoints = [
    { id: 'kp-001', name: '有理数', parentId: null, level: 1, order: 1, description: '正数、负数、有理数的概念' },
    { id: 'kp-002', name: '有理数的加减法', parentId: 'kp-001', level: 2, order: 1, description: '有理数加减法运算' },
    { id: 'kp-003', name: '有理数的乘除法', parentId: 'kp-001', level: 2, order: 2, description: '有理数乘除法运算' },
    { id: 'kp-004', name: '整式的加减', parentId: null, level: 1, order: 2, description: '整式概念及加减运算' },
    { id: 'kp-005', name: '一元一次方程', parentId: null, level: 1, order: 3, description: '一元一次方程的解法' },
    { id: 'kp-006', name: '几何初步', parentId: null, level: 1, order: 4, description: '线段、角的概念' },
    { id: 'kp-007', name: '相交线与平行线', parentId: null, level: 1, order: 5, description: '相交线、平行线的性质' },
    { id: 'kp-008', name: '实数', parentId: null, level: 1, order: 6, description: '无理数、实数的概念' },
    { id: 'kp-009', name: '平面直角坐标系', parentId: null, level: 1, order: 7, description: '坐标系的概念' },
    { id: 'kp-010', name: '二元一次方程组', parentId: null, level: 1, order: 8, description: '二元一次方程组的解法' },
    { id: 'kp-011', name: '不等式与不等式组', parentId: null, level: 1, order: 9, description: '不等式的性质与解法' },
    { id: 'kp-012', name: '数据的收集与整理', parentId: null, level: 1, order: 10, description: '统计初步' }
  ];

  knowledgePoints.forEach(kp => {
    db.knowledgePoints.push({
      ...kp,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    });
  });

  // 系统设置
  db.settings = {
    ocrApiKey: '',
    ocrApiSecret: '',
    llmApiKey: '',
    llmApiEndpoint: '',
    maxUploadSize: 10, // MB
    allowedFileTypes: ['jpg', 'jpeg', 'png', 'pdf'],
    systemName: '智慧教育平台',
    logo: '/logo.png'
  }

  // 初始化模拟答题记录
  const now = new Date().toISOString()
  const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  const twoDaysAgo = new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString()

  // 创建模拟作业
  const assignment1 = {
    id: 'assignment-001',
    title: '第一次测试',
    paperId: 'paper-001',
    classId: classId,
    teacherId: teacherId,
    studentIds: [studentId],
    deadline: now,
    type: 'exam',
    level: 'normal',
    status: 'published',
    createdAt: twoDaysAgo,
    updatedAt: twoDaysAgo
  }
  db.assignments.push(assignment1)

  // 创建模拟答题记录
  const answer1 = {
    id: 'answer-001',
    assignmentId: assignment1.id,
    paperId: 'paper-001',
    classId: classId,
    studentId: studentId,
    submittedAt: yesterday,
    totalScore: 85,
    status: 'graded',
    scores: { 'q1': 20, 'q2': 15, 'q3': 25, 'q4': 25 },
    comments: '整体表现良好',
    gradedBy: teacherId,
    gradedAt: now,
    knowledgePointScores: {
      '有理数': 90,
      '整式的加减': 80,
      '一元一次方程': 85,
      '几何初步': 75,
      '相交线与平行线': 95
    },
    questionResults: [
      { questionId: 'q1', answer: 'A', correct: true, score: 20 },
      { questionId: 'q2', answer: 'B', correct: true, score: 15 },
      { questionId: 'q3', answer: 'C', correct: false, score: 10 },
      { questionId: 'q4', answer: 'D', correct: true, score: 25 }
    ],
    createdAt: yesterday,
    updatedAt: now
  }
  db.answers.push(answer1)

  // 创建第二次模拟作业
  const assignment2 = {
    id: 'assignment-002',
    title: '第二次测试',
    paperId: 'paper-002',
    classId: classId,
    teacherId: teacherId,
    studentIds: [studentId],
    deadline: now,
    type: 'exam',
    level: 'normal',
    status: 'published',
    createdAt: yesterday,
    updatedAt: yesterday
  }
  db.assignments.push(assignment2)

  // 创建第二次模拟答题记录
  const answer2 = {
    id: 'answer-002',
    assignmentId: assignment2.id,
    paperId: 'paper-002',
    classId: classId,
    studentId: studentId,
    submittedAt: now,
    totalScore: 92,
    status: 'graded',
    scores: { 'q1': 25, 'q2': 20, 'q3': 22, 'q4': 25 },
    comments: '进步明显',
    gradedBy: teacherId,
    gradedAt: now,
    knowledgePointScores: {
      '有理数': 95,
      '整式的加减': 85,
      '一元一次方程': 90,
      '几何初步': 85,
      '相交线与平行线': 98
    },
    questionResults: [
      { questionId: 'q1', answer: 'A', correct: true, score: 25 },
      { questionId: 'q2', answer: 'B', correct: true, score: 20 },
      { questionId: 'q3', answer: 'C', correct: true, score: 22 },
      { questionId: 'q4', answer: 'D', correct: true, score: 25 }
    ],
    createdAt: now,
    updatedAt: now
  }
  db.answers.push(answer2)

  console.log('数据库初始化完成');
  console.log('默认账号信息:');
  console.log('管理员 - 用户名: admin, 密码: admin123');
  console.log('教师 - 用户名: teacher, 密码: teacher123');
  console.log('学生 - 用户名: student, 密码: student123');
}

// 数据库操作类
class Database {
  constructor() {
    this.data = db;
  }

  // 通用 CRUD 操作
  create(collection, item) {
    const newItem = {
      ...item,
      id: item.id || uuidv4(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    this.data[collection].push(newItem);
    return newItem;
  }

  findById(collection, id) {
    return this.data[collection].find(item => item.id === id);
  }

  find(collection, query = {}) {
    return this.data[collection].filter(item => {
      return Object.keys(query).every(key => item[key] === query[key]);
    });
  }

  findOne(collection, query = {}) {
    return this.data[collection].find(item => {
      return Object.keys(query).every(key => item[key] === query[key]);
    });
  }

  updateById(collection, id, updates) {
    const index = this.data[collection].findIndex(item => item.id === id);
    if (index === -1) return null;

    this.data[collection][index] = {
      ...this.data[collection][index],
      ...updates,
      updatedAt: new Date().toISOString()
    };
    return this.data[collection][index];
  }

  deleteById(collection, id) {
    const index = this.data[collection].findIndex(item => item.id === id);
    if (index === -1) return false;

    this.data[collection].splice(index, 1);
    return true;
  }

  delete(collection, query = {}) {
    const initialLength = this.data[collection].length;
    this.data[collection] = this.data[collection].filter(item => {
      return !Object.keys(query).every(key => item[key] === query[key]);
    });
    return initialLength - this.data[collection].length;
  }

  count(collection, query = {}) {
    return this.find(collection, query).length;
  }

  // 分页查询
  paginate(collection, query = {}, page = 1, pageSize = 10, sortField = 'createdAt', sortOrder = 'desc') {
    const items = this.find(collection, query);

    // 排序
    items.sort((a, b) => {
      const aVal = a[sortField];
      const bVal = b[sortField];
      if (sortOrder === 'asc') {
        return aVal > bVal ? 1 : -1;
      }
      return aVal < bVal ? 1 : -1;
    });

    const total = items.length;
    const start = (page - 1) * pageSize;
    const end = start + pageSize;

    return {
      data: items.slice(start, end),
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize)
    };
  }

  // 聚合操作
  aggregate(collection, pipeline) {
    // 简化版的聚合实现
    let result = [...this.data[collection]];

    for (const stage of pipeline) {
      if (stage.$match) {
        result = result.filter(item => {
          return Object.keys(stage.$match).every(key => {
            const condition = stage.$match[key];
            if (typeof condition === 'object' && condition.$eq) {
              return item[key] === condition.$eq;
            }
            return item[key] === condition;
          });
        });
      }
      if (stage.$group) {
        // 简化的分组实现
        const groups = {};
        result.forEach(item => {
          const groupKey = stage.$group._id ? item[stage.$group._id.replace('$', '')] : 'all';
          if (!groups[groupKey]) {
            groups[groupKey] = [];
          }
          groups[groupKey].push(item);
        });
        result = Object.entries(groups).map(([key, items]) => ({
          _id: key,
          count: items.length
        }));
      }
    }

    return result;
  }

  // 日志记录
  addLog(userId, action, details) {
    this.data.logs.push({
      id: uuidv4(),
      userId,
      action,
      details,
      timestamp: new Date().toISOString()
    });
  }
}

// 初始化数据
initializeData();

// 导出数据库实例
const database = new Database();
module.exports = database;
