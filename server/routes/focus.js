const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { focus } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有专注记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userFocus = focus.getByUserId(userId);

    res.json({
      focus: userFocus,
      total: userFocus.length
    });
  } catch (error) {
    console.error('Get focus error:', error);
    res.status(500).json({ error: '获取专注记录失败' });
  }
});

// 创建新专注记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const { id, startTime, endTime, durationMinutes, category, task, notes } = req.body;

    // 验证必填字段
    if (!startTime || durationMinutes === undefined) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建专注记录对象
    const newFocus = {
      id: id || uuidv4(),
      userId,
      startTime,
      endTime: endTime || null,
      durationMinutes,
      category: category || 'other',
      task: task || null,
      notes: notes || null,
      createdAt: new Date().toISOString()
    };

    focus.create(newFocus);
    res.status(201).json(newFocus);
  } catch (error) {
    console.error('Create focus error:', error);
    res.status(500).json({ error: '创建专注记录失败' });
  }
});

// 批量创建专注记录（用于同步）
router.post('/batch', (req, res) => {
  try {
    const { userId } = req.user;
    const { focus: focusList } = req.body;

    if (!Array.isArray(focusList)) {
      return res.status(400).json({ error: '数据格式错误' });
    }

    // 为每条记录添加userId
    const focusWithUserId = focusList.map(item => ({
      ...item,
      userId,
      id: item.id || uuidv4(),
      createdAt: item.createdAt || new Date().toISOString()
    }));

    focus.createBatch(focusWithUserId);
    res.status(201).json({
      message: '批量创建成功',
      count: focusWithUserId.length
    });
  } catch (error) {
    console.error('Batch create focus error:', error);
    res.status(500).json({ error: '批量创建失败' });
  }
});

// 更新专注记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const focusRecord = focus.findById(id);

    if (!focusRecord) {
      return res.status(404).json({ error: '专注记录不存在' });
    }

    if (focusRecord.userId !== userId) {
      return res.status(403).json({ error: '无权修改此记录' });
    }

    const updatedFocus = focus.update(id, req.body);
    res.json(updatedFocus);
  } catch (error) {
    console.error('Update focus error:', error);
    res.status(500).json({ error: '更新专注记录失败' });
  }
});

// 删除专注记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const focusRecord = focus.findById(id);

    if (!focusRecord) {
      return res.status(404).json({ error: '专注记录不存在' });
    }

    if (focusRecord.userId !== userId) {
      return res.status(403).json({ error: '无权删除此记录' });
    }

    const success = focus.delete(id);

    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete focus error:', error);
    res.status(500).json({ error: '删除专注记录失败' });
  }
});

module.exports = router;
