#!/bin/bash

###############################################################################
# Coach Daily - 自动部署脚本
# 由 GitHub Webhook 触发
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 项目路径
PROJECT_DIR="$HOME/caoch_daily"
SERVER_DIR="$PROJECT_DIR/server"

echo -e "${GREEN}========================================"
echo "Coach Daily - 自动部署"
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================${NC}"

# 切换到项目目录
cd $PROJECT_DIR

echo -e "${YELLOW}[1/5] 拉取最新代码...${NC}"
git fetch origin main
git reset --hard origin/main
echo "✓ 代码更新完成"

echo -e "${YELLOW}[2/5] 切换到服务器目录...${NC}"
cd $SERVER_DIR

echo -e "${YELLOW}[3/5] 安装依赖...${NC}"
# 只在 package.json 变化时安装
npm install --production
echo "✓ 依赖检查完成"

echo -e "${YELLOW}[4/5] 重启服务...${NC}"
pm2 restart coach-daily-api
echo "✓ 服务重启完成"

echo -e "${YELLOW}[5/5] 检查服务状态...${NC}"
sleep 2
pm2 status coach-daily-api

echo ""
echo -e "${GREEN}========================================"
echo "✓ 部署完成！"
echo "========================================${NC}"
echo ""

# 测试健康检查
echo "测试健康检查..."
if curl -f -s http://localhost:3000/health > /dev/null; then
    echo -e "${GREEN}✓ 服务运行正常${NC}"
else
    echo -e "${RED}✗ 服务可能存在问题，请检查日志${NC}"
    pm2 logs coach-daily-api --lines 20 --nostream
fi

echo ""
echo "部署日志已记录到 PM2"
