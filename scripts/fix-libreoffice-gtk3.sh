#!/usr/bin/env bash
# Faz o LibreOffice seguir o tema do Cinnamon (GTK3) em vez de cair no
# backend genérico do X11 (que parece o IceWM e ignora tema, ícones e fontes).
#
# - Instala o pacote libreoffice-gtk3 se estiver faltando (pede root).
# - Copia o launcher configurado para ~/.local/bin/libreoffice.
# - Não altera nenhum documento nem configuração do LibreOffice.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WRAPPER_SRC="$REPO_ROOT/configs/libreoffice/libreoffice"
WRAPPER_DEST="${HOME}/.local/bin/libreoffice"

have_plugin() {
    [ -f /usr/lib64/libreoffice/program/libvclplug_gtk3lo.so ] ||
    [ -f /usr/lib/libreoffice/program/libvclplug_gtk3lo.so ]
}

if ! command -v libreoffice >/dev/null 2>&1; then
    echo "ERRO: LibreOffice não está instalado." >&2
    exit 1
fi

if ! have_plugin; then
    echo "Pacote libreoffice-gtk3 ausente; instalando..."
    if command -v zypper >/dev/null 2>&1; then
        if [ "$(id -u)" -eq 0 ]; then
            zypper --non-interactive install libreoffice-gtk3
        elif command -v pkexec >/dev/null 2>&1; then
            pkexec zypper --non-interactive install libreoffice-gtk3
        elif command -v sudo >/dev/null 2>&1; then
            sudo zypper --non-interactive install libreoffice-gtk3
        else
            echo "ERRO: sem root disponível (pkexec/sudo) para instalar o pacote." >&2
            exit 1
        fi
    else
        echo "ERRO: instale o pacote 'libreoffice-gtk3' pelo gerenciador da sua distro." >&2
        exit 1
    fi
fi

mkdir -p "$(dirname "$WRAPPER_DEST")"
install -m 755 "$WRAPPER_SRC" "$WRAPPER_DEST"

echo "Launcher instalado em: $WRAPPER_DEST"
echo
echo "Feche o LibreOffice e abra de novo. Para conferir o backend carregado:"
echo "  pid=\$(pgrep -n soffice.bin)"
echo "  grep -ao 'libvclplug_[a-z0-9]*\\.so' /proc/\$pid/maps | sort -u"
echo
echo "O esperado é libvclplug_gtk3lo.so (e não libvclplug_genlo.so)."
