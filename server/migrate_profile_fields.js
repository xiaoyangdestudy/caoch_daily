#!/usr/bin/env node

/**
 * 数据库迁移脚本 - 添加用户资料字段
 * 用于给已存在的 users 表添加 nickname, avatar, signature, email 字段
 */

const Database = require('better-sqlite3');
const path = require('path');

// 从命令行参数获取数据库路径，或使用默认路径
const dbPath = process.argv[2] || './data/coach_daily.db';

console.log(`正在迁移数据库: ${dbPath}`);

try {
  const db = new Database(dbPath);

  // 检查表是否存在
  const tableExists = db.prepare(`
    SELECT name FROM sqlite_master
    WHERE type='table' AND name='users'
  `).get();

  if (!tableExists) {
    console.error('❌ users 表不存在！');
    process.exit(1);
  }

  // 获取现有列
  const columns = db.prepare("PRAGMA table_info(users)").all();
  const columnNames = columns.map(col => col.name);

  console.log('当前表结构:', columnNames.join(', '));

  let addedColumns = 0;

  // 添加缺失的字段
  const fieldsToAdd = [
    { name: 'nickname', type: 'TEXT' },
    { name: 'avatar', type: 'TEXT' },
    { name: 'signature', type: 'TEXT' },
    { name: 'email', type: 'TEXT' }
  ];

  for (const field of fieldsToAdd) {
    if (!columnNames.includes(field.name)) {
      console.log(`添加字段: ${field.name} ${field.type}`);
      db.exec(`ALTER TABLE users ADD COLUMN ${field.name} ${field.type};`);
      addedColumns++;
    } else {
      console.log(`✓ 字段已存在: ${field.name}`);
    }
  }

  // 显示迁移后的表结构
  const newColumns = db.prepare("PRAGMA table_info(users)").all();
  console.log('\n迁移后的表结构:');
  newColumns.forEach(col => {
    console.log(`  - ${col.name} (${col.type})`);
  });

  db.close();

  if (addedColumns > 0) {
    console.log(`\n✅ 成功添加 ${addedColumns} 个字段！`);
  } else {
    console.log('\n✅ 所有字段都已存在，无需迁移。');
  }

} catch (error) {
  console.error('❌ 迁移失败:', error.message);
  process.exit(1);
}
