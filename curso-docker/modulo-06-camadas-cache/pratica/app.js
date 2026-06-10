// App mínimo só pra termos algum "código" pra mexer.
// O que importa neste módulo NÃO é o que o app faz —
// é como o Dockerfile copia/instala as coisas.

const express = require('express');
const { v4: uuid } = require('uuid');

const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    msg: 'Oi do modulo 06 — Camadas e Cache!',
    id: uuid(),
    horario: new Date().toISOString()
  });
});

app.listen(PORT, () => {
  console.log(`App rodando na porta ${PORT}`);
});
