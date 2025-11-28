# Coach Daily API 接口文档

## 基本信息

- **Base URL**: `http://your-server:3000/api`
- **认证方式**: Bearer Token (JWT)
- **数据格式**: JSON
- **字符编码**: UTF-8

## 目录

1. [认证接口](#认证接口)
2. [回顾记录接口](#回顾记录接口)
3. [运动记录接口](#运动记录接口)
4. [饮食记录接口](#饮食记录接口)
5. [睡眠记录接口](#睡眠记录接口)
6. [专注记录接口](#专注记录接口)
7. [数据同步接口](#数据同步接口)
8. [错误码说明](#错误码说明)

---

## 认证接口

### 1.1 用户注册

注册新用户账号。

**接口地址**: `POST /api/auth/register`

**请求参数**:

```json
{
  "username": "testuser",
  "password": "test123456"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名，至少3个字符 |
| password | string | 是 | 密码，至少6个字符 |

**响应示例**:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "username": "testuser"
}
```

**错误响应**:

- `400`: 缺少必填字段或格式不正确
- `409`: 用户名已存在

---

### 1.2 用户登录

用户登录获取访问令牌。

**接口地址**: `POST /api/auth/login`

**请求参数**:

```json
{
  "username": "testuser",
  "password": "test123456"
}
```

**响应示例**:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "username": "testuser"
}
```

**错误响应**:

- `400`: 缺少必填字段
- `401`: 用户名或密码错误

---

## 回顾记录接口

> 所有回顾记录接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 2.1 获取回顾记录列表

获取当前用户的所有回顾记录。

**接口地址**: `GET /api/reviews`

**查询参数**:

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| startDate | string | 否 | - | 开始日期 (YYYY-MM-DD) |
| endDate | string | 否 | - | 结束日期 (YYYY-MM-DD) |
| limit | number | 否 | 100 | 返回记录数量限制 |

**请求示例**:

```
GET /api/reviews?startDate=2025-11-01&endDate=2025-11-30&limit=50
```

**响应示例**:

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "user-uuid",
    "date": "2025-11-28",
    "mood": 4,
    "highlights": ["完成了API开发", "锻炼了30分钟"],
    "improvements": ["需要更早睡觉"],
    "tomorrowPlans": ["完成测试", "写文档"],
    "ai_summary": "今天工作效率很高，完成了主要任务",
    "note": "今天感觉不错",
    "created_at": "2025-11-28T10:00:00.000Z",
    "updated_at": "2025-11-28T10:00:00.000Z"
  }
]
```

---

### 2.2 获取单个回顾记录

获取指定ID的回顾记录详情。

**接口地址**: `GET /api/reviews/:id`

**响应示例**: 同上

**错误响应**:

- `404`: 记录不存在

---

### 2.3 创建/更新回顾记录

创建新的回顾记录或更新已存在的记录。

**接口地址**: `POST /api/reviews`

**请求参数**:

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "date": "2025-11-28",
  "mood": 4,
  "highlights": ["完成了API开发", "锻炼了30分钟"],
  "improvements": ["需要更早睡觉"],
  "tomorrowPlans": ["完成测试", "写文档"],
  "aiSummary": "今天工作效率很高",
  "note": "今天感觉不错"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录的唯一标识符 (UUID) |
| date | string | 是 | 日期 (YYYY-MM-DD) |
| mood | number | 是 | 心情评分 (1-5) |
| highlights | array | 否 | 今日亮点列表 |
| improvements | array | 否 | 需要改进的地方 |
| tomorrowPlans | array | 否 | 明日计划 |
| aiSummary | string | 否 | AI生成的总结 |
| note | string | 否 | 备注 |

**响应示例**:

```json
{
  "success": true,
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

---

### 2.4 删除回顾记录

删除指定的回顾记录。

**接口地址**: `DELETE /api/reviews/:id`

**响应示例**:

```json
{
  "success": true
}
```

**错误响应**:

- `404`: 记录不存在

---

## 运动记录接口

> 所有运动记录接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 3.1 获取运动记录列表

**接口地址**: `GET /api/workouts`

**查询参数**:

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| startDate | string | 否 | - | 开始时间 (ISO 8601) |
| endDate | string | 否 | - | 结束时间 (ISO 8601) |
| limit | number | 否 | 100 | 返回记录数量限制 |

**响应示例**:

```json
[
  {
    "id": "workout-uuid",
    "user_id": "user-uuid",
    "type": "跑步",
    "start_time": "2025-11-28T06:00:00.000Z",
    "duration_minutes": 30,
    "distance_km": 5.2,
    "calories_kcal": 350,
    "notes": "晨跑，感觉良好",
    "created_at": "2025-11-28T06:30:00.000Z",
    "updated_at": "2025-11-28T06:30:00.000Z"
  }
]
```

---

### 3.2 获取单个运动记录

**接口地址**: `GET /api/workouts/:id`

**错误响应**:

- `404`: 记录不存在

---

### 3.3 创建/更新运动记录

**接口地址**: `POST /api/workouts`

**请求参数**:

```json
{
  "id": "workout-uuid",
  "type": "跑步",
  "startTime": "2025-11-28T06:00:00.000Z",
  "durationMinutes": 30,
  "distanceKm": 5.2,
  "caloriesKcal": 350,
  "notes": "晨跑，感觉良好"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录的唯一标识符 (UUID) |
| type | string | 是 | 运动类型 (跑步/力量训练/游泳等) |
| startTime | string | 是 | 开始时间 (ISO 8601) |
| durationMinutes | number | 是 | 运动时长（分钟） |
| distanceKm | number | 否 | 运动距离（公里） |
| caloriesKcal | number | 否 | 消耗卡路里 |
| notes | string | 否 | 备注 |

**响应示例**:

```json
{
  "success": true,
  "id": "workout-uuid"
}
```

---

### 3.4 删除运动记录

**接口地址**: `DELETE /api/workouts/:id`

**响应示例**:

```json
{
  "success": true
}
```

---

## 饮食记录接口

> 所有饮食记录接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 4.1 获取饮食记录列表

**接口地址**: `GET /api/meals`

**查询参数**: 同运动记录接口

**响应示例**:

```json
[
  {
    "id": "meal-uuid",
    "user_id": "user-uuid",
    "meal_type": "早餐",
    "timestamp": "2025-11-28T07:00:00.000Z",
    "notes": "营养均衡的早餐",
    "created_at": "2025-11-28T07:30:00.000Z",
    "updated_at": "2025-11-28T07:30:00.000Z",
    "items": [
      {
        "id": "item-uuid-1",
        "meal_id": "meal-uuid",
        "name": "燕麦片",
        "calories": 150,
        "protein": 5,
        "carbs": 27,
        "fat": 3,
        "image_url": null
      },
      {
        "id": "item-uuid-2",
        "meal_id": "meal-uuid",
        "name": "牛奶",
        "calories": 120,
        "protein": 8,
        "carbs": 12,
        "fat": 5,
        "image_url": null
      }
    ]
  }
]
```

---

### 4.2 创建/更新饮食记录

**接口地址**: `POST /api/meals`

**请求参数**:

```json
{
  "id": "meal-uuid",
  "mealType": "早餐",
  "timestamp": "2025-11-28T07:00:00.000Z",
  "items": [
    {
      "id": "item-uuid-1",
      "name": "燕麦片",
      "calories": 150,
      "protein": 5,
      "carbs": 27,
      "fat": 3,
      "imageUrl": null
    },
    {
      "id": "item-uuid-2",
      "name": "牛奶",
      "calories": 120,
      "protein": 8,
      "carbs": 12,
      "fat": 5,
      "imageUrl": null
    }
  ],
  "notes": "营养均衡的早餐"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录的唯一标识符 (UUID) |
| mealType | string | 是 | 餐食类型 (早餐/午餐/晚餐/加餐) |
| timestamp | string | 是 | 用餐时间 (ISO 8601) |
| items | array | 否 | 食物项目列表 |
| items[].id | string | 是 | 食物项目ID |
| items[].name | string | 是 | 食物名称 |
| items[].calories | number | 是 | 卡路里 |
| items[].protein | number | 是 | 蛋白质(g) |
| items[].carbs | number | 是 | 碳水化合物(g) |
| items[].fat | number | 是 | 脂肪(g) |
| items[].imageUrl | string | 否 | 食物图片URL |
| notes | string | 否 | 备注 |

**响应示例**:

```json
{
  "success": true,
  "id": "meal-uuid"
}
```

---

### 4.3 删除饮食记录

**接口地址**: `DELETE /api/meals/:id`

**响应示例**:

```json
{
  "success": true
}
```

---

## 睡眠记录接口

> 所有睡眠记录接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 5.1 获取睡眠记录列表

**接口地址**: `GET /api/sleep`

**查询参数**:

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| startDate | string | 否 | - | 开始日期 (YYYY-MM-DD) |
| endDate | string | 否 | - | 结束日期 (YYYY-MM-DD) |
| limit | number | 否 | 100 | 返回记录数量限制 |

**响应示例**:

```json
[
  {
    "id": "sleep-uuid",
    "user_id": "user-uuid",
    "date": "2025-11-28",
    "bedtime": "23:00",
    "wake_time": "07:00",
    "sleep_quality": 4,
    "note": "睡眠质量不错",
    "created_at": "2025-11-28T07:30:00.000Z",
    "updated_at": "2025-11-28T07:30:00.000Z"
  }
]
```

---

### 5.2 创建/更新睡眠记录

**接口地址**: `POST /api/sleep`

**请求参数**:

```json
{
  "id": "sleep-uuid",
  "date": "2025-11-28",
  "bedtime": "23:00",
  "wakeTime": "07:00",
  "sleepQuality": 4,
  "note": "睡眠质量不错"
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录的唯一标识符 (UUID) |
| date | string | 是 | 日期 (YYYY-MM-DD) |
| bedtime | string | 是 | 入睡时间 (HH:mm) |
| wakeTime | string | 是 | 起床时间 (HH:mm) |
| sleepQuality | number | 否 | 睡眠质量评分 (1-5) |
| note | string | 否 | 备注 |

**响应示例**:

```json
{
  "success": true,
  "id": "sleep-uuid"
}
```

---

### 5.3 删除睡眠记录

**接口地址**: `DELETE /api/sleep/:id`

**响应示例**:

```json
{
  "success": true
}
```

---

## 专注记录接口

> 所有专注记录接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 6.1 获取专注记录列表

**接口地址**: `GET /api/focus`

**查询参数**:

| 参数名 | 类型 | 必填 | 默认值 | 说明 |
|--------|------|------|--------|------|
| startDate | string | 否 | - | 开始时间 (ISO 8601) |
| endDate | string | 否 | - | 结束时间 (ISO 8601) |
| limit | number | 否 | 100 | 返回记录数量限制 |

**响应示例**:

```json
[
  {
    "id": "focus-uuid",
    "user_id": "user-uuid",
    "start_time": "2025-11-28T09:00:00.000Z",
    "end_time": "2025-11-28T09:25:00.000Z",
    "target_minutes": 25,
    "task_name": "API开发",
    "completed": 1,
    "created_at": "2025-11-28T09:25:00.000Z",
    "updated_at": "2025-11-28T09:25:00.000Z"
  }
]
```

---

### 6.2 创建/更新专注记录

**接口地址**: `POST /api/focus`

**请求参数**:

```json
{
  "id": "focus-uuid",
  "startTime": "2025-11-28T09:00:00.000Z",
  "endTime": "2025-11-28T09:25:00.000Z",
  "targetMinutes": 25,
  "taskName": "API开发",
  "completed": true
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录的唯一标识符 (UUID) |
| startTime | string | 是 | 开始时间 (ISO 8601) |
| endTime | string | 是 | 结束时间 (ISO 8601) |
| targetMinutes | number | 是 | 目标专注时长（分钟） |
| taskName | string | 否 | 任务名称 |
| completed | boolean | 否 | 是否完成 |

**响应示例**:

```json
{
  "success": true,
  "id": "focus-uuid"
}
```

---

### 6.3 删除专注记录

**接口地址**: `DELETE /api/focus/:id`

**响应示例**:

```json
{
  "success": true
}
```

---

## 数据同步接口

> 所有同步接口都需要在请求头中携带 `Authorization: Bearer {token}`

### 7.1 批量同步数据

批量上传多种类型的数据记录。

**接口地址**: `POST /api/sync/batch`

**请求参数**:

```json
{
  "reviews": [
    {
      "id": "review-uuid",
      "date": "2025-11-28",
      "mood": 4,
      "highlights": ["完成任务"],
      "improvements": ["早睡"],
      "tomorrowPlans": ["继续努力"],
      "aiSummary": "今天不错",
      "note": "备注"
    }
  ],
  "workouts": [
    {
      "id": "workout-uuid",
      "type": "跑步",
      "startTime": "2025-11-28T06:00:00.000Z",
      "durationMinutes": 30,
      "distanceKm": 5,
      "caloriesKcal": 300,
      "notes": "晨跑"
    }
  ],
  "meals": [],
  "sleep": [
    {
      "id": "sleep-uuid",
      "date": "2025-11-28",
      "bedtime": "23:00",
      "wakeTime": "07:00",
      "sleepQuality": 4,
      "note": "睡得好"
    }
  ],
  "focus": [
    {
      "id": "focus-uuid",
      "startTime": "2025-11-28T09:00:00.000Z",
      "endTime": "2025-11-28T09:25:00.000Z",
      "targetMinutes": 25,
      "taskName": "工作",
      "completed": true
    }
  ]
}
```

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| reviews | array | 否 | 回顾记录数组 |
| workouts | array | 否 | 运动记录数组 |
| meals | array | 否 | 饮食记录数组 |
| sleep | array | 否 | 睡眠记录数组 |
| focus | array | 否 | 专注记录数组 |

**响应示例**:

```json
{
  "success": true,
  "synced": {
    "reviewsCount": 1,
    "workoutsCount": 1,
    "mealsCount": 0,
    "sleepCount": 1,
    "focusCount": 1
  }
}
```

---

### 7.2 获取最后同步时间

获取当前用户所有数据的最后更新时间。

**接口地址**: `GET /api/sync/last-sync`

**响应示例**:

```json
{
  "lastSync": "2025-11-28T10:30:00.000Z"
}
```

如果没有任何数据，返回：

```json
{
  "lastSync": null
}
```

---

## 错误码说明

### HTTP 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权（未登录或token无效） |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突（如用户名已存在） |
| 500 | 服务器内部错误 |

### 错误响应格式

所有错误响应都遵循以下格式：

```json
{
  "error": "错误描述信息"
}
```

**常见错误示例**:

```json
{
  "error": "Username and password are required"
}
```

```json
{
  "error": "Invalid credentials"
}
```

```json
{
  "error": "Review entry not found"
}
```

---

## 认证说明

### 获取 Token

通过注册或登录接口获取 JWT token。

### 使用 Token

在需要认证的接口请求头中添加：

```
Authorization: Bearer {your-token-here}
```

### Token 过期

Token 默认有效期为 7 天。过期后需要重新登录获取新的 token。

---

## 数据格式说明

### 日期时间格式

- **日期**: `YYYY-MM-DD` (例如: `2025-11-28`)
- **时间**: `HH:mm` (例如: `23:00`)
- **日期时间**: ISO 8601 格式 (例如: `2025-11-28T10:30:00.000Z`)

### UUID 格式

所有记录的 `id` 字段都使用 UUID v4 格式：

```
550e8400-e29b-41d4-a716-446655440000
```

---

## 示例代码

### JavaScript (Fetch API)

```javascript
// 登录
async function login(username, password) {
  const response = await fetch('http://localhost:3000/api/auth/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ username, password })
  });

  const data = await response.json();
  return data.token;
}

// 获取回顾记录
async function getReviews(token) {
  const response = await fetch('http://localhost:3000/api/reviews', {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });

  return await response.json();
}

// 创建回顾记录
async function createReview(token, reviewData) {
  const response = await fetch('http://localhost:3000/api/reviews', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(reviewData)
  });

  return await response.json();
}
```

### cURL

```bash
# 登录
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123456"}'

# 获取回顾记录
curl -X GET http://localhost:3000/api/reviews \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# 创建回顾记录
curl -X POST http://localhost:3000/api/reviews \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "date": "2025-11-28",
    "mood": 4,
    "highlights": ["完成任务"],
    "improvements": ["早睡"],
    "tomorrowPlans": ["继续努力"]
  }'
```

---

## 健康检查

### 健康检查接口

**接口地址**: `GET /health`

无需认证。

**响应示例**:

```json
{
  "status": "ok",
  "timestamp": "2025-11-28T10:30:00.000Z",
  "environment": "production",
  "version": "1.0.0"
}
```

---

## 更新日志

### v1.0.0 (2025-11-28)

- 初始版本发布
- 实现用户认证功能
- 实现回顾、运动、饮食、睡眠、专注记录管理
- 实现批量数据同步功能

---

## 技术支持

如有问题或建议，请联系开发团队。
