const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

const authMiddleware = (req, res, next) => {
  try {
    // 从请求头获取token
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: '未提供认证令牌' });
    }
    
    const token = authHeader.substring(7); // 移除 'Bearer ' 前缀
    
    // 验证token
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // 将用户信息添加到请求对象
    req.user = {
      userId: decoded.userId,
      username: decoded.username
    };
    
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: '无效的认证令牌' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: '认证令牌已过期' });
    }
    return res.status(500).json({ error: '服务器错误' });
  }
};

module.exports = { authMiddleware, JWT_SECRET };
