# GitHub Webhook 自动部署配置指南

本文档说明如何配置 GitHub Webhook 实现自动部署功能。

## 工作原理

1. 你在本地修改代码并推送到 GitHub
2. GitHub 自动向你的服务器发送 webhook 请求
3. 服务器接收请求后自动拉取最新代码并重启服务

## 服务器端配置步骤

### 1. 设置 Webhook 密钥

首先生成一个随机密钥：

```bash
# SSH 到服务器
ssh root@111.230.25.80

# 切换到应用用户
sudo su - coach-daily

# 生成随机密钥
openssl rand -hex 32
```

复制生成的密钥，然后将其添加到环境变量：

```bash
# 编辑 .env 文件
cd ~/coach-daily/server
nano .env
```

添加以下行（替换为你刚生成的密钥）：

```env
WEBHOOK_SECRET=your_generated_secret_here
```

保存并退出（Ctrl+O, Enter, Ctrl+X）。

### 2. 给脚本添加执行权限

```bash
chmod +x ~/coach-daily/server/deploy.sh
```

### 3. 启动 Webhook 服务

```bash
cd ~/coach-daily/server
pm2 start ecosystem.config.js
pm2 save
```

验证服务运行：

```bash
pm2 status
```

你应该看到两个服务：
- `coach-daily-api`
- `coach-daily-webhook`

### 4. 配置 Nginx 代理

编辑 Nginx 配置：

```bash
exit  # 退出 coach-daily 用户，回到 root
sudo nano /etc/nginx/sites-available/coach-daily
```

在 `server` 块中添加以下 location（在其他 location 之前）：

```nginx
    # Webhook 接收端点
    location /webhook {
        proxy_pass http://localhost:9000/webhook;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 传递 GitHub 请求头
        proxy_set_header X-GitHub-Event $http_x_github_event;
        proxy_set_header X-Hub-Signature-256 $http_x_hub_signature_256;
    }
```

测试并重启 Nginx：

```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 5. 测试 Webhook 服务

```bash
curl http://localhost:9000/webhook
```

应该返回 404（因为我们使用的是 POST 请求），这是正常的。

## GitHub 配置步骤

### 1. 打开仓库设置

1. 访问你的 GitHub 仓库：https://github.com/xiaoyangdestudy/caoch_daily
2. 点击 **Settings** 标签
3. 在左侧菜单点击 **Webhooks**
4. 点击 **Add webhook** 按钮

### 2. 配置 Webhook

填写以下信息：

**Payload URL**：
```
http://111.230.25.80/webhook
```

**Content type**：
```
application/json
```

**Secret**：
```
粘贴你在步骤1中生成的 WEBHOOK_SECRET
```

**Which events would you like to trigger this webhook?**：
- 选择 "Just the push event"

**Active**：
- 勾选 ✅

点击 **Add webhook** 按钮保存。

### 3. 测试 Webhook

GitHub 会自动发送一个 ping 事件来测试 webhook。

回到 Webhooks 页面，你应该看到：
- 绿色的 ✅ 表示 webhook 配置成功
- 点击 webhook 可以查看最近的发送记录

## 验证自动部署

### 1. 本地测试

修改任意文件（比如在 README 添加一行文字），然后：

```bash
git add .
git commit -m "test: webhook 自动部署测试"
git push origin main
```

### 2. 查看部署日志

在服务器上查看 webhook 日志：

```bash
ssh root@111.230.25.80
sudo su - coach-daily
cd ~/coach-daily/server

# 查看 webhook 日志
pm2 logs coach-daily-webhook

# 查看 API 日志
pm2 logs coach-daily-api
```

你应该能看到部署过程的输出。

### 3. 在 GitHub 查看

在 GitHub 仓库的 Settings > Webhooks 中，点击你的 webhook，可以看到：
- Recent Deliveries（最近的发送记录）
- 每次 push 的请求和响应详情

## 常见问题

### Q1: Webhook 返回 401 Unauthorized

**原因**：Secret 不匹配

**解决**：
1. 检查服务器上 `.env` 文件中的 `WEBHOOK_SECRET`
2. 检查 GitHub webhook 配置中的 Secret
3. 确保两者完全一致
4. 重启 webhook 服务：`pm2 restart coach-daily-webhook`

### Q2: Webhook 返回 404

**原因**：Nginx 没有正确代理

**解决**：
1. 检查 Nginx 配置中的 `/webhook` location
2. 测试 nginx 配置：`sudo nginx -t`
3. 重启 nginx：`sudo systemctl restart nginx`

### Q3: 部署脚本执行失败

**原因**：权限或路径问题

**解决**：
```bash
# 确保脚本有执行权限
chmod +x ~/coach-daily/server/deploy.sh

# 查看详细错误
pm2 logs coach-daily-webhook --err
```

### Q4: Git pull 失败

**原因**：本地有未提交的修改

**解决**：
```bash
cd ~/coach-daily
git status
# 如果有修改，重置到远程版本
git reset --hard origin/main
```

## 管理命令

```bash
# 查看所有服务状态
pm2 status

# 查看 webhook 日志
pm2 logs coach-daily-webhook

# 重启 webhook 服务
pm2 restart coach-daily-webhook

# 停止 webhook 服务
pm2 stop coach-daily-webhook

# 手动执行部署（用于测试）
cd ~/coach-daily/server
bash deploy.sh
```

## 安全建议

1. **使用强密钥**：WEBHOOK_SECRET 应该是随机生成的长字符串
2. **HTTPS**：生产环境建议配置 SSL 证书，使用 HTTPS
3. **IP 白名单**（可选）：只允许 GitHub 的 IP 访问 webhook 端点
4. **监控日志**：定期查看 webhook 日志，防止异常请求

## 禁用自动部署

如果需要临时禁用自动部署：

```bash
# 方法1：停止 webhook 服务
pm2 stop coach-daily-webhook

# 方法2：在 GitHub 禁用 webhook
# Settings > Webhooks > 编辑 > 取消勾选 Active
```

## 成功标志

配置成功后，每次你推送代码到 GitHub，你会看到：

1. GitHub webhook 页面显示 ✅ 成功发送
2. 服务器 webhook 日志显示接收到请求
3. 部署脚本自动执行
4. API 服务自动重启
5. 最新代码已部署

**祝自动部署顺利！** 🚀
