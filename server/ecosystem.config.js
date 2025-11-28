module.exports = {
  apps: [
    {
      name: 'coach-daily-api',
      script: './src/index.js',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '200M',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
    },
    {
      name: 'coach-daily-webhook',
      script: './webhook.js',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '100M',
      env: {
        NODE_ENV: 'production',
        WEBHOOK_SECRET: process.env.WEBHOOK_SECRET || 'your-webhook-secret-change-me'
      },
      error_file: './logs/webhook-err.log',
      out_file: './logs/webhook-out.log',
      log_file: './logs/webhook-combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss'
    }
  ]
};
