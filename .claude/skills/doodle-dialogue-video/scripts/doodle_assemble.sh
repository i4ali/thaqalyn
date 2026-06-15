#!/usr/bin/env bash
# Assemble a doodle-dialogue video — concept-agnostic, any number of beats.
#
#   doodle_assemble.sh <base-dir>
#
# Reads $BASE/work/segments.txt — one ordered beat per line:  filename|seconds
#   filename is relative to $BASE/work/ and may be:
#     - a talking clip from doodle_talk.py  (e.g. talk_seg4.mp4)
#     - a still .png for a static beat       (looped to a clip)
#   Each is normalized to 1080x1920 @30fps and trimmed to its exact seconds so
#   it stays in sync with the audio and captions.
#
# Audio:    $BASE/inputs/audio.*  (REQUIRED — pre-mixed voices + SFX; see SKILL.md)
# Captions: burns $BASE/work/captions.ass if present (10-field Format line!).
# Output:   $BASE/final.mp4
#
# NOTE: every ffmpeg uses -nostdin. Without it, the ffmpeg inside the while-read
# loop eats the loop's stdin and later filenames get mangled (seg6 -> eg6).
set -euo pipefail
BASE="${1:?usage: doodle_assemble.sh <base-dir>}"
W=1080; H=1920
SEG="$BASE/work/segments.txt"
[ -f "$SEG" ] || { echo "missing $SEG"; exit 1; }

norm () {  # $1 in  $2 seconds  $3 out
  local loop=""
  case "$1" in *.png|*.jpg|*.jpeg) loop="-loop 1";; esac
  ffmpeg -nostdin -y -loglevel error $loop -i "$1" -t "$2" \
    -vf "scale=$W:$H:force_original_aspect_ratio=increase,crop=$W:$H,fps=30" \
    -an -c:v libx264 -pix_fmt yuv420p "$3"
}

: > "$BASE/work/_concat.txt"
i=0
while IFS='|' read -r fn dur; do
  [ -z "${fn:-}" ] && continue
  case "$fn" in \#*) continue;; esac
  norm "$BASE/work/$fn" "$dur" "$BASE/work/_n$i.mp4"
  echo "file '_n$i.mp4'" >> "$BASE/work/_concat.txt"
  i=$((i+1))
done < "$SEG"

ffmpeg -nostdin -y -loglevel error -f concat -safe 0 -i "$BASE/work/_concat.txt" \
  -c:v libx264 -pix_fmt yuv420p "$BASE/work/_joined.mp4"

AUDIO=$(ls "$BASE"/inputs/audio.* 2>/dev/null | head -1 || true)
[ -n "$AUDIO" ] || { echo "missing $BASE/inputs/audio.* (pre-mixed voices + SFX)"; exit 1; }
ffmpeg -nostdin -y -loglevel error -i "$BASE/work/_joined.mp4" -i "$AUDIO" \
  -map 0:v -map 1:a -c:v copy -c:a aac -shortest "$BASE/work/_aud.mp4"

OUT="$BASE/final.mp4"
if [ -f "$BASE/work/captions.ass" ]; then
  ffmpeg -nostdin -y -loglevel error -i "$BASE/work/_aud.mp4" \
    -vf "ass=$BASE/work/captions.ass" -c:v libx264 -pix_fmt yuv420p -c:a copy "$OUT"
else
  cp "$BASE/work/_aud.mp4" "$OUT"
fi

echo "Wrote $OUT"
ffprobe -v error -show_entries stream=width,height,codec_type \
  -show_entries format=duration -of default=nw=1 "$OUT"
