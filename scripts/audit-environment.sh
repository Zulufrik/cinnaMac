#!/usr/bin/env bash
# Auditoria de conflitos do ambiente Cinnamon.
#
# Somente leitura: não altera nada. Compara o que o Cinnamon aplica (gsettings)
# com o que os apps leem por conta própria (settings.ini, .gtkrc-2.0), checa
# temas/ícones/cursores inexistentes, variáveis de Qt brigando, wallpaper
# apontando para arquivo que não existe e atalhos com Exec quebrado.
#
# Uso: scripts/audit-environment.sh
set -uo pipefail

warn=0
ok=0
fail=0

pass() { ok=$((ok+1)); printf '  [ok]   %s\n' "$1"; }
note() { warn=$((warn+1)); printf '  [aviso] %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  [erro] %s\n' "$1"; }

has_dir() {
    local name="$1" d
    for d in "$HOME/.themes" "$HOME/.local/share/themes" /usr/share/themes \
             "$HOME/.icons" "$HOME/.local/share/icons" /usr/share/icons; do
        [ -d "$d/$name" ] && return 0
    done
    return 1
}

gs() { gsettings get "$1" "$2" 2>/dev/null | tr -d "'"; }
ini() { sed -n "s/^$2=//p" "$1" 2>/dev/null | head -1; }

echo "============================================================"
echo "  Auditoria do ambiente Cinnamon"
echo "============================================================"

echo
echo "== Tema, ícones, fonte e cursor =="
for pair in \
    "org.cinnamon.desktop.interface gtk-theme:gtk-theme-name" \
    "org.cinnamon.desktop.interface icon-theme:gtk-icon-theme-name" \
    "org.cinnamon.desktop.interface font-name:gtk-font-name" \
    "org.cinnamon.desktop.interface cursor-theme:gtk-cursor-theme-name"; do
    schema=${pair%% *}; key=${pair#* }; gkey=${key%%:*}; ikey=${key##*:}
    value=$(gs "$schema" "$gkey")
    for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
        [ -f "$f" ] || continue
        iv=$(ini "$f" "$ikey")
        if [ -n "$iv" ] && [ "$iv" != "$value" ]; then
            note "$(basename "$(dirname "$f")")/settings.ini: $ikey=$iv (gsettings=$value)"
        fi
    done
    case "$gkey" in
        font-name) pass "$gkey = $value" ;;
        *) if has_dir "$value"; then pass "$gkey = $value"; else bad "$gkey = $value (não encontrado)"; fi ;;
    esac
done

echo
echo "== Animações =="
if [ "$(gs org.cinnamon.desktop.interface enable-animations)" = "false" ]; then
    pass "animações desligadas no gsettings"
else
    note "animações ligadas no gsettings"
fi
for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    [ -f "$f" ] || continue
    [ "$(ini "$f" gtk-enable-animations)" = "true" ] && \
        note "$(basename "$(dirname "$f")")/settings.ini ainda liga animações"
done

echo
echo "== GTK2 (~/.gtkrc-2.0) =="
if [ -f "$HOME/.gtkrc-2.0" ]; then
    t=$(sed -n 's/^gtk-theme-name="\(.*\)"$/\1/p' "$HOME/.gtkrc-2.0" | head -1)
    i=$(sed -n 's/^gtk-icon-theme-name="\(.*\)"$/\1/p' "$HOME/.gtkrc-2.0" | head -1)
    [ -n "$t" ] && { has_dir "$t" && pass "gtkrc-2.0 tema = $t" || bad "gtkrc-2.0 tema = $t (não encontrado)"; }
    [ -n "$i" ] && { has_dir "$i" && pass "gtkrc-2.0 ícones = $i" || bad "gtkrc-2.0 ícones = $i (não encontrado)"; }
fi

echo
echo "== Variável de tema dos apps Qt =="
eff="${QT_QPA_PLATFORMTHEME:-}"
[ -n "$eff" ] && pass "QT_QPA_PLATFORMTHEME=$eff" || note "QT_QPA_PLATFORMTHEME não definida"
for f in "$HOME/.config/environment.d"/*.conf; do
    [ -f "$f" ] || continue
    v=$(sed -n 's/^QT_QPA_PLATFORMTHEME=//p' "$f" | head -1)
    [ -n "$v" ] && { [ "$v" = "$eff" ] && pass "environment.d: $v" || note "environment.d diz $v, shell diz $eff"; }
done
for f in /etc/profile.d/*qt*.sh; do
    [ -f "$f" ] || continue
    v=$(sed -n "s/.*QT_QPA_PLATFORMTHEME=['\"]\{0,1\}\([^'\"]*\)['\"]\{0,1\}.*/\1/p" "$f" | head -1)
    [ -n "$v" ] && [ "$v" != "$eff" ] && note "$f força $v"
done

echo
echo "== Kvantum (se usado) =="
if [ -f "$HOME/.config/Kvantum/kvantum.kvconfig" ]; then
    kt=$(sed -n 's/^theme=//p' "$HOME/.config/Kvantum/kvantum.kvconfig" | head -1)
    if [ -n "$kt" ]; then
        found=0
        for d in "$HOME/.config/Kvantum" /usr/share/Kvantum; do [ -d "$d/$kt" ] && found=1; done
        [ "$found" -eq 1 ] && pass "tema Kvantum = $kt" || bad "tema Kvantum = $kt (não encontrado)"
    fi
fi

echo
echo "== Wallpaper =="
uri=$(gs org.cinnamon.desktop.background picture-uri)
path=${uri#file://}
if [ -n "$path" ] && [ -f "$path" ]; then pass "wallpaper existe: $path"; else bad "wallpaper ausente: $path"; fi

echo
echo "== Atalhos com Exec quebrado =="
broken=0
for f in "$HOME/.local/share/applications"/*.desktop; do
    [ -f "$f" ] || continue
    grep -q '^Hidden=true' "$f" && continue
    while IFS= read -r line; do
        cmd=${line#Exec=}; cmd=${cmd%% *}; cmd=${cmd#\"}; cmd=${cmd%\"}
        case "$cmd" in env|sh|bash|flatpak|/usr/bin/env|"") continue;; esac
        if ! command -v "$cmd" >/dev/null 2>&1 && [ ! -x "$cmd" ]; then
            note "$(basename "$f"): Exec=$cmd (não encontrado)"; broken=$((broken+1))
        fi
    done < <(grep -h '^Exec=' "$f" 2>/dev/null | sort -u)
done
[ "$broken" -eq 0 ] && pass "nenhum atalho quebrado"

echo
echo "== Módulos GTK referenciados =="
for f in "$HOME/.config/gtk-3.0/settings.ini"; do
    [ -f "$f" ] || continue
    mods=$(ini "$f" gtk-modules)
    [ -z "$mods" ] && { pass "nenhum gtk-modules customizado"; continue; }
    IFS=':' read -ra list <<< "$mods"
    for m in "${list[@]}"; do
        if find /usr/lib64/gtk-3.0/modules /usr/lib/gtk-3.0/modules -name "lib${m}.so" 2>/dev/null | grep -q .; then
            pass "módulo $m"
        else
            bad "módulo $m referenciado mas ausente"
        fi
    done
done

echo
echo "== LibreOffice =="
if command -v libreoffice >/dev/null 2>&1; then
    if [ -f /usr/lib64/libreoffice/program/libvclplug_gtk3lo.so ] || \
       [ -f /usr/lib/libreoffice/program/libvclplug_gtk3lo.so ]; then
        pass "backend GTK3 instalado"
    else
        bad "backend GTK3 ausente (rode scripts/fix-libreoffice-gtk3.sh)"
    fi
fi

echo
echo "============================================================"
printf '  %d ok, %d avisos, %d erros\n' "$ok" "$warn" "$fail"
echo "============================================================"
[ "$fail" -eq 0 ]
