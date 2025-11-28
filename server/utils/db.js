const fs = require('fs');
const path = require('path');

const DB_DIR = path.join(__dirname, '../data');
const USERS_FILE = path.join(DB_DIR, 'users.json');
const MOMENTS_FILE = path.join(DB_DIR, 'moments.json');

// 确保数据目录存在
if (!fs.existsSync(DB_DIR)) {
  fs.mkdirSync(DB_DIR, { recursive: true });
}

// 初始化数据文件
if (!fs.existsSync(USERS_FILE)) {
  fs.writeFileSync(USERS_FILE, JSON.stringify([], null, 2));
}

if (!fs.existsSync(MOMENTS_FILE)) {
  fs.writeFileSync(MOMENTS_FILE, JSON.stringify([], null, 2));
}

// 读取数据
const readData = (filePath) => {
  try {
    const data = fs.readFileSync(filePath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error);
    return [];
  }
};

// 写入数据
const writeData = (filePath, data) => {
  try {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
    return true;
  } catch (error) {
    console.error(`Error writing ${filePath}:`, error);
    return false;
  }
};

// 用户操作
const users = {
  getAll: () => readData(USERS_FILE),
  
  findByUsername: (username) => {
    const allUsers = readData(USERS_FILE);
    return allUsers.find(u => u.username === username);
  },
  
  findById: (id) => {
    const allUsers = readData(USERS_FILE);
    return allUsers.find(u => u.id === id);
  },
  
  create: (user) => {
    const allUsers = readData(USERS_FILE);
    allUsers.push(user);
    writeData(USERS_FILE, allUsers);
    return user;
  },
  
  update: (id, updates) => {
    const allUsers = readData(USERS_FILE);
    const index = allUsers.findIndex(u => u.id === id);
    if (index !== -1) {
      allUsers[index] = { ...allUsers[index], ...updates };
      writeData(USERS_FILE, allUsers);
      return allUsers[index];
    }
    return null;
  }
};

// 动态操作
const moments = {
  getAll: () => readData(MOMENTS_FILE),
  
  getByUserId: (userId) => {
    const allMoments = readData(MOMENTS_FILE);
    return allMoments.filter(m => m.userId === userId)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  },
  
  findById: (id) => {
    const allMoments = readData(MOMENTS_FILE);
    return allMoments.find(m => m.id === id);
  },
  
  create: (moment) => {
    const allMoments = readData(MOMENTS_FILE);
    allMoments.push(moment);
    writeData(MOMENTS_FILE, allMoments);
    return moment;
  },
  
  update: (id, updates) => {
    const allMoments = readData(MOMENTS_FILE);
    const index = allMoments.findIndex(m => m.id === id);
    if (index !== -1) {
      allMoments[index] = { ...allMoments[index], ...updates };
      writeData(MOMENTS_FILE, allMoments);
      return allMoments[index];
    }
    return null;
  },
  
  delete: (id) => {
    const allMoments = readData(MOMENTS_FILE);
    const filtered = allMoments.filter(m => m.id !== id);
    writeData(MOMENTS_FILE, filtered);
    return filtered.length < allMoments.length;
  }
};

module.exports = { users, moments };
