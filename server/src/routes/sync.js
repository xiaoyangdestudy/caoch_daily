const express = require('express');
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

const router = express.Router();
router.use(authMiddleware);

// 批量同步数据
router.post('/batch', (req, res, next) => {
  const transaction = db.transaction((syncData, userId) => {
    const { reviews, workouts, meals, sleep, focus } = syncData;
    const result = {
      reviewsCount: 0,
      workoutsCount: 0,
      mealsCount: 0,
      sleepCount: 0,
      focusCount: 0
    };

    // 同步reviews
    if (reviews && reviews.length > 0) {
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

      for (const entry of reviews) {
        stmt.run(
          entry.id,
          userId,
          entry.date,
          entry.mood,
          JSON.stringify(entry.highlights || []),
          JSON.stringify(entry.improvements || []),
          JSON.stringify(entry.tomorrowPlans || []),
          entry.aiSummary || null,
          entry.note || null
        );
      }
      result.reviewsCount = reviews.length;
    }

    // 同步workouts
    if (workouts && workouts.length > 0) {
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

      for (const record of workouts) {
        stmt.run(
          record.id,
          userId,
          record.type,
          record.startTime,
          record.durationMinutes,
          record.distanceKm || 0,
          record.caloriesKcal || 0,
          record.notes || null
        );
      }
      result.workoutsCount = workouts.length;
    }

    // 同步sleep
    if (sleep && sleep.length > 0) {
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

      for (const record of sleep) {
        stmt.run(
          record.id,
          userId,
          record.date,
          record.bedtime,
          record.wakeTime,
          record.note || null,
          record.sleepQuality || null
        );
      }
      result.sleepCount = sleep.length;
    }

    // 同步focus
    if (focus && focus.length > 0) {
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

      for (const record of focus) {
        stmt.run(
          record.id,
          userId,
          record.startTime,
          record.endTime,
          record.targetMinutes,
          record.taskName || null,
          record.completed ? 1 : 0
        );
      }
      result.focusCount = focus.length;
    }

    return result;
  });

  try {
    const result = transaction(req.body, req.userId);
    res.json({ success: true, synced: result });
  } catch (error) {
    next(error);
  }
});

// 获取最后同步时间
router.get('/last-sync', (req, res, next) => {
  try {
    const queries = [
      'SELECT MAX(updated_at) as last_sync FROM review_entries WHERE user_id = ?',
      'SELECT MAX(updated_at) as last_sync FROM workout_records WHERE user_id = ?',
      'SELECT MAX(updated_at) as last_sync FROM meal_records WHERE user_id = ?',
      'SELECT MAX(updated_at) as last_sync FROM sleep_records WHERE user_id = ?',
      'SELECT MAX(updated_at) as last_sync FROM focus_sessions WHERE user_id = ?'
    ];

    const lastSyncTimes = queries.map(query => {
      const stmt = db.prepare(query);
      const result = stmt.get(req.userId);
      return result.last_sync;
    });

    const overallLastSync = lastSyncTimes
      .filter(time => time !== null)
      .sort()
      .reverse()[0];

    res.json({ lastSync: overallLastSync || null });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
