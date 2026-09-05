#!/usr/bin/env python3

import os
import sys
from pathlib import Path

import certifi

os.environ["SSL_CERT_FILE"] = certifi.where()
os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()

from PIL import Image
from rembg import remove, new_session


def main():
    if len(sys.argv) != 3:
        print("Uso: remove_bg.py INPUT OUTPUT", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])

    if not source.exists():
        raise RuntimeError("Imagem de entrada não encontrada.")

    print("Carregando IA de remoção de fundo...")
    session = new_session("u2net")
    image = Image.open(source).convert("RGBA")
    result = remove(image, session=session, alpha_matting=False)
    result.save(output, "PNG")
    print("FUNDO REMOVIDO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
