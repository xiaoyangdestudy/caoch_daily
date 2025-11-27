const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取所有回顾记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM review_entries WHERE user_id = ?';
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
    const entries = stmt.all(...params);

    // 转换JSON字段
    const formatted = entries.map(entry => ({
      ...entry,
      highlights: entry.highlights ? JSON.parse(entry.highlights) : [],
      improvements: entry.improvements ? JSON.parse(entry.improvements) : [],
      tomorrowPlans: entry.tomorrow_plans ? JSON.parse(entry.tomorrow_plans) : []
    }));

    res.json(formatted);
  } catch (error) {
    next(error);
  }
});

// 获取单个回顾记录
router.get('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare(`
      SELECT * FROM review_entries
      WHERE id = ? AND user_id = ?
    `);
    const entry = stmt.get(req.params.id, req.userId);

    if (!entry) {
      return res.status(404).json({ error: 'Review entry not found' });
    }

    const formatted = {
      ...entry,
      highlights: entry.highlights ? JSON.parse(entry.highlights) : [],
      improvements: entry.improvements ? JSON.parse(entry.improvements) : [],
      tomorrowPlans: entry.tomorrow_plans ? JSON.parse(entry.tomorrow_plans) : []
    };

    res.json(formatted);
  } catch (error) {
    next(error);
  }
});

// 创建或更新回顾记录
router.post('/', (req, res, next) => {
  try {
    const { id, date, mood, highlights, improvements, tomorrowPlans, aiSummary, note } = req.body;

    if (!id || !date || !mood) {
      return res.status(400).json({ error: 'Missing required fields: id, date, mood' });
    }

    const stmt = db.prepare(`
      INSERT INTO review_entries
      (id, user_id, date, mood, highlights, improvements, tomorrow_plans, ai_summary, note, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        mood = excluded.mood,
        highlights = excluded.highlights,
        improvements = excluded.improvements,
        tomorrow_plans = excluded.tomorrow_plans,
        ai_summary = excluded.ai_summary,
        note = excluded.note,
        updated_at = CURRENT_TIMESTAMP
    `);

    stmt.run(
      id,
      req.userId,
      date,
      mood,
      JSON.stringify(highlights || []),
      JSON.stringify(improvements || []),
      JSON.stringify(tomorrowPlans || []),
      aiSummary || null,
      note || null
    );

    res.status(201).json({ success: true, id });
  } catch (error) {
    next(error);
  }
});

// 删除回顾记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare(`
      DELETE FROM review_entries
      WHERE id = ? AND user_id = ?
    `);
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Review entry not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
