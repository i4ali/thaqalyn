from scripts.dhul_hijjah_carousel import config


def test_canvas_is_4x5_portrait():
    assert config.CANVAS_W == 1080
    assert config.CANVAS_H == 1350


def test_five_slides_defined_in_order():
    slides = config.SLIDES
    assert [s["index"] for s in slides] == [1, 2, 3, 4, 5]
    roles = [s["role"] for s in slides]
    assert roles == ["hook", "pillar", "pillar", "pillar", "cta"]


def test_every_slide_has_required_fields():
    for s in config.SLIDES:
        assert s["headline"], f"slide {s['index']} missing headline"
        assert s["bg_prompt"], f"slide {s['index']} missing bg_prompt"
        if s.get("arabic"):
            assert s["index"] == 2
            assert s["arabic_verified"] in (True, False)


def test_fonts_exist():
    import os
    assert os.path.exists(config.FONT_ARABIC)
    assert os.path.exists(config.FONT_DISPLAY)


def test_slide2_arabic_must_be_verified_before_render():
    s2 = next(s for s in config.SLIDES if s["index"] == 2)
    if s2["arabic"]:
        assert s2["arabic_verified"] is True, (
            "Slide 2 Arabic present but not user-verified — render must not proceed"
        )
