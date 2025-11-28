# 服务器接口无法访问排查指南

## 问题描述
无法访问 http://111.230.25.80:3000 的API接口

## 排查步骤

### 1. 检查服务器是否安装了依赖包

之前的错误日志显示缺少 `dotenv`、`helmet`、`express-rate-limit` 这些依赖包。

**在服务器上执行**：

```bash
cd /home/coach-daily/caoch_daily/server
git pull  # 拉取最新的 package.json
npm install  # 安装依赖
```

### 2. 检查PM2服务状态

**在服务器上执行**：

```bash
pm2 status
pm2 logs coach-daily-api --lines 50
```

如果服务没有运行或有错误，重启服务：

```bash
pm2 restart coach-daily-api
# 或者
pm2 delete all
cd /home/coach-daily/caoch_daily/server
pm2 start ecosystem.config.js
```

### 3. 检查端口是否在监听

**在服务器上执行**：

```bash
# 检查3000端口是否被监听
netstat -tulpn | grep 3000
# 或者
lsof -i:3000
# 或者
ss -tulpn | grep 3000
```

如果没有输出，说明服务没有启动成功。

### 4. 检查防火墙规则

**在服务器上执行**：

```bash
# 检查防火墙状态
sudo ufw status

# 如果防火墙开启了，需要允许3000端口
sudo ufw allow 3000/tcp
sudo ufw reload
```

### 5. 检查云服务器安全组设置

腾讯云需要在控制台配置安全组规则：

1. 登录腾讯云控制台
2. 进入云服务器 -> 安全组
3. 找到你的服务器关联的安全组
4. 添加入站规则：
   - 协议端口：TCP:3000
   - 来源：0.0.0.0/0 (或者你的特定IP)
   - 策略：允许

### 6. 测试本地连接

**在服务器上执行**：

```bash
# 在服务器内部测试接口
curl http://localhost:3000/health
curl http://127.0.0.1:3000/health
```

如果服务器内部可以访问，说明是防火墙/安全组的问题。

### 7. 检查服务器日志

**在服务器上执行**：

```bash
# 查看PM2日志
pm2 logs coach-daily-api --lines 100

# 查看应用日志
tail -n 50 /home/coach-daily/caoch_daily/server/logs/err.log
tail -n 50 /home/coach-daily/caoch_daily/server/logs/out.log
```

## 快速修复命令（按顺序执行）

```bash
# 1. SSH 登录到服务器
ssh coach-daily@111.230.25.80

# 2. 进入项目目录
cd /home/coach-daily/caoch_daily/server

# 3. 拉取最新代码
git pull

# 4. 安装依赖
npm install

# 5. 重启PM2服务
pm2 restart coach-daily-api

# 6. 查看服务状态
pm2 status
pm2 logs coach-daily-api --lines 20

# 7. 测试本地接口
curl http://localhost:3000/health

# 8. 如果本地可以访问但外网不行，检查防火墙
sudo ufw status
sudo ufw allow 3000/tcp

# 9. 检查端口监听
netstat -tulpn | grep 3000
```

## 常见错误及解决方案

### 错误1: MODULE_NOT_FOUND

**原因**: 缺少npm包

**解决**:
```bash
cd /home/coach-daily/caoch_daily/server
npm install
pm2 restart coach-daily-api
```

### 错误2: EADDRINUSE (端口被占用)

**原因**: 3000端口已被其他程序占用

**解决**:
```bash
# 查找占用端口的进程
lsof -i:3000
# 或
netstat -tulpn | grep 3000

# 杀掉进程（替换PID为实际进程ID）
kill -9 PID
```

### 错误3: 连接超时

**原因**: 防火墙或安全组未开放端口

**解决**:
1. 服务器防火墙：`sudo ufw allow 3000/tcp`
2. 腾讯云控制台 -> 安全组 -> 添加入站规则

### 错误4: Permission denied

**原因**: 权限不足

**解决**:
```bash
# 修改项目目录权限
sudo chown -R coach-daily:coach-daily /home/coach-daily/caoch_daily
```

## 验证修复成功

修复后，从本地测试：

```bash
# 健康检查
curl http://111.230.25.80:3000/health

# 根路径
curl http://111.230.25.80:3000/

# 测试登录接口
curl -X POST http://111.230.25.80:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

如果返回JSON数据，说明接口已经正常工作。
