# Coach Daily Server

## 快速开始

### 本地开发

1. 安装依赖
```bash
npm install
```

2. 启动开发服务器
```bash
npm run dev
```

3. 测试API
```bash
# 健康检查
curl http://111.230.25.80:3000/health

# 注册用户
curl -X POST http://111.230.25.80:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

### 生产部署

详见根目录的《服务器部署配置文档.md》和《开发部署工作流.md》

## 项目结构

```
server/
├── src/
│   ├── config/          # 配置文件
│   │   └── database.js  # 数据库配置
│   ├── middleware/      # 中间件
│   │   ├── auth.js      # JWT认证
│   │   └── errorHandler.js
│   ├── routes/          # API路由
│   │   ├── auth.js      # 认证API
│   │   ├── reviews.js   # 每日回顾
│   │   ├── workouts.js  # 运动记录
│   │   ├── meals.js     # 饮食记录
│   │   ├── sleep.js     # 睡眠记录
│   │   ├── focus.js     # 专注工作
│   │   └── sync.js      # 数据同步
│   ├── utils/           # 工具函数
│   │   └── jwt.js       # JWT工具
│   └── index.js         # 主入口
├── data/                # SQLite数据库
├── logs/                # 日志文件
├── package.json
├── .env                 # 环境变量（开发）
├── .env.production      # 环境变量模板（生产）
└── ecosystem.config.js  # PM2配置
```

## API端点

### 认证
- `POST /api/auth/register` - 注册
- `POST /api/auth/login` - 登录

### 每日回顾
- `GET /api/reviews` - 获取所有回顾
- `POST /api/reviews` - 创建/更新回顾
- `DELETE /api/reviews/:id` - 删除回顾

### 运动记录
- `GET /api/workouts` - 获取所有运动记录
- `POST /api/workouts` - 创建/更新运动记录
- `DELETE /api/workouts/:id` - 删除运动记录

### 饮食记录
- `GET /api/meals` - 获取所有饮食记录
- `POST /api/meals` - 创建/更新饮食记录
- `DELETE /api/meals/:id` - 删除饮食记录

### 睡眠记录
- `GET /api/sleep` - 获取所有睡眠记录
- `POST /api/sleep` - 创建/更新睡眠记录
- `DELETE /api/sleep/:id` - 删除睡眠记录

### 专注工作
- `GET /api/focus` - 获取所有专注记录
- `POST /api/focus` - 创建/更新专注记录
- `DELETE /api/focus/:id` - 删除专注记录

### 数据同步
- `POST /api/sync/batch` - 批量同步数据
- `GET /api/sync/last-sync` - 获取最后同步时间

## 环境变量

```bash
# 服务器配置
PORT=3000
NODE_ENV=development

# JWT配置
JWT_SECRET=your_secret_key_min_32_chars
JWT_EXPIRES_IN=30d

# 数据库
DB_PATH=./data/coach_daily.db

# CORS
ALLOWED_ORIGINS=*
```

## 技术栈

- **Node.js** - 运行环境
- **Express** - Web框架
- **SQLite** - 数据库
- **JWT** - 身份认证
- **bcryptjs** - 密码加密

## 开发命令

```bash
npm run dev      # 开发模式（自动重启）
npm start        # 生产模式
npm test         # 测试运行
```

## 许可证

MIT
