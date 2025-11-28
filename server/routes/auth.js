const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { users } = require('../utils/db');
const { JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

// 注册
router.post('/register', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // 验证输入
    if (!username || !password) {
      return res.status(400).json({ error: '用户名和密码不能为空' });
    }
    
    if (username.length < 3) {
      return res.status(400).json({ error: '用户名至少3个字符' });
    }
    
    if (password.length < 6) {
      return res.status(400).json({ error: '密码至少6个字符' });
    }
    
    // 检查用户是否已存在
    const existingUser = users.findByUsername(username);
    if (existingUser) {
      return res.status(409).json({ error: '用户名已存在' });
    }
    
    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // 创建用户
    const userId = uuidv4();
    const newUser = {
      id: userId,
      username,
      password: hashedPassword,
      createdAt: new Date().toISOString()
    };
    
    users.create(newUser);
    
    // 生成JWT token
    const token = jwt.sign(
      { userId, username },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    // 返回用户信息（不包含密码）
    res.status(201).json({
      token,
      userId,
      username,
      message: '注册成功'
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: '服务器错误' });
  }
});

// 登录
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    // 验证输入
    if (!username || !password) {
      return res.status(400).json({ error: '用户名和密码不能为空' });
    }
    
    // 查找用户
    const user = users.findByUsername(username);
    if (!user) {
      return res.status(401).json({ error: '用户名或密码错误' });
    }
    
    // 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.status(401).json({ error: '用户名或密码错误' });
    }
    
    // 生成JWT token
    const token = jwt.sign(
      { userId: user.id, username: user.username },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    
    // 返回用户信息
    res.json({
      token,
      userId: user.id,
      username: user.username,
      message: '登录成功'
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: '服务器错误' });
  }
});

module.exports = router;
