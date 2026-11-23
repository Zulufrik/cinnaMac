# Fontes

Coloque aqui (ou em `~/.local/share/fonts`) as fontes usadas pelo tema:

## SF Pro
Usada na barra de título das janelas (`titlebar-font = "SF Pro weight=590 11"`).

- Fonte oficial da Apple: não há redistribuição direta oficial no GitHub.
- Espelhos comuns: procure por "SF Pro fonts" no GitHub ou extraia do instalador oficial da Apple.
- Instale em `~/.local/share/fonts/SF-Pro.ttf` e rode `fc-cache -fv`.

## SF Mono Nerd Font
Usada em terminais e editores que suportam Nerd Font.

- Baixe de: https://github.com/ryanoasis/nerd-fonts/releases (arquivo `SFMono.zip`)
- Extraia os arquivos `.ttf` em `~/.local/share/fonts/SFMonoNerdFont/`
- Rode `fc-cache -fv`

O `install.sh` tenta baixar ambas automaticamente. Se falhar, faça o download manual acima.
