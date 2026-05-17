import pytest
from PIL import Image
from scripts.dhul_hijjah_carousel import config

OUTPUTS = [config.OUTPUT_DIR / f"slide_{i}.png" for i in range(1, 6)]


@pytest.mark.parametrize("path", OUTPUTS)
def test_slide_exists_and_is_exact_canvas(path):
    if not path.exists():
        pytest.skip(f"{path} not generated yet (run build.py to produce)")
    with Image.open(path) as im:
        assert im.size == (config.CANVAS_W, config.CANVAS_H)
        assert im.mode == "RGB"
    assert path.stat().st_size > 20_000, "suspiciously small image"
