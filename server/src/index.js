require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { initDatabase } = require('./config/database');
const errorHandler = require('./middleware/errorHandler');

// 导入路由
const authRoutes = require('./routes/auth');
const reviewRoutes = require('./routes/reviews');
const workoutRoutes = require('./routes/workouts');
const mealRoutes = require('./routes/meals');
const sleepRoutes = require('./routes/sleep');
const focusRoutes = require('./routes/focus');
const syncRoutes = require('./routes/sync');

const app = express();
const PORT = process.env.PORT || 3000;

// 初始化数据库
console.log('======================================');
console.log('Coach Daily API Server');
console.log('======================================');
initDatabase();

// 安全中间件
app.use(helmet());

// CORS配置
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['*'];
app.use(cors({
  origin: (origin, callback) => {
    // 允许没有origin的请求（如移动应用、Postman等）
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes('*') || allowedOrigins.some(allowed => {
      if (allowed.includes('*')) {
        const pattern = new RegExp(allowed.replace(/\*/g, '.*'));
        return pattern.test(origin);
      }
      return allowed === origin;
    })) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

// 请求限流（防止暴力破解）
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15分钟
  max: 10, // 限制10次登录尝试
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

const generalLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1分钟
  max: 60, // 限制60个请求
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
});

// Body解析
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// 请求日志（开发环境）
if (process.env.NODE_ENV === 'development') {
  app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
    next();
  });
}

// 健康检查
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: '1.0.0'
  });
});

// API根路径
app.get('/', (req, res) => {
  res.json({
    service: 'Coach Daily API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      reviews: '/api/reviews',
      workouts: '/api/workouts',
      meals: '/api/meals',
      sleep: '/api/sleep',
      focus: '/api/focus',
      sync: '/api/sync'
    }
  });
});

// API路由
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/reviews', generalLimiter, reviewRoutes);
app.use('/api/workouts', generalLimiter, workoutRoutes);
app.use('/api/meals', generalLimiter, mealRoutes);
app.use('/api/sleep', generalLimiter, sleepRoutes);
app.use('/api/focus', generalLimiter, focusRoutes);
app.use('/api/sync', generalLimiter, syncRoutes);

// 404处理
app.use((req, res) => {
  res.status(404).json({
    error: 'Not found',
    path: req.path
  });
});

// 错误处理
app.use(errorHandler);

// 启动服务器
app.listen(PORT, () => {
  console.log('======================================');
  console.log(`✓ Server running on port ${PORT}`);
  console.log(`✓ Environment: ${process.env.NODE_ENV}`);
  console.log(`✓ API Base URL: http://localhost:${PORT}/api`);
  console.log('======================================');
  console.log('Available endpoints:');
  console.log('  POST   /api/auth/register');
  console.log('  POST   /api/auth/login');
  console.log('  GET    /api/reviews');
  console.log('  POST   /api/reviews');
  console.log('  GET    /api/workouts');
  console.log('  POST   /api/workouts');
  console.log('  GET    /api/meals');
  console.log('  POST   /api/meals');
  console.log('  GET    /api/sleep');
  console.log('  POST   /api/sleep');
  console.log('  GET    /api/focus');
  console.log('  POST   /api/focus');
  console.log('  POST   /api/sync/batch');
  console.log('  GET    /api/sync/last-sync');
  console.log('======================================');
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});
