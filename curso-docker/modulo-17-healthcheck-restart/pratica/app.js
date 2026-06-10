// Módulo 17 — Prática: app minúsculo com /health
// Sem dependências externas — só módulo http nativo do Node.
const http = require('http');

const PORT = 3000;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    // Healthcheck: retorna 200 + JSON simples
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', uptime: process.uptime() }));
    return;
  }

  if (req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Modulo 17 — vivo e respondendo\n');
    return;
  }

  res.writeHead(404, { 'Content-Type': 'text/plain' });
  res.end('not found\n');
});

server.listen(PORT, () => {
  console.log(`Servidor ouvindo em :${PORT}`);
});

// Boa pratica: SIGTERM limpo (Docker manda quando para o container)
process.on('SIGTERM', () => {
  console.log('Recebi SIGTERM — fechando...');
  server.close(() => process.exit(0));
});
