const express = require('express');
const router = express.Router();
const { db } = require('../config/database');
const authMiddleware = require('../middleware/auth');

/**
 * GET /api/profile
 * 获取当前用户的个人资料
 */
router.get('/', authMiddleware, (req, res) => {
  try {
    const userId = req.userId;

    const user = db.prepare(`
      SELECT id, username, nickname, avatar, signature, email, created_at
      FROM users
      WHERE id = ?
    `).get(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
});

/**
 * PUT /api/profile
 * 更新当前用户的个人资料
 * Body: { nickname?, avatar?, signature?, email? }
 */
router.put('/', authMiddleware, (req, res) => {
  try {
    const userId = req.userId;
    const { nickname, avatar, signature, email } = req.body;

    // 验证输入
    if (nickname !== undefined && typeof nickname !== 'string') {
      return res.status(400).json({ error: 'Invalid nickname' });
    }
    if (avatar !== undefined && typeof avatar !== 'string') {
      return res.status(400).json({ error: 'Invalid avatar' });
    }
    if (signature !== undefined && typeof signature !== 'string') {
      return res.status(400).json({ error: 'Invalid signature' });
    }
    if (email !== undefined && typeof email !== 'string') {
      return res.status(400).json({ error: 'Invalid email' });
    }

    // 构建更新字段
    const updates = [];
    const params = [];

    if (nickname !== undefined) {
      updates.push('nickname = ?');
      params.push(nickname);
    }
    if (avatar !== undefined) {
      updates.push('avatar = ?');
      params.push(avatar);
    }
    if (signature !== undefined) {
      updates.push('signature = ?');
      params.push(signature);
    }
    if (email !== undefined) {
      updates.push('email = ?');
      params.push(email);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    // 添加 updated_at
    updates.push('updated_at = CURRENT_TIMESTAMP');
    params.push(userId);

    // 执行更新
    const sql = `UPDATE users SET ${updates.join(', ')} WHERE id = ?`;
    const result = db.prepare(sql).run(...params);

    if (result.changes === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // 返回更新后的用户信息
    const updatedUser = db.prepare(`
      SELECT id, username, nickname, avatar, signature, email, created_at
      FROM users
      WHERE id = ?
    `).get(userId);

    res.json(updatedUser);
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
