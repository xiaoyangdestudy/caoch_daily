const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { workouts } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有运动记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userWorkouts = workouts.getByUserId(userId);

    res.json({
      workouts: userWorkouts,
      total: userWorkouts.length
    });
  } catch (error) {
    console.error('Get workouts error:', error);
    res.status(500).json({ error: '获取运动记录失败' });
  }
});

// 创建新运动记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const { id, type, startTime, durationMinutes, distanceKm, caloriesKcal, notes } = req.body;

    // 验证必填字段
    if (!type || !startTime || durationMinutes === undefined) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建运动记录对象
    const newWorkout = {
      id: id || uuidv4(),
      userId,
      type,
      startTime,
      durationMinutes,
      distanceKm: distanceKm || 0,
      caloriesKcal: caloriesKcal || 0,
      notes: notes || null,
      createdAt: new Date().toISOString()
    };

    workouts.create(newWorkout);
    res.status(201).json(newWorkout);
  } catch (error) {
    console.error('Create workout error:', error);
    res.status(500).json({ error: '创建运动记录失败' });
  }
});

// 批量创建运动记录（用于同步）
router.post('/batch', (req, res) => {
  try {
    const { userId } = req.user;
    const { workouts: workoutList } = req.body;

    if (!Array.isArray(workoutList)) {
      return res.status(400).json({ error: '数据格式错误' });
    }

    // 为每条记录添加userId
    const workoutsWithUserId = workoutList.map(workout => ({
      ...workout,
      userId,
      id: workout.id || uuidv4(),
      createdAt: workout.createdAt || new Date().toISOString()
    }));

    workouts.createBatch(workoutsWithUserId);
    res.status(201).json({
      message: '批量创建成功',
      count: workoutsWithUserId.length
    });
  } catch (error) {
    console.error('Batch create workouts error:', error);
    res.status(500).json({ error: '批量创建失败' });
  }
});

// 更新运动记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const workout = workouts.findById(id);

    if (!workout) {
      return res.status(404).json({ error: '运动记录不存在' });
    }

    if (workout.userId !== userId) {
      return res.status(403).json({ error: '无权修改此记录' });
    }

    const updatedWorkout = workouts.update(id, req.body);
    res.json(updatedWorkout);
  } catch (error) {
    console.error('Update workout error:', error);
    res.status(500).json({ error: '更新运动记录失败' });
  }
});

// 删除运动记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const workout = workouts.findById(id);

    if (!workout) {
      return res.status(404).json({ error: '运动记录不存在' });
    }

    if (workout.userId !== userId) {
      return res.status(403).json({ error: '无权删除此记录' });
    }

    const success = workouts.delete(id);

    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete workout error:', error);
    res.status(500).json({ error: '删除运动记录失败' });
  }
});

module.exports = router;
