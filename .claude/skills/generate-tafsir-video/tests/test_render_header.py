import sys
from pathlib import Path
import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from render_header import render_header  # noqa: E402

ASSETS = Path(__file__).resolve().parent.parent / "assets"
FONT = ASSETS / "fonts" / "header.ttf"


@pytest.mark.skipif(not FONT.exists(), reason="Header font not yet provided")
def test_render_header_dimensions(tmp_path):
    out = tmp_path / "h.png"
    render_header("AL-BAQARA", 258, output_path=out, font_path=FONT)
    img = Image.open(out)
    assert img.size == (1080, 260)
    assert img.mode == "RGBA"


@pytest.mark.skipif(not FONT.exists(), reason="Header font not yet provided")
def test_render_header_has_visible_pixels(tmp_path):
    out = tmp_path / "h.png"
    render_header("AL-BAQARA", 258, output_path=out, font_path=FONT)
    img = Image.open(out)
    alpha = img.getchannel("A")
    nonzero = sum(1 for p in alpha.getdata() if p > 0)
    assert nonzero > 5000, "Header looks empty — text not rendered"
