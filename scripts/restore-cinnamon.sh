#!/usr/bin/env bash
# Restaura as configurações do Cinnamon a partir de backup/cinnamon.dconf.
#
# Uso: scripts/restore-cinnamon.sh [--dry-run] [arquivo]
#
# - Não usa sudo.
# - Pede confirmação antes de sobrescrever as preferências atuais.
# - --dry-run apenas mostra o que seria aplicado, sem alterar nada.
set -euo pipefail

if ! command -v dconf >/dev/null 2>&1; then
    echo "ERRO: 'dconf' não está instalado." >&2
    echo "       Linux Mint / Debian: sudo apt install dconf-cli" >&2
    echo "       openSUSE:            sudo zypper install dconf" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DCONF_PATH="/org/cinnamon/"
DRY_RUN=0
SRC=""

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            echo "Uso: $0 [--dry-run] [arquivo]"
            exit 0
            ;;
        -*)
            echo "ERRO: opção desconhecida: $arg" >&2
            exit 2
            ;;
        *) SRC="$arg" ;;
    esac
done
SRC="${SRC:-$REPO_ROOT/backup/cinnamon.dconf}"

if [ ! -f "$SRC" ]; then
    echo "ERRO: arquivo não encontrado: $SRC" >&2
    exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Reverte o marcador __HOME__ para o caminho real do usuário atual.
sed "s|__HOME__|${HOME}|g" "$SRC" >"$tmp"

echo "Arquivo: $SRC"
echo "Destino: dconf $DCONF_PATH"
echo
echo "ATENÇÃO: restaurar SUBSTITUI as preferências atuais do Cinnamon"
echo "         (painel, temas, fontes, efeitos, atalhos etc.)."
echo

if [ "$DRY_RUN" -eq 1 ]; then
    echo "--dry-run: nada será alterado. Conteúdo que seria carregado:"
    echo "------------------------------------------------------------"
    cat "$tmp"
    echo "------------------------------------------------------------"
    exit 0
fi

printf "Digite 'sim' para continuar: "
answer=""
read -r answer || true
if [ "$answer" != "sim" ]; then
    echo "Cancelado. Nada foi alterado."
    exit 1
fi

if dconf load "$DCONF_PATH" <"$tmp"; then
    echo "Configurações restauradas."
    echo "Reinicie o Cinnamon para aplicar:  cinnamon --replace &"
else
    echo "ERRO: 'dconf load' falhou." >&2
    exit 1
fi
