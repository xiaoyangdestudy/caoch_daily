const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 获取所有饮食记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM meal_records WHERE user_id = ?';
    const params = [req.userId];

    if (startDate) {
      query += ' AND timestamp >= ?';
      params.push(startDate);
    }

    if (endDate) {
      query += ' AND timestamp <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY timestamp DESC LIMIT ?';
    params.push(parseInt(limit));

    const stmt = db.prepare(query);
    const meals = stmt.all(...params);

    // 获取每个meal的food items
    const foodStmt = db.prepare('SELECT * FROM food_items WHERE meal_id = ?');
    const mealsWithItems = meals.map(meal => ({
      ...meal,
      items: foodStmt.all(meal.id)
    }));

    res.json(mealsWithItems);
  } catch (error) {
    next(error);
  }
});

// 创建或更新饮食记录
router.post('/', (req, res, next) => {
  const transaction = db.transaction((mealData, userId) => {
    const { id, mealType, timestamp, items, notes } = mealData;

    if (!id || !mealType || !timestamp) {
      throw new Error('Missing required fields: id, mealType, timestamp');
    }

    // 插入或更新meal记录
    const mealStmt = db.prepare(`
      INSERT INTO meal_records (id, user_id, meal_type, timestamp, notes, updated_at)
      VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        meal_type = excluded.meal_type,
        timestamp = excluded.timestamp,
        notes = excluded.notes,
        updated_at = CURRENT_TIMESTAMP
    `);
    mealStmt.run(id, userId, mealType, timestamp, notes || null);

    // 删除旧的food items
    const deleteStmt = db.prepare('DELETE FROM food_items WHERE meal_id = ?');
    deleteStmt.run(id);

    // 插入新的food items
    if (items && items.length > 0) {
      const foodStmt = db.prepare(`
        INSERT INTO food_items (id, meal_id, name, calories, protein, carbs, fat, image_url)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `);

      for (const item of items) {
        foodStmt.run(
          item.id,
          id,
          item.name,
          item.calories,
          item.protein,
          item.carbs,
          item.fat,
          item.imageUrl || null
        );
      }
    }
  });

  try {
    transaction(req.body, req.userId);
    res.status(201).json({ success: true, id: req.body.id });
  } catch (error) {
    next(error);
  }
});

// 删除饮食记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare('DELETE FROM meal_records WHERE id = ? AND user_id = ?');
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Meal record not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
