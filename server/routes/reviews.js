const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { reviews } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有复盘记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userReviews = reviews.getByUserId(userId);

    res.json({
      reviews: userReviews,
      total: userReviews.length
    });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({ error: '获取复盘记录失败' });
  }
});

// 创建新复盘记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const { id, date, mood, achievements, challenges, improvements, gratitude, tomorrow, notes } = req.body;

    // 验证必填字段
    if (!date) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建复盘记录对象
    const newReview = {
      id: id || uuidv4(),
      userId,
      date,
      mood: mood || null,
      achievements: achievements || [],
      challenges: challenges || [],
      improvements: improvements || [],
      gratitude: gratitude || [],
      tomorrow: tomorrow || [],
      notes: notes || null,
      createdAt: new Date().toISOString()
    };

    reviews.create(newReview);
    res.status(201).json(newReview);
  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({ error: '创建复盘记录失败' });
  }
});

// 批量创建复盘记录（用于同步）
router.post('/batch', (req, res) => {
  try {
    const { userId } = req.user;
    const { reviews: reviewList } = req.body;

    if (!Array.isArray(reviewList)) {
      return res.status(400).json({ error: '数据格式错误' });
    }

    // 为每条记录添加userId
    const reviewsWithUserId = reviewList.map(item => ({
      ...item,
      userId,
      id: item.id || uuidv4(),
      createdAt: item.createdAt || new Date().toISOString()
    }));

    reviews.createBatch(reviewsWithUserId);
    res.status(201).json({
      message: '批量创建成功',
      count: reviewsWithUserId.length
    });
  } catch (error) {
    console.error('Batch create reviews error:', error);
    res.status(500).json({ error: '批量创建失败' });
  }
});

// 更新复盘记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const review = reviews.findById(id);

    if (!review) {
      return res.status(404).json({ error: '复盘记录不存在' });
    }

    if (review.userId !== userId) {
      return res.status(403).json({ error: '无权修改此记录' });
    }

    const updatedReview = reviews.update(id, req.body);
    res.json(updatedReview);
  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json({ error: '更新复盘记录失败' });
  }
});

// 删除复盘记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const review = reviews.findById(id);

    if (!review) {
      return res.status(404).json({ error: '复盘记录不存在' });
    }

    if (review.userId !== userId) {
      return res.status(403).json({ error: '无权删除此记录' });
    }

    const success = reviews.delete(id);

    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json({ error: '删除复盘记录失败' });
  }
});

module.exports = router;
