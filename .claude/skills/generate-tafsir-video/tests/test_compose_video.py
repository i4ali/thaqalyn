import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from compose_video import build_drawtext_chain, build_filter_complex  # noqa: E402


def test_drawtext_chain_one_per_word():
    timings = [
        {"word": "Hello", "start": 0.0, "end": 0.5},
        {"word": "world", "start": 0.5, "end": 1.0},
    ]
    chain = build_drawtext_chain(timings, font_path="/x/caption.ttf")
    # one drawtext for the static (muted) line + N enable-gated drawtext for active words
    assert chain.count("drawtext=") == 2 + 1  # 2 active + 1 muted-baseline
    assert "between(t,0.0,0.5)" in chain
    assert "between(t,0.5,1.0)" in chain


def test_filter_complex_overlays_header_and_audio():
    fc = build_filter_complex(
        timings=[{"word": "Hi", "start": 0.0, "end": 0.3}],
        header_path="/tmp/h.png",
        font_path="/x/caption.ttf",
        narration_duration=0.3,
    )
    assert "overlay=" in fc  # header overlay
    assert "drawtext=" in fc  # captions
    assert "trim=duration=0.3" in fc


def test_drawtext_chain_strips_apostrophes_and_quotes():
    # Regression: apostrophes/quotes broke the filter graph layer because
    # drawtext's internal `\'` escape isn't valid in the outer filter chain.
    timings = [
        {"word": "Quran's", "start": 0.0, "end": 0.5},
        {"word": '"Allah', "start": 0.5, "end": 1.0},
        {"word": 'earth"', "start": 1.0, "end": 1.5},
    ]
    chain = build_drawtext_chain(timings, font_path="/x/caption.ttf")
    # Each word should be rendered with its quotes/apostrophes stripped
    assert "text='Qurans'" in chain
    assert "text='Allah'" in chain
    assert "text='earth'" in chain
    # Originals must NOT appear as drawtext text values
    assert "text='Quran's'" not in chain
    assert 'text=\'"Allah\'' not in chain
    assert 'text=\'earth"\'' not in chain


def test_drawtext_chain_skips_pure_punctuation_words():
    # Em-dashes that arrive as standalone "words" from alignment should be
    # dropped, not rendered as bare punctuation captions.
    timings = [
        {"word": "Hello", "start": 0.0, "end": 0.5},
        {"word": "—",     "start": 0.5, "end": 0.55},
        {"word": "world", "start": 0.55, "end": 1.0},
    ]
    chain = build_drawtext_chain(timings, font_path="/x/caption.ttf")
    # 2 real words + 1 baseline = 3 drawtext calls; em-dash skipped
    assert chain.count("drawtext=") == 3
    assert "Hello" in chain
    assert "world" in chain
    assert "—" not in chain
