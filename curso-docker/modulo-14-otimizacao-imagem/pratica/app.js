// App de exemplo bem simples — só pra ter algo pra empacotar.
// Sobe um HTTP server na porta 3000 que responde "ok".

const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'ok', module: 14, lesson: 'otimizacao-imagem' }));
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Servidor ouvindo na porta ${PORT}`);
});
