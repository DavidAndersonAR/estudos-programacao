# 🎯 DESAFIO MÓDULO 04 — Servidor Flask minimalista
#
# Servidor Python + Flask que responde "Olá Flask!" na rota /.
# Você não precisa mexer aqui — o foco é o Dockerfile.

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    return "Olá Flask!\n"


if __name__ == "__main__":
    # host="0.0.0.0" é OBRIGATÓRIO dentro do container.
    # Se deixar localhost (default), o Flask só escuta dentro do container
    # e o -p do docker run não consegue alcançar.
    app.run(host="0.0.0.0", port=5000)
