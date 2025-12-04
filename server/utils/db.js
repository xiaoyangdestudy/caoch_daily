const fs = require('fs');
const path = require('path');

const DB_DIR = path.join(__dirname, '../data');
const USERS_FILE = path.join(DB_DIR, 'users.json');
const MOMENTS_FILE = path.join(DB_DIR, 'moments.json');
const WORKOUTS_FILE = path.join(DB_DIR, 'workouts.json');
const MEALS_FILE = path.join(DB_DIR, 'meals.json');
const SLEEP_FILE = path.join(DB_DIR, 'sleep.json');
const FOCUS_FILE = path.join(DB_DIR, 'focus.json');
const REVIEWS_FILE = path.join(DB_DIR, 'reviews.json');
const READING_FILE = path.join(DB_DIR, 'reading.json');

// 确保数据目录存在
if (!fs.existsSync(DB_DIR)) {
  fs.mkdirSync(DB_DIR, { recursive: true });
}

// 初始化所有数据文件
const initFile = (filePath) => {
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, JSON.stringify([], null, 2));
  }
};

initFile(USERS_FILE);
initFile(MOMENTS_FILE);
initFile(WORKOUTS_FILE);
initFile(MEALS_FILE);
initFile(SLEEP_FILE);
initFile(FOCUS_FILE);
initFile(REVIEWS_FILE);
initFile(READING_FILE);

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

// 通用数据操作工厂函数
const createDataOperations = (filePath) => ({
  getAll: () => readData(filePath),

  getByUserId: (userId) => {
    const allData = readData(filePath);
    return allData.filter(item => item.userId === userId)
      .sort((a, b) => new Date(b.createdAt || b.startTime || b.timestamp) - new Date(a.createdAt || a.startTime || a.timestamp));
  },

  findById: (id) => {
    const allData = readData(filePath);
    return allData.find(item => item.id === id);
  },

  create: (item) => {
    const allData = readData(filePath);
    allData.push(item);
    writeData(filePath, allData);
    return item;
  },

  createBatch: (items) => {
    const allData = readData(filePath);
    allData.push(...items);
    writeData(filePath, allData);
    return items;
  },

  update: (id, updates) => {
    const allData = readData(filePath);
    const index = allData.findIndex(item => item.id === id);
    if (index !== -1) {
      allData[index] = { ...allData[index], ...updates };
      writeData(filePath, allData);
      return allData[index];
    }
    return null;
  },

  delete: (id) => {
    const allData = readData(filePath);
    const filtered = allData.filter(item => item.id !== id);
    writeData(filePath, filtered);
    return filtered.length < allData.length;
  },

  deleteByUserId: (userId) => {
    const allData = readData(filePath);
    const filtered = allData.filter(item => item.userId !== userId);
    writeData(filePath, filtered);
    return allData.length - filtered.length;
  }
});

// 运动记录操作
const workouts = createDataOperations(WORKOUTS_FILE);

// 饮食记录操作
const meals = createDataOperations(MEALS_FILE);

// 睡眠记录操作
const sleep = createDataOperations(SLEEP_FILE);

// 专注记录操作
const focus = createDataOperations(FOCUS_FILE);

// 复盘记录操作
const reviews = createDataOperations(REVIEWS_FILE);

// 阅读记录操作
const reading = createDataOperations(READING_FILE);

module.exports = {
  users,
  moments,
  workouts,
  meals,
  sleep,
  focus,
  reviews,
  reading
};
