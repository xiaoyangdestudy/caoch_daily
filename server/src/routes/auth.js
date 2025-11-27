const express = require('express');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { db } = require('../config/database');
const { generateToken } = require('../utils/jwt');

const router = express.Router();

// 注册
router.post('/register', async (req, res, next) => {
  try {
    const { username, password } = req.body;

    // 验证输入
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    if (username.length < 3) {
      return res.status(400).json({ error: 'Username must be at least 3 characters' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    // 检查用户名是否已存在
    const existingUser = db.prepare('SELECT id FROM users WHERE username = ?').get(username);
    if (existingUser) {
      return res.status(409).json({ error: 'Username already exists' });
    }

    const userId = uuidv4();
    const passwordHash = await bcrypt.hash(password, 10);

    const stmt = db.prepare(`
      INSERT INTO users (id, username, password_hash)
      VALUES (?, ?, ?)
    `);

    stmt.run(userId, username, passwordHash);

    const token = generateToken(userId);

    res.status(201).json({
      token,
      userId,
      username
    });
  } catch (error) {
    next(error);
  }
});

// 登录
router.post('/login', async (req, res, next) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    const stmt = db.prepare('SELECT * FROM users WHERE username = ?');
    const user = stmt.get(username);

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user.id);

    res.json({
      token,
      userId: user.id,
      username: user.username
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
