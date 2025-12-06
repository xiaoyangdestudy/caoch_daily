const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const dbPath = process.env.DB_PATH || './data/coach_daily.db';
const dbDir = path.dirname(dbPath);

// 确保数据目录存在
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

const db = new Database(dbPath, {
  verbose: process.env.NODE_ENV === 'development' ? console.log : null
});

// 启用WAL模式（提高并发性能）
db.pragma('journal_mode = WAL');
db.pragma('busy_timeout = 5000');

// 初始化数据库表结构
function initDatabase() {
  console.log('Initializing database...');

  // 用户表
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      username TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      nickname TEXT,
      avatar TEXT,
      signature TEXT,
      email TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);

  // 迁移：为已存在的 users 表添加新字段
  const userTableInfo = db.prepare("PRAGMA table_info(users)").all();
  const existingColumns = userTableInfo.map(col => col.name);

  if (!existingColumns.includes('nickname')) {
    db.exec(`ALTER TABLE users ADD COLUMN nickname TEXT;`);
    console.log('✓ Added nickname column to users table');
  }
  if (!existingColumns.includes('avatar')) {
    db.exec(`ALTER TABLE users ADD COLUMN avatar TEXT;`);
    console.log('✓ Added avatar column to users table');
  }
  if (!existingColumns.includes('signature')) {
    db.exec(`ALTER TABLE users ADD COLUMN signature TEXT;`);
    console.log('✓ Added signature column to users table');
  }
  if (!existingColumns.includes('email')) {
    db.exec(`ALTER TABLE users ADD COLUMN email TEXT;`);
    console.log('✓ Added email column to users table');
  }

  // 每日回顾表
  db.exec(`
    CREATE TABLE IF NOT EXISTS review_entries (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      mood TEXT NOT NULL,
      highlights TEXT,
      improvements TEXT,
      tomorrow_plans TEXT,
      ai_summary TEXT,
      note TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_review_user_date ON review_entries(user_id, date);
  `);

  // 运动记录表
  db.exec(`
    CREATE TABLE IF NOT EXISTS workout_records (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      type TEXT NOT NULL,
      start_time TEXT NOT NULL,
      duration_minutes INTEGER NOT NULL,
      distance_km REAL NOT NULL,
      calories_kcal INTEGER NOT NULL,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_workout_user_time ON workout_records(user_id, start_time);
  `);

  // 饮食记录表
  db.exec(`
    CREATE TABLE IF NOT EXISTS meal_records (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      meal_type TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      notes TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_meal_user_time ON meal_records(user_id, timestamp);
  `);

  // 食物项表
  db.exec(`
    CREATE TABLE IF NOT EXISTS food_items (
      id TEXT PRIMARY KEY,
      meal_id TEXT NOT NULL,
      name TEXT NOT NULL,
      calories INTEGER NOT NULL,
      protein REAL NOT NULL,
      carbs REAL NOT NULL,
      fat REAL NOT NULL,
      image_url TEXT,
      FOREIGN KEY (meal_id) REFERENCES meal_records(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_food_meal ON food_items(meal_id);
  `);

  // 睡眠记录表
  db.exec(`
    CREATE TABLE IF NOT EXISTS sleep_records (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      date TEXT NOT NULL,
      bedtime TEXT NOT NULL,
      wake_time TEXT NOT NULL,
      note TEXT,
      sleep_quality INTEGER,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_sleep_user_date ON sleep_records(user_id, date);
  `);

  // 专注工作表
  db.exec(`
    CREATE TABLE IF NOT EXISTS focus_sessions (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      target_minutes INTEGER NOT NULL,
      task_name TEXT,
      completed INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
    CREATE INDEX IF NOT EXISTS idx_focus_user_time ON focus_sessions(user_id, start_time);
  `);

  console.log('✓ Database initialized successfully');
  console.log(`✓ Database location: ${path.resolve(dbPath)}`);
}

module.exports = { db, initDatabase };
