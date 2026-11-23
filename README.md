# Cinnamon "igualzinho um Mac" — openSUSE Leap 16.1

Configurações essenciais para deixar o Cinnamon com cara e comportamento de macOS, depois de migrar 100% do KDE.

## O que está incluído

| Item | Onde fica | O que faz |
|------|-----------|-----------|
| Painel Mac (menu bar) | `configs/gsettings.sh` | Apenas os applets essenciais: Cinnamenu, título da janela ativa, bandeja (systray, rede, som, energia, calendário) |
| Launchpad | `configs/cinnamon/Cinnamenu@json/21.json` | Cinnamenu em modo grade, ícones 112 px, sem sidebar/categorias, abre em "Todos os aplicativos", 1900×1040 |
| Spotlight | `overlay-key = <Super>space` | `Super + Espaço` abre o menu (Launchpad) |
| Relógio macOS | `configs/cinnamon/calendar@cinnamon.org/15.json` | Formato `%a %d %b  %-I:%M %p` (12 horas) |
| Bateria | `configs/cinnamon/power@cinnamon.org/power@cinnamon.org.json` | Mostra porcentagem ao lado do ícone |
| Efeitos (performance) | `configs/gsettings.sh` | Animações de janela e GTK desligadas, `vm.swappiness=10` |
| Wallpaper dinâmico | `backgrounds/macos-slideshow.xml` | Slideshow Monterey → Ventura → Sonoma → WhiteSur (dark) |
| Tela de login | `configs/lightdm/slick-greeter.conf` | LightDM + Slick Greeter com logo Apple, tema WhiteSur-Dark |
| Fallback SDDM | `configs/sddm/kde_settings.conf` | Sessão Cinnamon, tema elarun, cursor WhiteSur |
| Fontes | `fonts/README.md` | SF Pro (título da barra) e SF Mono Nerd Font |
| Ícones | `scripts/fix-whitesur-icons.py` | WhiteSur não herda mais do Breeze (útil após remover KDE) |
| Logo Apple | `scripts/setup-apple-logo.py` | Gera/instala o logo branco no menu e no greeter |

## Como usar

```bash
# 1. Clone este repositório
git clone https://github.com/seu-usuario/cinnamon-macos-config.git
cd cinnamon-macos-config

# 2. Dê permissão de execução
chmod +x install.sh

# 3. Rode a instalação (como usuário comum)
./install.sh
```

O script pede privilégios de root (`pkexec` ou `sudo`) somente para copiar arquivos de sistema (`/etc/lightdm`, `/etc/sysctl.d`, etc.) e instalar fontes.

### Após rodar o install.sh

1. Reinicie o computador para validar o **LightDM** com o logo Apple.
2. O atalho do Launchpad/Spotlight é **Super + Espaço**.
3. Se o LightDM falhar, use `Ctrl+Alt+F2`, faça login e rode:
   ```bash
   sudo /usr/sbin/update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/sddm
   sudo reboot
   ```

## Fontes

As fontes **SF Pro** (barra de título) e **SF Mono Nerd Font** devem ser colocadas em `~/.local/share/fonts`.  
Veja `fonts/README.md` para instruções de download.

## Limitação conhecida

O Cinnamon não fornece nativamente uma barra de menus global estilo macOS (`Arquivo`, `Editar`, `Visualizar` no painel superior). Isso é uma limitação do próprio ambiente e foi aceita como tal.

## Requisitos

- openSUSE Leap 16.1 (ou similar)
- Cinnamon 6.x
- LightDM + Slick Greeter
- Tema de ícones WhiteSur / WhiteSur-dark
- Cursores WhiteSur-cursors

## Licença

MIT — veja `LICENSE`.
