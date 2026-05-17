from PIL import Image
from scripts.dhul_hijjah_carousel import compose, config


def _blank_bg():
    return Image.new("RGB", (config.CANVAS_W, config.CANVAS_H), (8, 9, 14))


def test_wrap_text_respects_max_width():
    lines = compose.wrap("a " * 60, compose._font(config.FONT_BODY, 40), 800)
    assert len(lines) > 1
    assert all(isinstance(ln, str) for ln in lines)


def test_render_slide_returns_exact_canvas():
    img = compose.render_slide(config.SLIDES[0], _blank_bg())
    assert img.size == (config.CANVAS_W, config.CANVAS_H)
    assert img.mode == "RGB"


def test_render_slide_changes_pixels():
    bg = _blank_bg()
    out = compose.render_slide(config.SLIDES[0], bg.copy())
    assert list(out.getdata()) != list(bg.getdata()), "no text drawn"


def test_arabic_renders_when_present_and_verified():
    slide = dict(config.SLIDES[1])
    slide["arabic"] = "لا إله إلا الله"
    slide["arabic_verified"] = True
    out = compose.render_slide(slide, _blank_bg())
    assert out.size == (config.CANVAS_W, config.CANVAS_H)


def test_render_slide_refuses_unverified_arabic():
    slide = dict(config.SLIDES[1])
    slide["arabic"] = "anything"
    slide["arabic_verified"] = False
    try:
        compose.render_slide(slide, _blank_bg())
        assert False, "should have raised"
    except ValueError as e:
        assert "verified" in str(e).lower()


def test_render_cta_returns_exact_canvas_and_draws():
    bg = Image.new("RGB", (config.CANVAS_W, config.CANVAS_H), (8, 9, 14))
    out = compose.render_cta(config.SLIDES[4], bg.copy())
    assert out.size == (config.CANVAS_W, config.CANVAS_H)
    assert list(out.getdata()) != list(bg.getdata())


def test_render_appshot_returns_canvas_and_draws():
    bg = Image.new("RGB", (config.CANVAS_W, config.CANVAS_H), (8, 9, 14))
    slide = next(s for s in config.SLIDES if s.get("app_screenshot"))
    out = compose.render_appshot(slide, bg.copy())
    assert out.size == (config.CANVAS_W, config.CANVAS_H)
    assert out.mode == "RGB"
    assert list(out.getdata()) != list(bg.getdata())
