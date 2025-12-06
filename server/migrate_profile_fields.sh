#!/bin/bash

# 数据库迁移脚本 - 添加用户资料字段
# 用于给已存在的 users 表添加 nickname, avatar, signature, email 字段

set -e

DB_PATH="${1:-./data/coach_daily.db}"

echo "正在迁移数据库: $DB_PATH"

if [ ! -f "$DB_PATH" ]; then
    echo "❌ 数据库文件不存在: $DB_PATH"
    exit 1
fi

# 备份数据库
BACKUP_PATH="${DB_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
echo "创建备份: $BACKUP_PATH"
cp "$DB_PATH" "$BACKUP_PATH"

# 执行迁移
echo "开始迁移..."

sqlite3 "$DB_PATH" <<EOF
-- 添加缺失的字段（如果字段已存在会报错，但不影响）
ALTER TABLE users ADD COLUMN nickname TEXT;
ALTER TABLE users ADD COLUMN avatar TEXT;
ALTER TABLE users ADD COLUMN signature TEXT;
ALTER TABLE users ADD COLUMN email TEXT;
EOF

# 忽略错误（字段可能已存在）
if [ $? -eq 0 ]; then
    echo "✅ 迁移完成！"
else
    echo "⚠️  迁移可能部分成功（字段已存在会报错，这是正常的）"
fi

# 显示表结构
echo ""
echo "当前表结构:"
sqlite3 "$DB_PATH" ".schema users"

echo ""
echo "✅ 完成！备份文件: $BACKUP_PATH"
