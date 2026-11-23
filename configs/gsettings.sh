#!/bin/bash
# Aplica todos os gsettings do Cinnamon estilo macOS.
# Rode como usuário comum (não precisa de root).
set -e

echo "==> Aplicando gsettings do Cinnamon..."

# --- Painel e applets ---
gsettings set org.cinnamon panels-height "['1:26']"
gsettings set org.cinnamon enabled-applets "['panel1:left:0:Cinnamenu@json:21', 'panel1:left:1:maximus-title@hanspr:27', 'panel1:right:3:systray@cinnamon.org:3', 'panel1:right:4:network@cinnamon.org:10', 'panel1:right:5:sound@cinnamon.org:11', 'panel1:right:6:power@cinnamon.org:12', 'panel1:right:7:calendar@cinnamon.org:15']"

# --- Tema e aparência ---
gsettings set org.cinnamon theme "WhiteSur-Dark-solid"
gsettings set org.cinnamon.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.cinnamon.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.cinnamon.desktop.interface cursor-theme "macOS-White"
gsettings set org.cinnamon.desktop.wm.preferences titlebar-font "SF Pro weight=590 11"
gsettings set org.cinnamon.desktop.interface font-name "Inter 11"
gsettings set org.cinnamon.desktop.wm.preferences button-layout "close,minimize,maximize:"

# --- Efeitos de janela (performance) ---
gsettings set org.cinnamon desktop-effects false
gsettings set org.cinnamon desktop-effects-minimize "none"
gsettings set org.cinnamon desktop-effects-map "none"
gsettings set org.cinnamon desktop-effects-close "none"
gsettings set org.cinnamon desktop-effects-change-size false
gsettings set org.cinnamon desktop-effects-workspace false
gsettings set org.cinnamon desktop-effects-on-menus false
gsettings set org.cinnamon desktop-effects-on-dialogs false
gsettings set org.cinnamon startup-animation false
gsettings set org.cinnamon window-effect-speed 2

# --- Animações GTK ---
gsettings set org.cinnamon.desktop.interface enable-animations false

# --- Relógio estilo macOS (12h) ---
gsettings set org.cinnamon.desktop.background picture-uri "file:///home/zulu/.local/share/backgrounds/macos-slideshow.xml"
gsettings set org.cinnamon.desktop.background picture-options "zoom"

# --- Cinnamenu (Launchpad) via gsettings não é suficiente;
#   o applet lê o JSON de spices. Veja configs/cinnamon/Cinnamenu@json/21.json

# --- Bateria: mostrar porcentagem ---
# Feito via JSON do power applet (configs/cinnamon/power@cinnamon.org/power@cinnamon.org.json)

echo "==> gsettings aplicados com sucesso."
