const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 获取所有阅读记录
router.get('/', (req, res, next) => {
  try {
    const { startDate, endDate, limit = 100 } = req.query;

    let query = 'SELECT * FROM reading_records WHERE user_id = ?';
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

// 获取单个阅读记录
router.get('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare(`
      SELECT * FROM reading_records
      WHERE id = ? AND user_id = ?
    `);
    const record = stmt.get(req.params.id, req.userId);

    if (!record) {
      return res.status(404).json({ error: 'Reading record not found' });
    }

    res.json(record);
  } catch (error) {
    next(error);
  }
});

// 创建或更新阅读记录
router.post('/', (req, res, next) => {
  try {
    const {
      id,
      bookTitle,
      bookAuthor,
      startTime,
      durationMinutes,
      pagesRead,
      notes,
      excerpt,
      aiSummary
    } = req.body;

    if (!id || !bookTitle || !startTime || durationMinutes === undefined) {
      return res.status(400).json({
        error: 'Missing required fields: id, bookTitle, startTime, durationMinutes'
      });
    }

    const stmt = db.prepare(`
      INSERT INTO reading_records
      (id, user_id, book_title, book_author, start_time, duration_minutes, pages_read, notes, excerpt, ai_summary, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
      ON CONFLICT(id) DO UPDATE SET
        book_title = excluded.book_title,
        book_author = excluded.book_author,
        start_time = excluded.start_time,
        duration_minutes = excluded.duration_minutes,
        pages_read = excluded.pages_read,
        notes = excluded.notes,
        excerpt = excluded.excerpt,
        ai_summary = excluded.ai_summary,
        updated_at = CURRENT_TIMESTAMP
    `);

    stmt.run(
      id,
      req.userId,
      bookTitle,
      bookAuthor || null,
      startTime,
      durationMinutes,
      pagesRead || null,
      notes || null,
      excerpt || null,
      aiSummary || null
    );

    res.status(201).json({ success: true, id });
  } catch (error) {
    next(error);
  }
});

// 删除阅读记录
router.delete('/:id', (req, res, next) => {
  try {
    const stmt = db.prepare('DELETE FROM reading_records WHERE id = ? AND user_id = ?');
    const result = stmt.run(req.params.id, req.userId);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'Reading record not found' });
    }

    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
