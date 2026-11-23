#!/usr/bin/python3
"""Gera e instala o logo Apple branco para o menu Cinnamenu e o greeter LightDM.

Requisitos: Pillow (pip install pillow) e rodar como root (pkexec).
A imagem fonte deve ser colocada em assets/apple-logo-source.png
"""

import os
import shutil
import subprocess
import sys
from PIL import Image

SRC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "apple-logo-source.png")
SRC = os.path.abspath(SRC)
PIXMAP = "/usr/share/pixmaps/apple-logo.png"
HICOLOR = "/usr/share/icons/hicolor/256x256/apps/apple-logo.png"
GREETER_CONF = "/etc/lightdm/slick-greeter.conf"


def make_logo():
    im = Image.open(SRC).convert("RGBA")
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    side = max(im.size)
    pad = int(side * 0.08)
    canvas = Image.new("RGBA", (side + pad * 2, side + pad * 2), (0, 0, 0, 0))
    canvas.paste(im, ((canvas.width - im.width) // 2, (canvas.height - im.height) // 2), im)
    canvas = canvas.resize((256, 256), Image.LANCZOS)
    return canvas


def main():
    if os.geteuid() != 0:
        sys.exit("Rode como root (pkexec).")

    if not os.path.exists(SRC):
        sys.exit(f"Imagem fonte não encontrada: {SRC}\nColoque o logo da Apple em assets/apple-logo-source.png")

    logo = make_logo()
    os.makedirs(os.path.dirname(PIXMAP), exist_ok=True)
    os.makedirs(os.path.dirname(HICOLOR), exist_ok=True)
    logo.save(PIXMAP)
    logo.save(HICOLOR)
    os.chmod(PIXMAP, 0o644)
    os.chmod(HICOLOR, 0o644)
    print("Instalado:", PIXMAP)
    print("Instalado:", HICOLOR)

    subprocess.run(["gtk-update-icon-cache", "-f", "-t", "/usr/share/icons/hicolor"], check=False)

    # Atualiza/insere logo= no slick-greeter.conf
    lines = []
    if os.path.exists(GREETER_CONF):
        with open(GREETER_CONF) as fh:
            lines = fh.read().splitlines()
    lines = [ln for ln in lines if not ln.startswith("logo=")]
    try:
        idx = lines.index("[Greeter]") + 1
    except ValueError:
        lines.insert(0, "[Greeter]")
        idx = 1
    lines.insert(idx, "logo=" + PIXMAP)
    with open(GREETER_CONF, "w") as fh:
        fh.write("\n".join(lines) + "\n")
    print("Greeter logo configurado em", GREETER_CONF)
    return 0


if __name__ == "__main__":
    sys.exit(main())
