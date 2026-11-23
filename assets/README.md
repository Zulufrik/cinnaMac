# Assets

Coloque aqui a imagem fonte do logo da Apple:

- `apple-logo-source.png` — imagem branca/transparente do logo da Apple (recomendado 512×512 ou maior, fundo transparente).

O script `scripts/setup-apple-logo.py` recorta, centraliza em um canvas e gera o PNG de 256×256 usado tanto no botão do Cinnamenu quanto no Slick Greeter (LightDM).

Exemplo de uso:
```bash
pkexec python3 scripts/setup-apple-logo.py
```
