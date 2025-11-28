const http = require('http');
const crypto = require('crypto');
const { exec } = require('child_process');
const path = require('path');

// 配置
const PORT = 9000;
const WEBHOOK_SECRET = process.env.WEBHOOK_SECRET || 'your-webhook-secret-change-me';
const DEPLOY_SCRIPT = path.join(__dirname, 'deploy.sh');

// 验证 GitHub webhook 签名
function verifySignature(payload, signature) {
  if (!signature) return false;

  const hmac = crypto.createHmac('sha256', WEBHOOK_SECRET);
  const digest = 'sha256=' + hmac.update(payload).digest('hex');

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(digest)
  );
}

// 执行部署脚本
function executeDeploy(branch) {
  console.log(`[${new Date().toISOString()}] Starting deployment for branch: ${branch}`);

  exec(`bash ${DEPLOY_SCRIPT}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`[${new Date().toISOString()}] Deployment error:`, error);
      console.error('stderr:', stderr);
      return;
    }

    console.log(`[${new Date().toISOString()}] Deployment output:`);
    console.log(stdout);

    if (stderr) {
      console.log('stderr:', stderr);
    }

    console.log(`[${new Date().toISOString()}] Deployment completed successfully`);
  });
}

// 创建 HTTP 服务器
const server = http.createServer((req, res) => {
  // 只接受 POST 请求到 /webhook 路径
  if (req.method !== 'POST' || req.url !== '/webhook') {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
    return;
  }

  let body = '';

  req.on('data', chunk => {
    body += chunk.toString();
  });

  req.on('end', () => {
    try {
      // 验证签名
      const signature = req.headers['x-hub-signature-256'];
      if (!verifySignature(body, signature)) {
        console.warn(`[${new Date().toISOString()}] Invalid signature from ${req.connection.remoteAddress}`);
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid signature' }));
        return;
      }

      const payload = JSON.parse(body);
      const event = req.headers['x-github-event'];

      console.log(`[${new Date().toISOString()}] Received ${event} event from GitHub`);

      // 只处理 push 事件
      if (event === 'push') {
        const branch = payload.ref.replace('refs/heads/', '');

        // 只部署 main 分支
        if (branch === 'main') {
          executeDeploy(branch);

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: 'success',
            message: 'Deployment triggered',
            branch: branch
          }));
        } else {
          console.log(`[${new Date().toISOString()}] Ignoring push to branch: ${branch}`);
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({
            status: 'ignored',
            message: 'Only main branch deployments are enabled',
            branch: branch
          }));
        }
      } else if (event === 'ping') {
        // GitHub webhook 测试
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'pong' }));
      } else {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          status: 'ignored',
          message: `Event type ${event} not handled`
        }));
      }
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error processing webhook:`, error);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Internal server error' }));
    }
  });
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[${new Date().toISOString()}] Webhook server listening on port ${PORT}`);
  console.log(`Webhook URL: http://YOUR_SERVER_IP/webhook`);
});

// 优雅关闭
process.on('SIGTERM', () => {
  console.log(`[${new Date().toISOString()}] SIGTERM received, closing server...`);
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
