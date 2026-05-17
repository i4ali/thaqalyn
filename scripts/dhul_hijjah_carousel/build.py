"""Build the 5-slide Dhul-Hijjah carousel: backgrounds -> compose -> save."""
import sys

from PIL import Image

from . import backgrounds, compose, config


def main(skip_bg: bool = False):
    config.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Hard gate: slide 2 Arabic must be verified before any render
    s2 = next(s for s in config.SLIDES if s["index"] == 2)
    if s2.get("arabic") and not s2.get("arabic_verified"):
        raise SystemExit("ABORT: Slide 2 Arabic not user-verified (see Task 3).")

    if not skip_bg:
        print("Generating backgrounds (Nano Banana)...")
        backgrounds.generate_all()

    for slide in config.SLIDES:
        bg_path = config.BG_DIR / f"bg_{slide['index']}.png"
        if not bg_path.exists():
            raise SystemExit(f"Missing background: {bg_path}")
        bg = Image.open(bg_path)
        if slide.get("app_screenshot"):
            out = compose.render_appshot(slide, bg)
        elif slide["role"] == "cta":
            out = compose.render_cta(slide, bg)
        else:
            out = compose.render_slide(slide, bg)
        dest = config.OUTPUT_DIR / f"slide_{slide['index']}.png"
        out.save(dest)
        print(f"  saved {dest}")
    print("Done. 5 slides in", config.OUTPUT_DIR)


if __name__ == "__main__":
    main(skip_bg="--skip-bg" in sys.argv)
