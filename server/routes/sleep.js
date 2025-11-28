const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { sleep } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有睡眠记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userSleep = sleep.getByUserId(userId);

    res.json({
      sleep: userSleep,
      total: userSleep.length
    });
  } catch (error) {
    console.error('Get sleep error:', error);
    res.status(500).json({ error: '获取睡眠记录失败' });
  }
});

// 创建新睡眠记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const { id, date, bedTime, wakeTime, durationHours, quality, notes } = req.body;

    // 验证必填字段
    if (!date || !bedTime || !wakeTime || durationHours === undefined) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建睡眠记录对象
    const newSleep = {
      id: id || uuidv4(),
      userId,
      date,
      bedTime,
      wakeTime,
      durationHours,
      quality: quality || 'medium',
      notes: notes || null,
      createdAt: new Date().toISOString()
    };

    sleep.create(newSleep);
    res.status(201).json(newSleep);
  } catch (error) {
    console.error('Create sleep error:', error);
    res.status(500).json({ error: '创建睡眠记录失败' });
  }
});

// 批量创建睡眠记录（用于同步）
router.post('/batch', (req, res) => {
  try {
    const { userId } = req.user;
    const { sleep: sleepList } = req.body;

    if (!Array.isArray(sleepList)) {
      return res.status(400).json({ error: '数据格式错误' });
    }

    // 为每条记录添加userId
    const sleepWithUserId = sleepList.map(item => ({
      ...item,
      userId,
      id: item.id || uuidv4(),
      createdAt: item.createdAt || new Date().toISOString()
    }));

    sleep.createBatch(sleepWithUserId);
    res.status(201).json({
      message: '批量创建成功',
      count: sleepWithUserId.length
    });
  } catch (error) {
    console.error('Batch create sleep error:', error);
    res.status(500).json({ error: '批量创建失败' });
  }
});

// 更新睡眠记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const sleepRecord = sleep.findById(id);

    if (!sleepRecord) {
      return res.status(404).json({ error: '睡眠记录不存在' });
    }

    if (sleepRecord.userId !== userId) {
      return res.status(403).json({ error: '无权修改此记录' });
    }

    const updatedSleep = sleep.update(id, req.body);
    res.json(updatedSleep);
  } catch (error) {
    console.error('Update sleep error:', error);
    res.status(500).json({ error: '更新睡眠记录失败' });
  }
});

// 删除睡眠记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const sleepRecord = sleep.findById(id);

    if (!sleepRecord) {
      return res.status(404).json({ error: '睡眠记录不存在' });
    }

    if (sleepRecord.userId !== userId) {
      return res.status(403).json({ error: '无权删除此记录' });
    }

    const success = sleep.delete(id);

    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete sleep error:', error);
    res.status(500).json({ error: '删除睡眠记录失败' });
  }
});

module.exports = router;
