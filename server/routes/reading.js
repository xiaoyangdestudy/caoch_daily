const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { reading } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有阅读记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userReading = reading.getByUserId(userId);

    res.json({
      reading: userReading,
      total: userReading.length
    });
  } catch (error) {
    console.error('Get reading error:', error);
    res.status(500).json({ error: '获取阅读记录失败' });
  }
});

// 获取单个阅读记录
router.get('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const record = reading.findById(req.params.id);

    if (!record) {
      return res.status(404).json({ error: '阅读记录不存在' });
    }

    // 确保只能访问自己的记录
    if (record.userId !== userId) {
      return res.status(403).json({ error: '无权访问该记录' });
    }

    res.json(record);
  } catch (error) {
    console.error('Get reading by id error:', error);
    res.status(500).json({ error: '获取阅读记录失败' });
  }
});

// 创建新阅读记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const {
      id,
      bookTitle,
      bookAuthor,
      startTime,
      durationMinutes,
      pagesRead,
      notes,
      excerpt
    } = req.body;

    // 验证必填字段
    if (!bookTitle || !startTime || durationMinutes === undefined) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建阅读记录对象
    const newReading = {
      id: id || uuidv4(),
      userId,
      bookTitle,
      bookAuthor: bookAuthor || null,
      startTime,
      durationMinutes,
      pagesRead: pagesRead || 0,
      notes: notes || null,
      excerpt: excerpt || null,
      createdAt: new Date().toISOString()
    };

    // 检查是否已存在该ID的记录（用于更新）
    const existing = reading.findById(newReading.id);
    if (existing) {
      // 更新现有记录
      const updated = reading.update(newReading.id, {
        ...newReading,
        updatedAt: new Date().toISOString()
      });
      return res.json({
        success: true,
        reading: updated,
        message: '阅读记录更新成功'
      });
    }

    // 保存新记录
    const saved = reading.create(newReading);

    res.status(201).json({
      success: true,
      reading: saved,
      message: '阅读记录创建成功'
    });
  } catch (error) {
    console.error('Create reading error:', error);
    res.status(500).json({ error: '创建阅读记录失败' });
  }
});

// 更新阅读记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const record = reading.findById(req.params.id);

    if (!record) {
      return res.status(404).json({ error: '阅读记录不存在' });
    }

    // 确保只能更新自己的记录
    if (record.userId !== userId) {
      return res.status(403).json({ error: '无权修改该记录' });
    }

    const updates = {
      ...req.body,
      updatedAt: new Date().toISOString()
    };

    const updated = reading.update(req.params.id, updates);

    res.json({
      success: true,
      reading: updated,
      message: '阅读记录更新成功'
    });
  } catch (error) {
    console.error('Update reading error:', error);
    res.status(500).json({ error: '更新阅读记录失败' });
  }
});

// 删除阅读记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const record = reading.findById(req.params.id);

    if (!record) {
      return res.status(404).json({ error: '阅读记录不存在' });
    }

    // 确保只能删除自己的记录
    if (record.userId !== userId) {
      return res.status(403).json({ error: '无权删除该记录' });
    }

    const deleted = reading.delete(req.params.id);

    if (deleted) {
      res.json({
        success: true,
        message: '阅读记录删除成功'
      });
    } else {
      res.status(500).json({ error: '删除阅读记录失败' });
    }
  } catch (error) {
    console.error('Delete reading error:', error);
    res.status(500).json({ error: '删除阅读记录失败' });
  }
});

module.exports = router;
