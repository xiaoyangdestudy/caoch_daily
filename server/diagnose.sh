#!/bin/bash

echo "=================================="
echo "云服务器诊断脚本"
echo "=================================="

echo -e "\n[1] PM2 进程状态"
pm2 status

echo -e "\n[2] PM2 错误日志 (最近50行)"
pm2 logs coach-daily --err --lines 50 --nostream

echo -e "\n[3] PM2 标准输出日志 (最近50行)"
pm2 logs coach-daily --out --lines 50 --nostream

echo -e "\n[4] 端口占用检查"
echo "检查端口 3000:"
lsof -i :3000 2>/dev/null || netstat -tuln | grep 3000

echo -e "\n[5] 环境变量检查"
if [ -f .env ]; then
    echo ".env 文件存在"
    echo "JWT_SECRET 长度: $(grep JWT_SECRET .env | cut -d'=' -f2 | wc -c)"
    cat .env | grep -v "PASSWORD\|SECRET" | grep -v "^#"
else
    echo "❌ .env 文件不存在！"
fi

echo -e "\n[6] 数据库目录检查"
ls -lah data/ 2>/dev/null || echo "❌ data 目录不存在"

echo -e "\n[7] Node.js 版本"
node --version

echo -e "\n[8] NPM 依赖检查"
if [ -d node_modules ]; then
    echo "✓ node_modules 存在"
else
    echo "❌ node_modules 不存在，需要运行 npm install"
fi

echo -e "\n[9] 服务器文件检查"
if [ -f server.js ]; then
    echo "✓ server.js 存在"
elif [ -f src/index.js ]; then
    echo "✓ src/index.js 存在"
else
    echo "❌ 入口文件不存在"
fi

echo -e "\n[10] ecosystem.config.js 配置"
if [ -f ecosystem.config.js ]; then
    cat ecosystem.config.js
else
    echo "❌ ecosystem.config.js 不存在"
fi

echo -e "\n=================================="
echo "诊断完成"
echo "=================================="
