#!/usr/bin/env python3

import sys
import os
import json
import math
import subprocess
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageEnhance, ImageFilter
import pytesseract


ROOT = Path(__file__).resolve().parent


def load_bgr(path):
    img = cv2.imread(str(path), cv2.IMREAD_COLOR)
    if img is None:
        raise RuntimeError(f"Não foi possível abrir: {path}")
    return img


def save_bgr(path, img):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    if not cv2.imwrite(str(path), img):
        raise RuntimeError(f"Não foi possível salvar: {path}")


# ------------------------------------------------------------
# MELHORAR AUTOMATICAMENTE
# ------------------------------------------------------------

def auto_enhance(inp, out):
    """
    Melhoria fotográfica natural.

    Objetivo:
    - recuperar detalhes sem estourar contraste
    - clarear sombras suavemente
    - preservar pele
    - evitar aparência HDR/artificial
    """

    img = load_bgr(inp)

    # --------------------------------------------------------
    # 1. CONTRASTE LOCAL SUAVE
    # --------------------------------------------------------
    lab = cv2.cvtColor(
        img,
        cv2.COLOR_BGR2LAB
    )

    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(
        clipLimit=1.35,
        tileGridSize=(8, 8)
    )

    improved_l = clahe.apply(l)

    enhanced = cv2.merge(
        (improved_l, a, b)
    )

    enhanced = cv2.cvtColor(
        enhanced,
        cv2.COLOR_LAB2BGR
    )

    # Usa só parte do efeito.
    result = cv2.addWeighted(
        img,
        0.62,
        enhanced,
        0.38,
        0
    )

    # --------------------------------------------------------
    # 2. NITIDEZ LEVE
    # --------------------------------------------------------
    blur = cv2.GaussianBlur(
        result,
        (0, 0),
        1.15
    )

    result = cv2.addWeighted(
        result,
        1.12,
        blur,
        -0.12,
        0
    )

    # --------------------------------------------------------
    # 3. SATURAÇÃO MUITO DISCRETA
    # --------------------------------------------------------
    hsv = cv2.cvtColor(
        result,
        cv2.COLOR_BGR2HSV
    ).astype(np.float32)

    hsv[:, :, 1] *= 1.035

    hsv[:, :, 1] = np.clip(
        hsv[:, :, 1],
        0,
        255
    )

    result = cv2.cvtColor(
        hsv.astype(np.uint8),
        cv2.COLOR_HSV2BGR
    )

    save_bgr(out, result)


# ------------------------------------------------------------
# REDUZIR RUÍDO
# ------------------------------------------------------------

def denoise(inp, out):
    img = load_bgr(inp)

    result = cv2.fastNlMeansDenoisingColored(
        img,
        None,
        6,
        6,
        7,
        21
    )

    save_bgr(out, result)


# ------------------------------------------------------------
# FOTO ESCURA
# ------------------------------------------------------------

def low_light(inp, out):
    img = load_bgr(inp)

    lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(
        clipLimit=3.0,
        tileGridSize=(8, 8)
    )

    l = clahe.apply(l)

    result = cv2.merge((l, a, b))
    result = cv2.cvtColor(
        result,
        cv2.COLOR_LAB2BGR
    )

    gamma = 0.82
    table = np.array([
        ((i / 255.0) ** gamma) * 255
        for i in np.arange(256)
    ]).astype("uint8")

    result = cv2.LUT(result, table)

    save_bgr(out, result)


# ------------------------------------------------------------
# RESTAURAR FOTO
# ------------------------------------------------------------

def restore_photo(inp, out):
    img = load_bgr(inp)

    den = cv2.fastNlMeansDenoisingColored(
        img, None, 7, 7, 7, 21
    )

    lab = cv2.cvtColor(
        den,
        cv2.COLOR_BGR2LAB
    )

    l, a, b = cv2.split(lab)

    clahe = cv2.createCLAHE(
        clipLimit=2.2,
        tileGridSize=(8, 8)
    )

    l = clahe.apply(l)

    result = cv2.merge((l, a, b))

    result = cv2.cvtColor(
        result,
        cv2.COLOR_LAB2BGR
    )

    blur = cv2.GaussianBlur(
        result,
        (0, 0),
        1.2
    )

    result = cv2.addWeighted(
        result,
        1.45,
        blur,
        -0.45,
        0
    )

    save_bgr(out, result)


# ------------------------------------------------------------
# MELHORAR ROSTOS
# ------------------------------------------------------------

def enhance_faces(inp, out):
    img = load_bgr(inp)

    gray = cv2.cvtColor(
        img,
        cv2.COLOR_BGR2GRAY
    )

    cascade_path = (
        cv2.data.haarcascades
        + "haarcascade_frontalface_default.xml"
    )

    detector = cv2.CascadeClassifier(
        cascade_path
    )

    faces = detector.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(60, 60)
    )

    result = img.copy()

    for x, y, w, h in faces:
        roi = result[y:y+h, x:x+w]

        smooth = cv2.bilateralFilter(
            roi,
            5,
            20,
            20
        )

        blur = cv2.GaussianBlur(
            smooth,
            (0, 0),
            1.0
        )

        sharpen = cv2.addWeighted(
            smooth,
            1.35,
            blur,
            -0.35,
            0
        )

        result[y:y+h, x:x+w] = sharpen

    save_bgr(out, result)


# ------------------------------------------------------------
# DESFOCAR ROSTOS
# ------------------------------------------------------------

def blur_faces(inp, out):
    img = load_bgr(inp)

    gray = cv2.cvtColor(
        img,
        cv2.COLOR_BGR2GRAY
    )

    detector = cv2.CascadeClassifier(
        cv2.data.haarcascades
        + "haarcascade_frontalface_default.xml"
    )

    faces = detector.detectMultiScale(
        gray,
        1.1,
        5,
        minSize=(40, 40)
    )

    result = img.copy()

    for x, y, w, h in faces:
        roi = result[y:y+h, x:x+w]

        k = max(31, int(min(w, h) / 3))

        if k % 2 == 0:
            k += 1

        result[y:y+h, x:x+w] = (
            cv2.GaussianBlur(
                roi,
                (k, k),
                0
            )
        )

    save_bgr(out, result)


# ------------------------------------------------------------
# OCR
# ------------------------------------------------------------

def ocr(inp):
    image = Image.open(inp)

    text = pytesseract.image_to_string(
        image,
        lang="por"
    )

    print(text)


# ------------------------------------------------------------
# RECORTE INTELIGENTE
# ------------------------------------------------------------

def smart_crop(inp, out, ratio="4:5"):
    img = load_bgr(inp)

    h, w = img.shape[:2]

    try:
        rw, rh = [
            float(x)
            for x in ratio.split(":")
        ]

        target = rw / rh

    except Exception:
        target = 4 / 5

    gray = cv2.cvtColor(
        img,
        cv2.COLOR_BGR2GRAY
    )

    detector = cv2.CascadeClassifier(
        cv2.data.haarcascades
        + "haarcascade_frontalface_default.xml"
    )

    faces = detector.detectMultiScale(
        gray,
        1.1,
        5,
        minSize=(40, 40)
    )

    if len(faces):
        x, y, fw, fh = max(
            faces,
            key=lambda v: v[2] * v[3]
        )

        cx = x + fw / 2
        cy = y + fh / 2

    else:
        cx = w / 2
        cy = h / 2

    if w / h > target:
        ch = h
        cw = int(h * target)
    else:
        cw = w
        ch = int(w / target)

    left = int(
        max(
            0,
            min(
                w - cw,
                cx - cw / 2
            )
        )
    )

    top = int(
        max(
            0,
            min(
                h - ch,
                cy - ch / 2
            )
        )
    )

    crop = img[
        top:top+ch,
        left:left+cw
    ]

    save_bgr(out, crop)


# ------------------------------------------------------------
# ASSINATURA VISUAL PARA BUSCA DE IMAGENS PARECIDAS
# ------------------------------------------------------------

def dhash(path):
    img = cv2.imread(
        str(path),
        cv2.IMREAD_GRAYSCALE
    )

    if img is None:
        return None

    img = cv2.resize(
        img,
        (9, 8)
    )

    diff = img[:, 1:] > img[:, :-1]

    value = 0

    for bit in diff.flatten():
        value = (value << 1) | int(bit)

    return value


def similar_images(inp, folder):
    reference = dhash(inp)

    if reference is None:
        raise RuntimeError(
            "Imagem de referência inválida."
        )

    items = []

    extensions = {
        ".jpg", ".jpeg", ".png",
        ".webp", ".bmp",
        ".tif", ".tiff"
    }

    for path in Path(folder).iterdir():

        if path.suffix.lower() not in extensions:
            continue

        value = dhash(path)

        if value is None:
            continue

        distance = (
            reference ^ value
        ).bit_count()

        items.append(
            (distance, str(path))
        )

    items.sort(
        key=lambda x: x[0]
    )

    print(
        json.dumps(
            [
                {
                    "distance": d,
                    "path": p
                }
                for d, p in items[:30]
            ],
            ensure_ascii=False
        )
    )


# ------------------------------------------------------------
# REAL-ESRGAN
# ------------------------------------------------------------

def upscale(inp, out, scale="2"):
    candidates = list(
        (
            ROOT
            / "engines"
            / "realesrgan"
            / "extracted"
        ).rglob(
            "realesrgan-ncnn-vulkan"
        )
    )

    if not candidates:
        raise RuntimeError(
            "Real-ESRGAN não encontrado."
        )

    binary = candidates[0]

    cmd = [
        str(binary),
        "-i", str(inp),
        "-o", str(out),
        "-s", str(scale)
    ]

    result = subprocess.run(
        cmd,
        cwd=str(binary.parent),
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        raise RuntimeError(
            result.stderr
            or result.stdout
            or "Falha no Real-ESRGAN"
        )


def main():
    if len(sys.argv) < 3:
        print(
            "Uso: vision_ai.py ACAO INPUT [OUTPUT] [PARAM]"
        )
        return 2

    action = sys.argv[1]
    inp = Path(sys.argv[2])

    if action == "ocr":
        ocr(inp)
        return 0

    if action == "similar":
        if len(sys.argv) < 4:
            raise RuntimeError(
                "Informe a pasta."
            )

        similar_images(
            inp,
            sys.argv[3]
        )

        return 0

    if len(sys.argv) < 4:
        raise RuntimeError(
            "Arquivo de saída ausente."
        )

    out = Path(sys.argv[3])

    if action == "auto":
        auto_enhance(inp, out)

    elif action == "denoise":
        denoise(inp, out)

    elif action == "lowlight":
        low_light(inp, out)

    elif action == "restore":
        restore_photo(inp, out)

    elif action == "face":
        enhance_faces(inp, out)

    elif action == "blurfaces":
        blur_faces(inp, out)

    elif action == "crop":
        ratio = (
            sys.argv[4]
            if len(sys.argv) > 4
            else "4:5"
        )

        smart_crop(
            inp,
            out,
            ratio
        )

    elif action == "upscale":
        scale = (
            sys.argv[4]
            if len(sys.argv) > 4
            else "2"
        )

        upscale(
            inp,
            out,
            scale
        )

    else:
        raise RuntimeError(
            f"Ação desconhecida: {action}"
        )

    print(
        f"===== ARNVIEW VISION OK: {action} ====="
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
