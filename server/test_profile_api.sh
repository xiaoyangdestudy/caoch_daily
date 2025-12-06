#!/bin/bash

# 测试用户资料 API - 诊断头像问题
# 使用方法: ./test_profile_api.sh <your_token>

set -e

if [ -z "$1" ]; then
    echo "用法: $0 <JWT_TOKEN>"
    echo "请先登录获取 token"
    exit 1
fi

TOKEN="$1"
BASE_URL="${BASE_URL:-http://111.230.25.80:3000}"

echo "========================================="
echo "测试用户资料 API"
echo "========================================="
echo ""

echo "1. 检查数据库表结构..."
echo "----------------------------------------"
sqlite3 data/coach_daily.db ".schema users" 2>/dev/null || {
    echo "❌ 无法连接到数据库"
    exit 1
}
echo ""

echo "2. 获取当前用户资料..."
echo "----------------------------------------"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer $TOKEN" \
    "$BASE_URL/api/profile")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ API 调用成功"
    echo "返回数据:"
    echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"

    # 检查头像字段
    HAS_AVATAR=$(echo "$BODY" | jq -r '.avatar // "null"')
    if [ "$HAS_AVATAR" = "null" ] || [ -z "$HAS_AVATAR" ]; then
        echo ""
        echo "⚠️  警告：avatar 字段为空，请上传头像"
    else
        AVATAR_LENGTH=${#HAS_AVATAR}
        echo ""
        echo "✅ 头像数据存在，长度: $AVATAR_LENGTH 字符"
    fi
else
    echo "❌ API 调用失败，HTTP $HTTP_CODE"
    echo "$BODY"
    exit 1
fi

echo ""
echo "3. 检查数据库中的实际数据..."
echo "----------------------------------------"
sqlite3 data/coach_daily.db <<EOF
SELECT
    username,
    nickname,
    CASE
        WHEN avatar IS NULL THEN '空'
        WHEN avatar = '' THEN '空字符串'
        ELSE '有数据 (' || LENGTH(avatar) || ' 字符)'
    END as avatar_status,
    email
FROM users
LIMIT 5;
EOF

echo ""
echo "========================================="
echo "诊断完成！"
echo "========================================="
