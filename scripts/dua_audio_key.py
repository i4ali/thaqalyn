"""Content-hash key for a dua's Arabic string -> bundled recording file name.

MUST stay byte-identical to the Swift `DuaAudioKey.key(for:)`:
NFC-normalize, trim the same whitespace set, SHA256, first 20 hex chars (lowercase).
"""
import hashlib
import unicodedata

_TRIM = " \t\n\r"


def dua_audio_key(arabic: str) -> str:
    norm = unicodedata.normalize("NFC", arabic).strip(_TRIM)
    return hashlib.sha256(norm.encode("utf-8")).hexdigest()[:20]


if __name__ == "__main__":
    # Sample used to eyeball Swift/Python parity (Task 1 sanity check).
    sample = "اللّٰهُمَّ اشْفِنِي بِشِفَائِكَ وَدَاوِنِي بِدَوَائِكَ وَعَافِنِي مِنْ بَلَائِكَ"
    print(dua_audio_key(sample))
