#!/usr/bin/python3
"""Remove a herança do tema Breeze do WhiteSur (útil após remover o KDE).

Rode como root (pkexec) ou como usuário para os temas em ~/.local/share/icons.
"""

import os
import sys

TARGETS = [
    "/usr/share/icons/WhiteSur/index.theme",
    "/usr/share/icons/WhiteSur-dark/index.theme",
    os.path.expanduser("~/.local/share/icons/WhiteSur/index.theme"),
    os.path.expanduser("~/.local/share/icons/WhiteSur-dark/index.theme"),
]


def main():
    changed = False
    for path in TARGETS:
        if not os.path.exists(path):
            continue
        with open(path) as fh:
            content = fh.read()
        new = content.replace("Inherits=hicolor,breeze", "Inherits=hicolor,Adwaita")
        if new != content:
            with open(path, "w") as fh:
                fh.write(new)
            print("Atualizado:", path)
            changed = True
    if not changed:
        print("Nenhum arquivo precisou de ajuste.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
