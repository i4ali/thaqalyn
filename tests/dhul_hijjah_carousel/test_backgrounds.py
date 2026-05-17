from PIL import Image
from scripts.dhul_hijjah_carousel import backgrounds, config


def test_normalize_crops_and_resizes_to_canvas():
    wide = Image.new("RGB", (2000, 1000), (10, 10, 10))
    out = backgrounds.normalize(wide)
    assert out.size == (config.CANVAS_W, config.CANVAS_H)
    assert out.mode == "RGB"


def test_normalize_tall_image():
    tall = Image.new("RGB", (1000, 4000), (10, 10, 10))
    out = backgrounds.normalize(tall)
    assert out.size == (config.CANVAS_W, config.CANVAS_H)


def test_build_bg_prompt_includes_shared_style_and_no_text_rule():
    p = backgrounds.build_bg_prompt(config.SLIDES[0])
    assert "Kaaba" in p
    assert "no text" in p.lower()
    assert config.BG_STYLE in p
