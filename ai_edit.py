#!/usr/bin/env python3
import sys
from pathlib import Path

from huggingface_hub import InferenceClient


def main():
    if len(sys.argv) < 5:
        print("Uso: ai_edit.py TOKEN INPUT OUTPUT PROMPT", file=sys.stderr)
        return 2

    token = sys.argv[1]
    input_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3])
    prompt = sys.argv[4]

    if not input_path.exists():
        print("Imagem de entrada não encontrada.", file=sys.stderr)
        return 3

    client = InferenceClient(
        provider="fal-ai",
        api_key=token,
    )

    try:
        with input_path.open("rb") as f:
            image_bytes = f.read()

        # ArnView - modo de preservação forte
        #
        # O usuário escreve apenas a alteração desejada.
        # Acrescentamos instruções para reduzir alterações
        # desnecessárias na identidade e no restante da foto.
        protected_prompt = f"""
EDIT INSTRUCTION:
{prompt}

STRICT PRESERVATION RULES:
Perform only the requested modification.

Preserve the person's identity as faithfully as possible.
Do not redesign or reinterpret the face.

Unless explicitly requested, preserve:
- facial structure
- face shape
- eyes and eye color
- eyebrows
- nose
- mouth and lips
- ears
- skin tone and skin texture
- expression
- age
- hairstyle and hair color
- body proportions
- pose
- hands
- clothing
- accessories
- lighting
- shadows
- camera angle
- framing
- image composition
- background

Keep all unrequested areas as close as possible to the
original image.

Do not beautify the person.
Do not make the person younger or older.
Do not replace the person with a similar-looking person.
Do not change gender or ethnicity.
Do not change facial proportions.

Apply the requested edit locally and minimally.
"""

        result = client.image_to_image(
            image_bytes,
            prompt=protected_prompt,
            model="Qwen/Qwen-Image-Edit",
        )

        result.save(output_path, format="PNG")
        print("OK")
        return 0

    except Exception as e:
        print(str(e), file=sys.stderr)
        return 10


if __name__ == "__main__":
    raise SystemExit(main())
