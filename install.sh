#!/bin/bash
# =============================================================================
# install.sh - Cinnamon "igualzinho um Mac" para openSUSE Leap 16.1
#
# Aplica todas as configurações essenciais do Cinnamon com visual/macOS:
#   - Painel Mac (menu bar) com logo Apple, título da janela ativa, bandeja
#   - Launchpad via Cinnamenu (modo grade, ícones grandes, sem categorias)
#   - Spotlight via Super + Espaço
#   - Efeitos de janela no mínimo (performance)
#   - Relógio estilo macOS (12 horas), bateria com porcentagem
#   - Wallpaper dinâmico (Monterey / Ventura / Sonoma / WhiteSur dark)
#   - Tela de login LightDM + Slick Greeter com logo Apple
#   - Fontes SF Pro e SF Mono Nerd Font
#   - Swappiness otimizado (10)
#
# Rode como usuário comum. O script pede privilégios de root (pkexec/sudo)
# apenas para copiar arquivos de sistema e instalar fontes.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${HOME}"
CONFIGS="${SCRIPT_DIR}/configs"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
need_root() {
    if [[ "$EUID" -ne 0 ]]; then
        if command -v pkexec >/dev/null 2>&1; then
            pkexec "$@"
        elif command -v sudo >/dev/null 2>&1; then
            sudo "$@"
        else
            echo "ERRO: este passo precisa de root e nem pkexec nem sudo estao disponíveis." >&2
            exit 1
        fi
    else
        "$@"
    fi
}

echo "============================================================"
echo "  Instalando configuracoes Cinnamon estilo macOS"
echo "============================================================"

# -----------------------------------------------------------------------------
# 1. Pacotes essenciais (openSUSE Leap 16.1 / zypper)
# -----------------------------------------------------------------------------
echo -e "\n==> Verificando pacotes essenciais..."
if command -v zypper >/dev/null 2>&1; then
    ESSENTIAL="cinnamon lightdm lightdm-slick-greeter nemo vlc flatpak"
    echo "   Pacotes recomendados: ${ESSENTIAL}"
    echo "   Se algum estiver faltando, rode:"
    echo "     sudo zypper install --no-recommends ${ESSENTIAL}"
else
    echo "   zypper nao encontrado; pulando instalacao de pacotes."
fi

# -----------------------------------------------------------------------------
# 2. gsettings (usuario)
# -----------------------------------------------------------------------------
echo -e "\n==> Aplicando gsettings do Cinnamon..."
bash "${CONFIGS}/gsettings.sh"

# -----------------------------------------------------------------------------
# 3. Configuracoes de usuario (cinnamon spices, portal, backgrounds)
# -----------------------------------------------------------------------------
echo -e "\n==> Copiando configuracoes de usuario..."

# Cinnamenu (Launchpad)
CINNAMENU_DEST="${USER_HOME}/.config/cinnamon/spices/Cinnamenu@json"
mkdir -p "${CINNAMENU_DEST}"
cp "${CONFIGS}/cinnamon/Cinnamenu@json/21.json" "${CINNAMENU_DEST}/21.json"
echo "   OK: Cinnamenu@json/21.json"

# Calendario (relogio macOS)
CAL_DEST="${USER_HOME}/.config/cinnamon/spices/calendar@cinnamon.org"
mkdir -p "${CAL_DEST}"
cp "${CONFIGS}/cinnamon/calendar@cinnamon.org/15.json" "${CAL_DEST}/15.json"
echo "   OK: calendar@cinnamon.org/15.json"

# Bateria (porcentagem)
POWER_DEST="${USER_HOME}/.config/cinnamon/spices/power@cinnamon.org"
mkdir -p "${POWER_DEST}"
cp "${CONFIGS}/cinnamon/power@cinnamon.org/power@cinnamon.org.json" "${POWER_DEST}/power@cinnamon.org.json"
echo "   OK: power@cinnamon.org/power@cinnamon.org.json"

# Portal xdg (Flatpak apps usam GTK, nao KDE)
PORTAL_DEST="${USER_HOME}/.config/xdg-desktop-portal"
mkdir -p "${PORTAL_DEST}"
cp "${CONFIGS}/xdg-desktop-portal/portals.conf" "${PORTAL_DEST}/portals.conf"
echo "   OK: xdg-desktop-portal/portals.conf"

# Wallpaper dinâmico
BG_DEST="${USER_HOME}/.local/share/backgrounds"
mkdir -p "${BG_DEST}"
cp "${CONFIGS}/backgrounds/macos-slideshow.xml" "${BG_DEST}/macos-slideshow.xml"
echo "   OK: backgrounds/macos-slideshow.xml"
echo "   ATENCAO: copie os arquivos de fundo (Monterey-dark.jpg, etc.) para ${BG_DEST}"

# -----------------------------------------------------------------------------
# 4. Configuracoes de sistema (precisam de root)
# -----------------------------------------------------------------------------
echo -e "\n==> Copiando configuracoes de sistema (root)..."

# LightDM + Slick Greeter
need_root bash -c '
    mkdir -p /etc/lightdm
    cp '"${CONFIGS}"'/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
    cp '"${CONFIGS}"'/lightdm/slick-greeter.conf /etc/lightdm/slick-greeter.conf
    echo "   OK: /etc/lightdm/lightdm.conf e slick-greeter.conf"
'

# SDDM (fallback de emergencia - opcional)
if [[ -d /etc/sddm.conf.d ]]; then
    need_root bash -c '
        mkdir -p /etc/sddm.conf.d
        cp '"${CONFIGS}"'/sddm/kde_settings.conf /etc/sddm.conf.d/kde_settings.conf
        echo "   OK: /etc/sddm.conf.d/kde_settings.conf (fallback)"
    '
else
    echo "   AVISO: /etc/sddm.conf.d nao existe; pulando SDDM."
fi

# sysctl (performance)
need_root bash -c '
    cp '"${CONFIGS}"'/sysctl/99-cinnamon-performance.conf /etc/sysctl.d/99-cinnamon-performance.conf
    sysctl -p /etc/sysctl.d/99-cinnamon-performance.conf >/dev/null 2>&1 || true
    echo "   OK: /etc/sysctl.d/99-cinnamon-performance.conf (vm.swappiness=10)"
'

# -----------------------------------------------------------------------------
# 5. Logo Apple (precisa de root + imagem fonte em assets/)
# -----------------------------------------------------------------------------
echo -e "\n==> Logo Apple..."
if [[ -f "${SCRIPT_DIR}/assets/apple-logo-source.png" ]]; then
    need_root python3 "${SCRIPT_DIR}/scripts/setup-apple-logo.py"
    echo "   OK: logo Apple instalado."
else
    echo "   AVISO: assets/apple-logo-source.png nao encontrado."
    echo "   Coloque sua imagem do logo da Apple em assets/apple-logo-source.png"
    echo "   e rode: pkexec python3 scripts/setup-apple-logo.py"
fi

# -----------------------------------------------------------------------------
# 6. Ajustar heranca de icones WhiteSur (tirar Breeze)
# -----------------------------------------------------------------------------
echo -e "\n==> Ajustando heranca de icones WhiteSur..."
need_root python3 "${SCRIPT_DIR}/scripts/fix-whitesur-icons.py"
echo "   OK: WhiteSur nao herda mais do Breeze."

# -----------------------------------------------------------------------------
# 7. Fontes SF Pro e SF Mono Nerd Font
# -----------------------------------------------------------------------------
echo -e "\n==> Instalando fontes..."

FONT_DIR="${USER_HOME}/.local/share/fonts"
mkdir -p "${FONT_DIR}"

# SF Pro (tentativa de download de espelho conhecido)
if [[ ! -f "${FONT_DIR}/SF-Pro.ttf" ]]; then
    echo "   Baixando SF Pro..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "${FONT_DIR}/SF-Pro.zip" \
            "https://github.com/ptrv/SF-Pro-Fonts/archive/refs/heads/main.zip" 2>/dev/null || true
        if [[ -f "${FONT_DIR}/SF-Pro.zip" && -s "${FONT_DIR}/SF-Pro.zip" ]]; then
            unzip -o -j "${FONT_DIR}/SF-Pro.zip" "*.ttf" -d "${FONT_DIR}" 2>/dev/null || true
            rm -f "${FONT_DIR}/SF-Pro.zip"
        fi
    fi
fi

# SF Mono Nerd Font (do repositorio nerd-fonts)
if [[ ! -f "${FONT_DIR}/SFMonoNerdFont.ttf" ]]; then
    echo "   Baixando SF Mono Nerd Font..."
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "${FONT_DIR}/SFMonoNerdFont.zip" \
            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/SFMono.zip" 2>/dev/null || true
        if [[ -f "${FONT_DIR}/SFMonoNerdFont.zip" && -s "${FONT_DIR}/SFMonoNerdFont.zip" ]]; then
            unzip -o "${FONT_DIR}/SFMonoNerdFont.zip" -d "${FONT_DIR}/SFMonoNerdFont" 2>/dev/null || true
            rm -f "${FONT_DIR}/SFMonoNerdFont.zip"
        fi
    fi
fi

if [[ -d "${FONT_DIR}" ]]; then
    fc-cache -fv "${FONT_DIR}" >/dev/null 2>&1 || true
    echo "   OK: fontes instaladas em ${FONT_DIR}"
else
    echo "   AVISO: nao foi possível baixar fontes automaticamente."
    echo "   Baixe manualmente SF Pro e SF Mono Nerd Font para ${FONT_DIR}"
fi

# -----------------------------------------------------------------------------
# 8. Sessão padrão e display manager
# -----------------------------------------------------------------------------
echo -e "\n==> Confirmando LightDM como display manager..."
if command -v update-alternatives >/dev/null 2>&1; then
    need_root /usr/sbin/update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/lightdm 2>/dev/null || true
elif command -v update-alternatives >/dev/null 2>&1; then
    need_root update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/lightdm 2>/dev/null || true
fi
echo "   OK: display manager = $(readlink -f /etc/alternatives/default-displaymanager 2>/dev/null || echo desconhecido)"

# -----------------------------------------------------------------------------
# 9. LibreOffice com o tema do Cinnamon (GTK3)
# -----------------------------------------------------------------------------
echo -e "\n==> Integrando LibreOffice ao tema do Cinnamon..."
if command -v libreoffice >/dev/null 2>&1; then
    bash "${SCRIPT_DIR}/scripts/fix-libreoffice-gtk3.sh"
else
    echo "   LibreOffice nao instalado; pulando."
fi

# -----------------------------------------------------------------------------
# 10. Tema dos apps Qt (GTK3)
# -----------------------------------------------------------------------------
echo -e "\n==> Unificando o tema dos apps Qt..."
mkdir -p "${USER_HOME}/.config/environment.d"
cp "${CONFIGS}/qt/qt.conf" "${USER_HOME}/.config/environment.d/qt.conf"
need_root install -m 644 "${CONFIGS}/qt/zz-qt-theme.sh" /etc/profile.d/zz-qt-theme.sh
echo "   OK: Qt5 e Qt6 seguem o tema GTK (WhiteSur-Dark)."

# -----------------------------------------------------------------------------
# 11. Reiniciar Cinnamon
# -----------------------------------------------------------------------------
echo -e "\n==> Reiniciando o Cinnamon para aplicar..."
dbus-send --session --print-reply --dest=org.Cinnamon /org/Cinnamon org.Cinnamon.RestartCinnamon boolean:true >/dev/null 2>&1 || true

echo ""
echo "============================================================"
echo "  Instalacao concluida!"
echo "============================================================"
echo ""
echo "Próximos passos:"
echo "  1. Reinicie o computador para validar o LightDM com o logo Apple."
echo "  2. Se o LightDM falhar, use Ctrl+Alt+F2, faça login e rode:"
echo "     sudo /usr/sbin/update-alternatives --set default-displaymanager /usr/lib/X11/displaymanagers/sddm"
echo "     sudo reboot"
echo "  3. Atalho do Launchpad/Spotlight: Super + Espaço"
echo ""
