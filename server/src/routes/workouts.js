const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 获取所有运动记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM workout_records WHERE user_id = ?';
    const params = [req.userId];

    if (startDate) {
      query += ' AND start_time >= ?';
      params.push(startDate);
    }

    if (endDate) {
      query += ' AND start_time <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY start_time DESC LIMIT ?';
    params.push(parseInt(limit));

    const stmt = db.prepare(query);
    const records = stmt.all(...params);

    res.json(records);
  } catch (error) {
    next(error);
  }
});

// 获取单个运动记录
router.get('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare(`
      SELECT * FROM workout_records
      WHERE id = ? AND user_id = ?
    `);
    const record = stmt.get(req.params.id, req.userId);

    if (!record) {
      return res.status(404).json({ error: 'Workout record not found' });
    }

    res.json(record);
  } catch (error) {
    next(error);
  }
});

// 创建或更新运动记录
router.post('/', (req, res, next) => {
  try {
    const { id, type, startTime, durationMinutes, distanceKm, caloriesKcal, notes } = req.body;

    if (!id || !type || !startTime || durationMinutes === undefined) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const stmt = db.prepare(`
      INSERT INTO workout_records
      (id, user_id, type, start_time, duration_minutes, distance_km, calories_kcal, notes, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        type = excluded.type,
        start_time = excluded.start_time,
        duration_minutes = excluded.duration_minutes,
        distance_km = excluded.distance_km,
        calories_kcal = excluded.calories_kcal,
        notes = excluded.notes,
        updated_at = CURRENT_TIMESTAMP
    `);

    stmt.run(
      id,
      req.userId,
      type,
      startTime,
      durationMinutes,
      distanceKm || 0,
      caloriesKcal || 0,
      notes || null
    );

    res.status(201).json({ success: true, id });
  } catch (error) {
    next(error);
  }
});

// 删除运动记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare('DELETE FROM workout_records WHERE id = ? AND user_id = ?');
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Workout record not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
