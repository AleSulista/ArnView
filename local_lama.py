#!/usr/bin/env python3

import sys
from pathlib import Path

import cv2
import numpy as np

from iopaint.model.lama import LaMa
from iopaint.schema import InpaintRequest


def main():
    if len(sys.argv) != 4:
        print("Uso: local_lama.py INPUT MASK OUTPUT", file=sys.stderr)
        return 2

    input_path = Path(sys.argv[1])
    mask_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3])

    image_bgr = cv2.imread(str(input_path), cv2.IMREAD_COLOR)
    mask = cv2.imread(str(mask_path), cv2.IMREAD_GRAYSCALE)

    if image_bgr is None:
        raise RuntimeError("Falha ao abrir a imagem.")
    if mask is None:
        raise RuntimeError("Falha ao abrir a máscara.")

    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)

    if mask.shape[:2] != image_rgb.shape[:2]:
        mask = cv2.resize(mask, (image_rgb.shape[1], image_rgb.shape[0]), interpolation=cv2.INTER_NEAREST)

    mask = np.where(mask > 127, 255, 0).astype(np.uint8)
    lama = LaMa("cpu")
    config = InpaintRequest()
    result_bgr = lama(image_rgb, mask, config)

    if isinstance(result_bgr, tuple):
        result_bgr = result_bgr[0]

    result_bgr = np.asarray(result_bgr)
    if result_bgr.ndim != 3 or result_bgr.shape[2] != 3:
        raise RuntimeError(f"Saída inválida do LaMa: {result_bgr.shape}")

    output_path.parent.mkdir(parents=True, exist_ok=True)
    if not cv2.imwrite(str(output_path), result_bgr):
        raise RuntimeError("Não foi possível salvar a imagem resultante.")

    print("===== LAMA LOCAL OK - CORES CORRETAS =====")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
