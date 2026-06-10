// Servidor HTTP minimalista em Node puro (sem deps externas)
// Escuta na porta 3000 e responde "Olá Docker!" em qualquer rota.

const http = require('http');

const PORT = 3000;
const HOST = '0.0.0.0'; // 0.0.0.0 (não 127.0.0.1!) — escuta em todas as interfaces
                        // dentro do container. Se usar localhost, não funciona do host.

const server = http.createServer((req, res) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end('Olá Docker!\n');
});

server.listen(PORT, HOST, () => {
  console.log(`Servidor rodando em http://${HOST}:${PORT}`);
});
