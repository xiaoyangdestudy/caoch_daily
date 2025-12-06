-- 数据库迁移脚本 - 添加用户资料字段
-- 使用方法: sqlite3 data/coach_daily.db < migrate_profile_fields.sql

-- 检查并添加 nickname 字段
ALTER TABLE users ADD COLUMN nickname TEXT;

-- 检查并添加 avatar 字段
ALTER TABLE users ADD COLUMN avatar TEXT;

-- 检查并添加 signature 字段
ALTER TABLE users ADD COLUMN signature TEXT;

-- 检查并添加 email 字段
ALTER TABLE users ADD COLUMN email TEXT;

-- 显示迁移后的表结构
.schema users

-- 显示用户数据
SELECT
  username,
  CASE
    WHEN nickname IS NULL THEN 'NULL'
    WHEN nickname = '' THEN 'EMPTY'
    ELSE nickname
  END as nickname_status,
  CASE
    WHEN avatar IS NULL THEN 'NULL'
    WHEN avatar = '' THEN 'EMPTY'
    ELSE 'HAS_DATA(' || LENGTH(avatar) || ' chars)'
  END as avatar_status
FROM users
LIMIT 5;
