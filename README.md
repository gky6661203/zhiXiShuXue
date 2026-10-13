# 智析数学

面向初中数学的智能学情分析平台，包含学生端、教师端和管理端。学生答题后，系统按知识点统计掌握度，再结合知识点之间的前置关系，推荐补练题目。

## 功能概览

### 学生端
- **学习工作台**：待完成作业、平均掌握度、薄弱 / 待巩固 / 已掌握知识点分布。
- **知识图谱**：按五大模块（数与式、方程与不等式、函数、几何、统计概率）排列知识点，箭头表示“先学 → 后学”的前置关系，颜色表示掌握状态。点击知识点会列出它的前置知识；前置知识薄弱时提示先补哪一个，并可直接开始练习。
- **薄弱知识点与专项补练计划**：按掌握度从低到高，依次练习最薄弱的 3 个知识点，每做完一组自动进入下一个。
- **错题本**：按知识点、错误类型、掌握状态筛选，查看正确答案和解析，一键重做。
- **学习轨迹**：作业与练习记录、正确率趋势、能力雷达图。

### 教师端
- 班级与学生管理，试卷、题目管理，作业发布，批改中心。
- **班级学情**：平均分、学生层次分布、各知识点掌握度、按题型统计的错题次数，全部来自真实答题记录。
- **学生学情**：成绩趋势、知识点掌握分布、能力雷达、错题列表，可导出学情报告。

### 管理端
- 用户、班级、知识点、题库管理，系统设置，操作日志，数据统计。

### 公式显示
题干、选项、答案和解析都支持 LaTeX 公式：行内公式用 `$...$`，独立公式用 `$$...$$`。教师和管理员录入题目时会实时显示预览。也可以直接用 `x²`、`√2` 这类 Unicode 写法。

## 技术栈

| 部分 | 技术 |
| --- | --- |
| 前端 | Vue 3、Vite 5、Element Plus、Pinia、ECharts 5、KaTeX |
| 后端 | Node.js、Express 4、JWT、WebSocket（`ws`） |
| 数据 | 题库存放在 SQLite（Node 内置 `node:sqlite`，文件为 `backend/database/questions.sqlite`）；其余业务数据目前保存在内存中，**重启后端会恢复为演示数据** |

## 目录结构

```
.
├── frontend/              前端（Vue 3 + Vite）
│   └── src/
│       ├── layouts/       学生 / 教师 / 管理员三套布局
│       ├── views/         各角色页面
│       ├── components/    公共组件（题卡 QuestionCard、公式 MathText）
│       └── utils/         接口封装、知识点元数据、图表配色、公式渲染
├── backend/               后端（Express）
│   ├── routes/            auth / student / teacher / admin / common 接口
│   ├── services/          掌握度计算、推荐、自动批改等
│   ├── database/          内存数据库与题库 SQLite
│   ├── seed/              演示数据
│   └── test/              Jest 测试
└── shared/
    └── knowledge-tree.json   知识点及前置关系（前后端共用）
```

## 本地运行

### 1. 环境要求
- Node.js **22.13 或更高版本**（后端使用内置的 `node:sqlite`）。
- npm 10 及以上。

### 2. 安装依赖
在项目根目录执行，会自动安装 `backend/` 和 `frontend/` 的依赖：

```bash
npm install
```

### 3. 配置环境变量
复制示例文件，可按需配置端口、OCR 和批改服务：

```bash
cp backend/.env.example backend/.env
```

| 变量 | 说明 |
| --- | --- |
| `API_PORT` | 后端端口，默认 `5001` |
| `LLM_*`、`OCR_*` | 批改等功能使用的大模型与 OCR 配置（可选） |

> `backend/.env` 已加入 `.gitignore`，**不要提交到仓库**。OCR 和大模型服务配置为可选项，也可以在管理端“系统设置”里填写。

### 4. 启动

```bash
npm run dev
```

- 前端：http://localhost:5000
- 后端：http://localhost:5001/api（健康检查：`/api/health`）
- WebSocket：`ws://localhost:5001/ws`

后端启动时会自动写入演示数据，不需要单独执行初始化命令。

### 5. 演示账号

| 角色 | 用户名 | 密码 |
| --- | --- | --- |
| 管理员 | `admin` | `admin123` |
| 教师 | `teacher` | `teacher123` |
| 学生 | `student`（李明），另有 `student2` ~ `student10` | `student123` |

登录页上点击账号卡片可以自动填充。

## 常用命令

| 命令 | 作用 |
| --- | --- |
| `npm run dev` | 同时启动前后端（开发模式） |
| `npm run build` | 构建前端到 `frontend/dist` |
| `npm start` | 只启动后端 |
| `cd backend && npm test` | 运行后端测试 |

## 主要接口

所有接口都以 `/api` 开头。

| 接口 | 说明 |
| --- | --- |
| `POST /auth/login` | 登录，返回 JWT |
| `GET /student/weak-points` | 学生各知识点掌握度与状态 |
| `GET /student/practice/:knowledgePointId` | 获取某知识点的练习题 |
| `POST /student/practice/:knowledgePointId/submit` | 提交练习，自动判分并更新掌握度、错题本 |
| `GET /student/wrong-questions` | 错题本 |
| `GET /student/recommendations` | 智能推荐题目 |
| `GET /teacher/analytics/class/:classId` | 班级学情 |
| `GET /common/knowledge-graph` | 知识图谱（分页、学科过滤） |
| `GET /common/wrong-q/:knowledgeId` | 某知识点最近 20 条错题 |
| `GET /common/recommend-q/:knowledgeId` | 某知识点 3–5 道推荐补练题 |

## 掌握度怎么算

- **掌握度** = 该知识点最近 10 次作答的正确率；最近连续 3 题全对且用时没有明显变慢，额外加 10 分；最近连续 2 题都错，扣 10 分（见 `backend/services/masteryEngine.js`）。
- **状态**：80 分及以上为“已掌握”，60–79 为“待巩固”，60 以下为“薄弱”。
- **推荐分** = 0.4 × 与错题的相似度 + 0.3 × 知识点薄弱程度 + 0.3 × 遗忘紧迫度（按 1、2、4、7、15 天的复习间隔估算），3 天内做对过的题不再推荐（见 `backend/services/recommendation.js`）。

