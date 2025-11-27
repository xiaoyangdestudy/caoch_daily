const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 获取所有专注记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM focus_sessions WHERE user_id = ?';
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
    const sessions = stmt.all(...params);

    res.json(sessions);
  } catch (error) {
    next(error);
  }
});

// 创建或更新专注记录
router.post('/', (req, res, next) => {
  try {
    const { id, startTime, endTime, targetMinutes, taskName, completed } = req.body;

    if (!id || !startTime || !endTime || targetMinutes === undefined) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const stmt = db.prepare(`
      INSERT INTO focus_sessions
      (id, user_id, start_time, end_time, target_minutes, task_name, completed, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        start_time = excluded.start_time,
        end_time = excluded.end_time,
        target_minutes = excluded.target_minutes,
        task_name = excluded.task_name,
        completed = excluded.completed,
        updated_at = CURRENT_TIMESTAMP
    `);

    stmt.run(
      id,
      req.userId,
      startTime,
      endTime,
      targetMinutes,
      taskName || null,
      completed ? 1 : 0
    );

    res.status(201).json({ success: true, id });
  } catch (error) {
    next(error);
  }
});

// 删除专注记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare('DELETE FROM focus_sessions WHERE id = ? AND user_id = ?');
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Focus session not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
