const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth');
const momentsRoutes = require('./routes/moments');
const uploadRoutes = require('./routes/upload');
const workoutsRoutes = require('./routes/workouts');
const mealsRoutes = require('./routes/meals');
const sleepRoutes = require('./routes/sleep');
const focusRoutes = require('./routes/focus');
const reviewsRoutes = require('./routes/reviews');
const readingRoutes = require('./routes/reading');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 静态文件服务 - 提供上传的图片
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 路由
app.use('/api/auth', authRoutes);
app.use('/api/moments', momentsRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/workouts', workoutsRoutes);
app.use('/api/meals', mealsRoutes);
app.use('/api/sleep', sleepRoutes);
app.use('/api/focus', focusRoutes);
app.use('/api/reviews', reviewsRoutes);
app.use('/api/reading', readingRoutes);

// 健康检查
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// 错误处理
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log(`API base URL: http://localhost:${PORT}/api`);
});
