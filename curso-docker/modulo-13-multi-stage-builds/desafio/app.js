// App Node "fake" que simula um build de SPA.
// Em projetos reais, isso seria um React/Vue/Angular gerando uma pasta dist/.
// Aqui, simplificamos: o script "build" copia index.html pra dist/ e injeta a data.

const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "dist");
if (!fs.existsSync(distDir)) fs.mkdirSync(distDir);

const html = `<!doctype html>
<html lang="pt-br">
  <head>
    <meta charset="utf-8" />
    <title>Multi-stage Node Demo</title>
    <style>
      body { font-family: sans-serif; max-width: 600px; margin: 4rem auto; }
      code { background: #eee; padding: 0.2rem 0.4rem; border-radius: 4px; }
    </style>
  </head>
  <body>
    <h1>Olá do nginx!</h1>
    <p>Esta página foi gerada no <strong>stage de build (Node)</strong> e está sendo servida pelo <strong>stage de runtime (nginx)</strong>.</p>
    <p>Build em: <code>${new Date().toISOString()}</code></p>
    <p>Imagem final: ~25MB. Sem Node, sem <code>node_modules</code>, só nginx + estáticos.</p>
  </body>
</html>`;

fs.writeFileSync(path.join(distDir, "index.html"), html);
console.log("Build OK — dist/index.html gerado.");
