#!/usr/bin/env bash
# Salva as configurações do Cinnamon (dconf /org/cinnamon/) em backup/cinnamon.dconf.
#
# Uso: scripts/backup-cinnamon.sh [arquivo-de-saida]
#
# - Não usa sudo.
# - Não envia nada para a internet.
# - Remove histórico de comandos e a última localização do night light.
# - Troca o caminho da sua home por __HOME__ para não versionar o nome de usuário.
set -euo pipefail

if ! command -v dconf >/dev/null 2>&1; then
    echo "ERRO: 'dconf' não está instalado." >&2
    echo "       Linux Mint / Debian: sudo apt install dconf-cli" >&2
    echo "       openSUSE:            sudo zypper install dconf" >&2
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DCONF_PATH="/org/cinnamon/"
OUT="${1:-$REPO_ROOT/backup/cinnamon.dconf}"

mkdir -p "$(dirname "$OUT")"
tmp="$(mktemp)"
clean="$(mktemp)"
trap 'rm -f "$tmp" "$clean"' EXIT

if ! dconf dump "$DCONF_PATH" >"$tmp"; then
    echo "ERRO: falha ao executar 'dconf dump $DCONF_PATH'." >&2
    exit 1
fi

# Remove dados de histórico e localização (não devem ir para um repo público).
awk '
    /^command-history=/              { next }
    /^night-light-last-coordinates=/ { next }
    { print }
' "$tmp" >"$clean"

# Substitui o caminho da home por um marcador neutro.
sed "s|${HOME}|__HOME__|g" "$clean" >"$OUT"

echo "Backup salvo em: $OUT"
echo "Linhas: $(wc -l <"$OUT" | tr -d ' ')"

# Aviso caso o nome de usuário ainda apareça em algum valor.
me="$(id -un)"
if grep -qF "$me" "$OUT" 2>/dev/null; then
    echo "AVISO: o nome de usuário ainda aparece em alguns valores." >&2
    echo "       Revise o arquivo antes de publicar." >&2
fi

echo
echo "Revise antes de commitar:"
echo "  git diff -- backup/cinnamon.dconf"
