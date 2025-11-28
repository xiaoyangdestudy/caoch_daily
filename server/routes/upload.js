const express = require('express');
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads'));
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
    cb(null, uniqueName);
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('只支持图片文件 (JPEG, PNG, GIF, WebP)'), false);
  }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } });

router.post('/images', authMiddleware, upload.array('images', 9), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: '没有上传文件' });
    }
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    const urls = req.files.map(file => `${baseUrl}/uploads/${file.filename}`);
    res.json({ urls, count: urls.length, message: '上传成功' });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ error: '上传失败' });
  }
});

router.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({ error: '文件大小超过10MB限制' });
    }
    if (error.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({ error: '最多只能上传9张图片' });
    }
  }
  res.status(500).json({ error: error.message || '上传错误' });
});

module.exports = router;