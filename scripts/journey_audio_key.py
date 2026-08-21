"""Content-hash key for a journey narration string -> bundled recording file name.

MUST stay byte-identical to the Swift `JourneyAudioKey.key(for:)`:
NFC-normalize, trim the same whitespace set, SHA256, first 20 hex chars (lowercase).
"""
import hashlib
import unicodedata

_TRIM = " \t\n\r"


def journey_audio_key(text: str) -> str:
    norm = unicodedata.normalize("NFC", text).strip(_TRIM)
    return hashlib.sha256(norm.encode("utf-8")).hexdigest()[:20]


if __name__ == "__main__":
    # Sample used to eyeball Swift/Python parity (Task 1 sanity check).
    sample = "Certainty is not the absence of doubt."
    print(journey_audio_key(sample))
