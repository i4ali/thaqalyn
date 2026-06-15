#!/usr/bin/env bash
# Generic UGC ad assembler — concept-agnostic, any number of beats.
#
#   assemble.sh <ad-base-dir>
#
# Reads $BASE/work/segments.txt — one ordered beat per line:
#     filename|seconds
#   (filename is relative to $BASE/work/, already at/near 1080x1920;
#    apply any per-segment overlay e.g. a notification banner BEFORE
#    listing it here, so this stays generic. One-liner for that:
#      ffmpeg -i seg.mp4 -i banner.png -filter_complex \
#       "[1:v]scale=940:-1[b];[0:v][b]overlay=(W-w)/2:H*0.13:enable='between(t,1.6,4)'" \
#       -c:v libx264 -pix_fmt yuv420p seg_with_banner.mp4 )
#
# Audio (first that exists wins):
#   $BASE/inputs/audio.*        -> use as-is (pre-mixed VO/music bed)
#   else low pink-noise room tone; if $BASE/inputs/chime.wav exists it is
#   mixed in, delayed by the value in $BASE/work/chime_at_ms (default 1700)
#
# Captions: burns $BASE/work/captions.ass if present (10-field Format!).
set -euo pipefail
BASE="${1:?usage: assemble.sh <ad-base-dir>}"
W=1080; H=1920
SEG="$BASE/work/segments.txt"
[ -f "$SEG" ] || { echo "missing $SEG"; exit 1; }

norm () {  # $1 in  $2 seconds  $3 out
  ffmpeg -y -loglevel error -i "$1" -t "$2" \
    -vf "scale=$W:$H:force_original_aspect_ratio=increase,crop=$W:$H,fps=30" \
    -an -c:v libx264 -pix_fmt yuv420p "$3"
}

: > "$BASE/work/_concat.txt"
TOTAL=0; i=0
while IFS='|' read -r fn dur; do
  [ -z "${fn:-}" ] && continue
  case "$fn" in \#*) continue;; esac
  out="$BASE/work/_n$i.mp4"
  norm "$BASE/work/$fn" "$dur" "$out"
  echo "file '_n$i.mp4'" >> "$BASE/work/_concat.txt"
  TOTAL=$(awk "BEGIN{print $TOTAL+$dur}"); i=$((i+1))
done < "$SEG"

ffmpeg -y -loglevel error -f concat -safe 0 -i "$BASE/work/_concat.txt" \
  -c:v libx264 -pix_fmt yuv420p "$BASE/work/_joined.mp4"

AUDIO=$(ls "$BASE"/inputs/audio.* 2>/dev/null | head -1 || true)
if [ -n "$AUDIO" ]; then
  ffmpeg -y -loglevel error -i "$BASE/work/_joined.mp4" -i "$AUDIO" \
    -map 0:v -map 1:a -c:v copy -c:a aac -shortest "$BASE/work/_aud.mp4"
else
  CMS=$(cat "$BASE/work/chime_at_ms" 2>/dev/null || echo 1700)
  if [ -f "$BASE/inputs/chime.wav" ]; then
    ffmpeg -y -loglevel error -i "$BASE/work/_joined.mp4" \
      -f lavfi -t "$TOTAL" -i "anoisesrc=c=pink:a=0.010" \
      -i "$BASE/inputs/chime.wav" \
      -filter_complex "[2:a]adelay=${CMS}|${CMS},volume=0.7[c];[1:a][c]amix=inputs=2:duration=first:dropout_transition=0[a]" \
      -map 0:v -map "[a]" -c:v copy -c:a aac -shortest "$BASE/work/_aud.mp4"
  else
    ffmpeg -y -loglevel error -i "$BASE/work/_joined.mp4" \
      -f lavfi -t "$TOTAL" -i "anoisesrc=c=pink:a=0.010" \
      -map 0:v -map 1:a -c:v copy -c:a aac -shortest "$BASE/work/_aud.mp4"
  fi
fi

OUT="$BASE/final-ugc.mp4"
if [ -f "$BASE/work/captions.ass" ]; then
  ffmpeg -y -loglevel error -i "$BASE/work/_aud.mp4" \
    -vf "ass=$BASE/work/captions.ass" \
    -c:v libx264 -pix_fmt yuv420p -c:a copy "$OUT"
else
  cp "$BASE/work/_aud.mp4" "$OUT"
fi

echo "Wrote $OUT"
ffprobe -v error -show_entries stream=width,height,codec_type \
  -show_entries format=duration -of default=nw=1 "$OUT"
