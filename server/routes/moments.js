const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { moments, users } = require('../utils/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// 所有路由都需要认证
router.use(authMiddleware);

// 获取当前用户的所有动态
router.get('/', (req, res) => {
  try {
    const { userId } = req.user;
    
    // 获取用户的所有动态
    const userMoments = moments.getByUserId(userId);
    
    // 返回动态列表
    res.json({
      moments: userMoments,
      total: userMoments.length
    });
  } catch (error) {
    console.error('Get moments error:', error);
    res.status(500).json({ error: '获取动态失败' });
  }
});

// 创建新动态
router.post('/', (req, res) => {
  try {
    const { userId, username } = req.user;
    const { content, imageUrls, location, tags } = req.body;
    
    // 验证输入
    if (!content || content.trim().length === 0) {
      return res.status(400).json({ error: '动态内容不能为空' });
    }
    
    // 创建动态对象
    const newMoment = {
      id: uuidv4(),
      userId,
      username,
      userAvatar: null,
      content: content.trim(),
      createdAt: new Date().toISOString(),
      imageUrls: imageUrls || [],
      likes: 0,
      commentsCount: 0,
      isLiked: false,
      location: location || null,
      tags: tags || []
    };
    
    // 保存到数据库
    moments.create(newMoment);
    
    res.status(201).json(newMoment);
  } catch (error) {
    console.error('Create moment error:', error);
    res.status(500).json({ error: '创建动态失败' });
  }
});

// 删除动态
router.delete('/:id', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;
    
    // 查找动态
    const moment = moments.findById(id);
    
    if (!moment) {
      return res.status(404).json({ error: '动态不存在' });
    }
    
    // 检查权限 - 只能删除自己的动态
    if (moment.userId !== userId) {
      return res.status(403).json({ error: '无权删除此动态' });
    }
    
    // 删除动态
    const success = moments.delete(id);
    
    if (success) {
      res.json({ message: '删除成功' });
    } else {
      res.status(500).json({ error: '删除失败' });
    }
  } catch (error) {
    console.error('Delete moment error:', error);
    res.status(500).json({ error: '删除动态失败' });
  }
});

// 点赞/取消点赞动态
router.put('/:id/like', (req, res) => {
  try {
    const { userId } = req.user;
    const { id } = req.params;
    
    // 查找动态
    const moment = moments.findById(id);
    
    if (!moment) {
      return res.status(404).json({ error: '动态不存在' });
    }
    
    // 检查权限 - 只能给自己的动态点赞（简化版）
    if (moment.userId !== userId) {
      return res.status(403).json({ error: '无权操作此动态' });
    }
    
    // 切换点赞状态
    const updatedMoment = moments.update(id, {
      isLiked: !moment.isLiked,
      likes: moment.isLiked ? moment.likes - 1 : moment.likes + 1
    });
    
    if (updatedMoment) {
      res.json(updatedMoment);
    } else {
      res.status(500).json({ error: '点赞失败' });
    }
  } catch (error) {
    console.error('Like moment error:', error);
    res.status(500).json({ error: '点赞操作失败' });
  }
});

module.exports = router;
