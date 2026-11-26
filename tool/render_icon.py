"""Desenha o ícone do Wallet Ledger a partir da mesma geometria do BrandMark.

Gera em assets/icon/:
  icon.png             1024x1024, fundo tinta com cantos arredondados (web, README)
  icon_square.png      1024x1024, fundo inteiro (o launcher aplica a máscara)
  icon_foreground.png  1024x1024 transparente, símbolo na zona segura do
                       ícone adaptativo do Android (o fundo é a cor #0F1413)
  splash.png           1024x1024 transparente, só o símbolo (splash nativo)

Uso: python tool/render_icon.py   (precisa do Pillow)
"""

from pathlib import Path

from PIL import Image, ImageDraw

INK = (0x0F, 0x14, 0x13, 255)
MINT = (0x7F, 0xD3, 0xBF, 255)
GROUND = (0xF4, 0xF5, 0xF1, 255)

SIZE = 1024
SS = 4  # supersampling: desenha 4x maior e reduz, para bordas suaves

OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"


def draw_mark(draw: ImageDraw.ImageDraw, size: float, ox: float, oy: float):
    """Três linhas e o ponto, com as proporções de lib/core/widgets/brand_mark.dart."""
    line = size * 0.08
    gap = size * 0.10
    pad = size * 0.227
    inner = size - 2 * pad
    top = oy + (size - (3 * line + 2 * gap)) / 2
    left = ox + pad

    def bar(x, y, w):
        draw.rounded_rectangle((x, y, x + w, y + line), radius=line / 2, fill=MINT)

    bar(left, top, inner)
    bar(left, top + line + gap, inner)

    # Terceira linha: Expanded(flex 307) + espaço 6,5% + ponto + Spacer(flex 245)
    y3 = top + 2 * (line + gap)
    dot_gap = size * 0.065
    flexible = inner - dot_gap - line
    w3 = flexible * 307 / (307 + 245)
    bar(left, y3, w3)
    dx = left + w3 + dot_gap
    draw.ellipse((dx, y3, dx + line, y3 + line), fill=GROUND)


def render(kind: str) -> Image.Image:
    s = SIZE * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    if kind == "rounded":
        d.rounded_rectangle((0, 0, s - 1, s - 1), radius=s * 0.225, fill=INK)
        draw_mark(d, s, 0, 0)
    elif kind == "square":
        d.rectangle((0, 0, s, s), fill=INK)
        draw_mark(d, s, 0, 0)
    else:
        # Adaptativo: a tela de 108dp mostra ~72dp. O símbolo ocupa o "ícone"
        # de 72dp centralizado, então sobra margem para qualquer máscara.
        scale = 72 / 108 if kind == "foreground" else 1.0
        m = s * scale
        draw_mark(d, m, (s - m) / 2, (s - m) / 2)
    return img.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    render("rounded").save(OUT / "icon.png")
    render("square").save(OUT / "icon_square.png")
    render("foreground").save(OUT / "icon_foreground.png")
    render("splash").save(OUT / "splash.png")
    print(f"ícones em {OUT}")


if __name__ == "__main__":
    main()
