#!/bin/bash

###############################################################################
# Coach Daily Server - 云服务器一键部署脚本
# 适用于：Ubuntu 20.04/22.04
# 用途：从零开始部署完整的生产环境
###############################################################################

set -e  # 遇到错误立即退出

echo "========================================"
echo "Coach Daily Server - 自动化部署"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用root用户运行此脚本${NC}"
    echo "使用方法: sudo bash setup-server.sh"
    exit 1
fi

# ==================== 配置变量 ====================
PROJECT_NAME="coach-daily"
GIT_REPO="https://github.com/xiaoyangdestudy/caoch_daily.git"
APP_USER="coach-daily"
APP_DIR="/home/$APP_USER/$PROJECT_NAME"
SERVER_DIR="$APP_DIR/server"

echo -e "${GREEN}[1/10] 更新系统...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}[2/10] 安装基础工具...${NC}"
apt install -y curl wget git build-essential ufw

echo -e "${GREEN}[3/10] 安装Node.js 18 LTS...${NC}"
# 安装Node.js
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

echo "Node.js 版本: $(node -v)"
echo "npm 版本: $(npm -v)"

echo -e "${GREEN}[4/10] 安装PM2...${NC}"
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi
echo "PM2 版本: $(pm2 -v)"

echo -e "${GREEN}[5/10] 安装Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
fi
systemctl enable nginx
echo "Nginx 版本: $(nginx -v 2>&1)"

echo -e "${GREEN}[6/10] 创建应用用户...${NC}"
if ! id "$APP_USER" &>/dev/null; then
    useradd -m -s /bin/bash $APP_USER
    echo "✓ 用户 $APP_USER 已创建"
else
    echo "✓ 用户 $APP_USER 已存在"
fi

echo -e "${GREEN}[7/10] 克隆代码仓库...${NC}"
# 切换到应用用户
su - $APP_USER <<EOF
cd ~
if [ -d "$PROJECT_NAME" ]; then
    echo "目录已存在，拉取最新代码..."
    cd $PROJECT_NAME
    git pull origin main
else
    echo "克隆代码仓库..."
    git clone $GIT_REPO
    cd $PROJECT_NAME
fi

echo "✓ 代码已准备完成"
EOF

echo -e "${GREEN}[8/10] 安装项目依赖...${NC}"
su - $APP_USER <<EOF
cd $SERVER_DIR
npm install --production
echo "✓ 依赖安装完成"
EOF

echo -e "${GREEN}[9/10] 配置环境变量...${NC}"
# 生成JWT密钥
JWT_SECRET=$(openssl rand -base64 32)

# 创建.env文件
su - $APP_USER <<EOF
cd $SERVER_DIR

# 备份旧的.env
if [ -f .env ]; then
    cp .env .env.backup.\$(date +%Y%m%d_%H%M%S)
fi

# 创建新的.env
cat > .env << EOL
# 生产环境配置
PORT=3000
NODE_ENV=production

# JWT配置（自动生成的强密钥）
JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=30d

# 数据库配置
DB_PATH=./data/coach_daily.db

# CORS配置（允许所有来源，生产环境建议修改）
ALLOWED_ORIGINS=*
EOL

echo "✓ 环境变量已配置"
EOF

echo -e "${GREEN}[10/10] 使用PM2启动服务...${NC}"
su - $APP_USER <<EOF
cd $SERVER_DIR

# 停止旧的进程（如果存在）
pm2 delete coach-daily-api 2>/dev/null || true

# 启动服务
pm2 start ecosystem.config.js

# 保存PM2配置
pm2 save

echo "✓ 服务已启动"
EOF

# 设置PM2开机自启（需要root权限）
echo -e "${GREEN}配置PM2开机自启...${NC}"
su - $APP_USER -c "pm2 startup" | tail -n 1 | bash

echo ""
echo -e "${GREEN}========================================"
echo "✓ Node.js服务部署完成！"
echo "========================================${NC}"
echo ""
echo "服务信息："
echo "  - API地址: http://localhost:3000"
echo "  - 健康检查: http://localhost:3000/health"
echo "  - 进程管理: pm2 list"
echo "  - 查看日志: pm2 logs coach-daily-api"
echo ""
echo "下一步："
echo "  1. 配置Nginx反向代理"
echo "  2. 配置防火墙"
echo "  3. （可选）配置SSL证书"
echo ""

# 询问是否继续配置Nginx
read -p "是否现在配置Nginx反向代理？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}配置Nginx...${NC}"

    # 获取服务器IP
    SERVER_IP=$(curl -s ifconfig.me || echo "无法获取")

    # 创建Nginx配置
    cat > /etc/nginx/sites-available/coach-daily <<EOL
server {
    listen 80;
    server_name $SERVER_IP _;

    # 限制请求大小
    client_max_body_size 10M;

    # API代理
    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;

        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 健康检查
    location /health {
        proxy_pass http://localhost:3000/health;
        access_log off;
    }

    # 根路径
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOL

    # 启用配置
    ln -sf /etc/nginx/sites-available/coach-daily /etc/nginx/sites-enabled/

    # 删除默认配置（避免冲突）
    rm -f /etc/nginx/sites-enabled/default

    # 测试配置
    nginx -t

    # 重启Nginx
    systemctl restart nginx

    echo -e "${GREEN}✓ Nginx配置完成${NC}"
fi

# 配置防火墙
echo ""
read -p "是否配置防火墙（UFW）？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}配置防火墙...${NC}"

    # 启用UFW
    ufw --force enable

    # 允许SSH（重要！）
    ufw allow 22/tcp
    ufw allow ssh

    # 允许HTTP/HTTPS
    ufw allow 80/tcp
    ufw allow 443/tcp

    # 允许Nginx
    ufw allow 'Nginx Full'

    # 显示状态
    ufw status

    echo -e "${GREEN}✓ 防火墙配置完成${NC}"
fi

# 最终信息
echo ""
echo -e "${GREEN}========================================"
echo "🎉 部署完成！"
echo "========================================${NC}"
echo ""
echo "访问地址："
if [ "$SERVER_IP" != "无法获取" ]; then
    echo "  - API: http://$SERVER_IP/api"
    echo "  - 健康检查: http://$SERVER_IP/health"
else
    echo "  - API: http://YOUR_SERVER_IP/api"
    echo "  - 健康检查: http://YOUR_SERVER_IP/health"
fi
echo ""
echo "常用命令："
echo "  - 查看服务状态: pm2 status"
echo "  - 查看日志: pm2 logs coach-daily-api"
echo "  - 重启服务: pm2 restart coach-daily-api"
echo "  - 查看Nginx状态: systemctl status nginx"
echo ""
echo "下一步："
echo "  1. 测试API: curl http://YOUR_SERVER_IP/health"
echo "  2. 在Flutter中修改API地址为: http://YOUR_SERVER_IP/api"
echo "  3. 测试登录和数据同步功能"
echo ""
echo "安全提示："
echo "  - 修改SSH端口提高安全性"
echo "  - 定期更新系统: apt update && apt upgrade"
echo "  - 配置数据库自动备份"
echo ""
