// Desafio Módulo 17 — app com bug intencional
// Depois de MAX_REQUESTS requisições em /, o app "trava":
// passa a responder 500 em /health.
// Combinado com healthcheck + restart no Docker, isso causa
// auto-recuperação visível.
const http = require('http');

const PORT = 3000;
const MAX_REQUESTS = 5;
let count = 0;
let broken = false;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    if (broken) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'broken', count }));
      return;
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', count }));
    return;
  }

  if (req.url === '/') {
    count++;
    if (count > MAX_REQUESTS) {
      broken = true;
    }
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Request #${count} — broken=${broken}\n`);
    return;
  }

  res.writeHead(404);
  res.end();
});

server.listen(PORT, () => {
  console.log(`Servidor ouvindo em :${PORT} (max ${MAX_REQUESTS} req antes de quebrar)`);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM — fechando.');
  server.close(() => process.exit(0));
});
