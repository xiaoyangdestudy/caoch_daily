# Flutter客户端集成完成指南

## ✅ 已完成的工作

### 1. 服务器端 ✅
- ✅ Node.js + Express + SQLite服务器
- ✅ 完整的RESTful API
- ✅ JWT认证系统
- ✅ 数据库初始化
- ✅ 服务器正在运行（http://localhost:3000）

### 2. Flutter客户端 ✅
- ✅ API客户端服务（`lib/shared/services/api_client.dart`）
- ✅ API Provider（`lib/shared/providers/api_provider.dart`）
- ✅ 认证页面（`lib/features/auth/presentation/auth_page.dart`）
- ✅ ReviewRepository改造（支持本地+云端双存储）
- ✅ 设置页面添加同步功能

---

## 🚀 如何测试（3步）

### 第1步：确保服务器运行中

服务器应该已经在后台运行，可以测试一下：

```bash
curl http://localhost:3000/health
```

应该返回：`{"status":"ok",...}`

如果没有运行，重新启动：
```bash
cd D:\00_DevProject\caoch_daily\server
npm run dev
```

### 第2步：运行Flutter应用

```bash
cd D:\00_DevProject\caoch_daily
flutter run
```

### 第3步：测试完整流程

1. **打开应用**，进入"个人设置"（Profile）页面

2. **找到"数据同步"section**，点击"登录/注册"

3. **注册新账号**：
   - 用户名：testuser（至少3个字符）
   - 密码：test123456（至少6个字符）
   - 点击"注册"

4. **注册成功后**，自动返回设置页面，显示"已登录"

5. **点击"同步数据"**：
   - 会将本地的Review数据上传到服务器
   - 显示"✓ 同步成功！"

6. **验证数据已同步**：
   - 可以在服务器数据库中查看数据
   - 或者使用curl测试：

```bash
# 先登录获取token
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"testuser\",\"password\":\"test123456\"}"

# 复制返回的token，然后：
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" http://localhost:3000/api/reviews
```

---

## 📱 功能说明

### 未登录状态
- **数据存储**：仅保存在本地（SharedPreferences）
- **功能**：所有功能正常使用，但数据不同步

### 已登录状态
- **创建数据**：自动同时保存到本地和服务器
- **读取数据**：优先从服务器获取（如果网络正常）
- **删除数据**：同时从本地和服务器删除
- **手动同步**：点击"同步数据"按钮，批量上传本地数据

### 离线支持
- **离线时创建数据**：保存到本地
- **联网后同步**：需要手动点击"同步数据"按钮（或自动同步，看实现）

---

## 📂 新增文件

```
lib/
├── shared/
│   ├── services/
│   │   └── api_client.dart         ← API客户端（HTTP请求+认证）
│   └── providers/
│       └── api_provider.dart       ← API Provider
├── features/
│   ├── auth/
│   │   └── presentation/
│       └── auth_page.dart          ← 登录/注册页面
│   └── review/
│       ├── data/
│       │   └── review_repository.dart  ← 已改造支持云端
│       └── application/
│           └── review_providers.dart   ← 已更新注入API
└── profile/
    └── presentation/
        └── profile_page.dart       ← 已添加同步功能

server/
└── (所有服务器端文件)
```

---

## 🔧 配置说明

### API地址配置

在 `lib/shared/providers/api_provider.dart` 中：

```dart
// 当前配置（本地开发）
baseUrl: 'http://localhost:3000/api'

// 如果在Android模拟器测试，改为：
baseUrl: 'http://10.0.2.2:3000/api'

// 如果在真机测试，改为你电脑的局域网IP：
baseUrl: 'http://192.168.1.100:3000/api'  // 替换为你的IP

// 生产环境（部署后）：
baseUrl: 'https://yourdomain.com/api'
```

### 查看你的电脑IP

Windows:
```powershell
ipconfig
# 找到"IPv4 地址"，如：192.168.1.100
```

macOS/Linux:
```bash
ifconfig
# 或
ip addr
```

---

## 🧪 测试场景

### 场景1：注册并同步
1. 打开应用
2. 进入设置 → 数据同步 → 登录/注册
3. 注册账号
4. 点击"同步数据"
5. 查看是否显示"同步成功"

### 场景2：创建新数据自动同步
1. 确保已登录
2. 创建一条新的Review记录
3. 查看控制台日志，应该看到"✓ 已同步到服务器"
4. 使用curl验证服务器有数据

### 场景3：退出登录
1. 设置 → 数据同步 → 退出登录
2. 本地数据仍然存在
3. 再次登录后可以继续同步

### 场景4：离线使用
1. 关闭服务器（Ctrl+C）
2. 创建新数据（会显示"同步到服务器失败"，但本地已保存）
3. 重启服务器
4. 点击"同步数据"手动同步

---

## ⚠️ 注意事项

### 1. 服务器必须运行

在测试前确保服务器在运行：
```bash
cd D:\00_DevProject\caoch_daily\server
npm run dev
```

### 2. 真机测试需要修改IP

如果在真机上测试，必须：
- 手机和电脑在同一WiFi网络
- 修改API地址为电脑的局域网IP
- 关闭电脑防火墙或允许3000端口

### 3. 其他Repository需要改造

目前只改造了ReviewRepository，其他Repository（workout、meal、sleep、focus）需要类似改造：

```dart
// 在对应的repository中
1. 构造函数添加ApiClient参数
2. 在provider中注入apiClientProvider
3. 在save/delete方法中添加服务器同步逻辑
4. 添加syncToServer方法
```

可以参考ReviewRepository的实现。

---

## 🎯 下一步

### 选项A：改造其他Repository
按照ReviewRepository的模式，改造其他数据模型，实现完整的云端同步。

### 选项B：部署到生产环境
1. 购买云服务器
2. 按照《服务器部署配置文档.md》部署
3. 修改Flutter的API地址为生产域名
4. 发布应用

### 选项C：添加更多功能
- 自动同步（应用启动时自动同步）
- 冲突处理（同一数据在不同设备修改）
- 同步状态显示（最后同步时间）
- 批量下载服务器数据

---

## 🆘 常见问题

### Q1: "连接超时，请检查网络"
**A**: 检查服务器是否运行，API地址是否正确

### Q2: "请先登录"
**A**: 需要先注册/登录账号

### Q3: Android模拟器无法连接localhost
**A**: 改用 `http://10.0.2.2:3000/api`

### Q4: 真机无法连接
**A**:
- 检查手机和电脑在同一WiFi
- 使用电脑的局域网IP而不是localhost
- 关闭电脑防火墙

---

## 📊 查看数据库

可以使用 **DB Browser for SQLite** 查看数据库：

1. 下载：https://sqlitebrowser.org/
2. 打开文件：`D:\00_DevProject\caoch_daily\server\data\coach_daily_dev.db`
3. 查看 `review_entries` 表，看看同步的数据

---

**恭喜！现在你的应用已经支持云端同步了！** 🎉

有任何问题随时问我！
