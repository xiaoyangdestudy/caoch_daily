const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { meals } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有饮食记录
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    const userMeals = meals.getByUserId(userId);

    res.json({
      meals: userMeals,
      total: userMeals.length
    });
  } catch (error) {
    console.error('Get meals error:', error);
    res.status(500).json({ error: '获取饮食记录失败' });
  }
});

// 创建新饮食记录
router.post('/', (req, res) => {
  try {
    const { userId } = req.user;
    const { id, mealType, timestamp, items, notes } = req.body;

    // 验证必填字段
    if (!mealType || !timestamp) {
      return res.status(400).json({ error: '缺少必填字段' });
    }

    // 创建饮食记录对象
    const newMeal = {
      id: id || uuidv4(),
      userId,
      mealType,
      timestamp,
      items: items || [],
      notes: notes || null,
      createdAt: new Date().toISOString()
    };

    meals.create(newMeal);
    res.status(201).json(newMeal);
  } catch (error) {
    console.error('Create meal error:', error);
    res.status(500).json({ error: '创建饮食记录失败' });
  }
});

// 批量创建饮食记录（用于同步）
router.post('/batch', (req, res) => {
  try {
    const { userId } = req.user;
    const { meals: mealList } = req.body;

    if (!Array.isArray(mealList)) {
      return res.status(400).json({ error: '数据格式错误' });
    }

    // 为每条记录添加userId
    const mealsWithUserId = mealList.map(meal => ({
      ...meal,
      userId,
      id: meal.id || uuidv4(),
      createdAt: meal.createdAt || new Date().toISOString()
    }));

    meals.createBatch(mealsWithUserId);
    res.status(201).json({
      message: '批量创建成功',
      count: mealsWithUserId.length
    });
  } catch (error) {
    console.error('Batch create meals error:', error);
    res.status(500).json({ error: '批量创建失败' });
  }
});

// 更新饮食记录
router.put('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const meal = meals.findById(id);

    if (!meal) {
      return res.status(404).json({ error: '饮食记录不存在' });
    }

    if (meal.userId !== userId) {
      return res.status(403).json({ error: '无权修改此记录' });
    }

    const updatedMeal = meals.update(id, req.body);
    res.json(updatedMeal);
  } catch (error) {
    console.error('Update meal error:', error);
    res.status(500).json({ error: '更新饮食记录失败' });
  }
});

// 删除饮食记录
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;

    const meal = meals.findById(id);

    if (!meal) {
      return res.status(404).json({ error: '饮食记录不存在' });
    }

    if (meal.userId !== userId) {
      return res.status(403).json({ error: '无权删除此记录' });
    }

    const success = meals.delete(id);

    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete meal error:', error);
    res.status(500).json({ error: '删除饮食记录失败' });
  }
});

module.exports = router;
