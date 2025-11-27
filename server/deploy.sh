#!/bin/bash

# Coach Daily Server - 快速部署脚本（用于Linux服务器）
# 使用方法：./deploy.sh

echo "========================================"
echo "Coach Daily - Quick Deploy"
echo "========================================"

# 进入脚本所在目录
cd "$(dirname "$0")"

echo ""
echo "[1/6] Pulling latest code from Git..."
git pull origin main || {
    echo "❌ Git pull failed. Please check your Git configuration."
    exit 1
}

echo ""
echo "[2/6] Installing dependencies..."
npm install --production || {
    echo "❌ npm install failed. Please check your Node.js installation."
    exit 1
}

echo ""
echo "[3/6] Checking environment configuration..."
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found. Copying from .env.production template..."
    cp .env.production .env
    echo "⚠️  Please edit .env file and update JWT_SECRET and other configurations!"
fi

echo ""
echo "[4/6] Restarting service with PM2..."
pm2 restart coach-daily-api || pm2 start ecosystem.config.js

echo ""
echo "[5/6] Checking service status..."
pm2 status

echo ""
echo "[6/6] Viewing recent logs..."
sleep 2
pm2 logs coach-daily-api --lines 20 --nostream

echo ""
echo "========================================"
echo "✓ Deploy completed successfully!"
echo "========================================"
echo "Tips:"
echo "  - View logs: pm2 logs coach-daily-api"
echo "  - Restart: pm2 restart coach-daily-api"
echo "  - Stop: pm2 stop coach-daily-api"
echo "========================================"
