const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 获取所有睡眠记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM sleep_records WHERE user_id = ?';
    const params = [req.userId];

    if (startDate) {
      query += ' AND date >= ?';
      params.push(startDate);
    }

    if (endDate) {
      query += ' AND date <= ?';
      params.push(endDate);
    }

    query += ' ORDER BY date DESC LIMIT ?';
    params.push(parseInt(limit));

    const stmt = db.prepare(query);
    const records = stmt.all(...params);

    res.json(records);
  } catch (error) {
    next(error);
  }
});

// 创建或更新睡眠记录
router.post('/', (req, res, next) => {
  try {
    const { id, date, bedtime, wakeTime, note, sleepQuality } = req.body;

    if (!id || !date || !bedtime || !wakeTime) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const stmt = db.prepare(`
      INSERT INTO sleep_records
      (id, user_id, date, bedtime, wake_time, note, sleep_quality, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        bedtime = excluded.bedtime,
        wake_time = excluded.wake_time,
        note = excluded.note,
        sleep_quality = excluded.sleep_quality,
        updated_at = CURRENT_TIMESTAMP
    `);

    stmt.run(
      id,
      req.userId,
      date,
      bedtime,
      wakeTime,
      note || null,
      sleepQuality || null
    );

    res.status(201).json({ success: true, id });
  } catch (error) {
    next(error);
  }
});

// 删除睡眠记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare('DELETE FROM sleep_records WHERE id = ? AND user_id = ?');
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Sleep record not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
