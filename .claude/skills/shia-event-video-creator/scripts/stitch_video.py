#!/usr/bin/env python3
"""
Stitch per-scene video clips + narration MP3s into a single final MP4.

Auto-detects any number of scenes by globbing `<event-dir>/videos/scene_*.mp4`.
Builds a single-pass ffmpeg command with a dynamic filter_complex so there's no
AAC priming drift from multi-pass encoding.

Usage:
    python stitch_video.py --event-dir video_output/aam-al-huzn/
    python stitch_video.py --event-dir <dir> --output my_final.mp4
    python stitch_video.py --event-dir <dir> --no-audio   # silent stitch

Expected directory layout (within --event-dir):
    videos/scene_1.mp4, scene_2.mp4, ...   (required, any count)
    audio/scene_1.mp3, scene_2.mp3, ...    (optional — if missing, silent concat)

For each scene, target duration = max(video_duration, audio_duration). If narration
is longer than the video clip, the last frame of the video is freeze-frame padded.
If video is longer than narration, the audio is silence-padded at the end.

Output:
    <event-dir>/<output>   (default: final.mp4)

Requires: ffmpeg, ffprobe on PATH.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


def ffprobe_duration(path: Path) -> float:
    """Return the duration of a media file in seconds."""
    r = subprocess.run(
        [
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            str(path),
        ],
        capture_output=True, text=True, check=True,
    )
    return float(r.stdout.strip())


def natural_scene_num(path: Path) -> int:
    """Extract the integer N from a filename like 'scene_12.mp4'."""
    m = re.search(r"scene_(\d+)", path.name)
    return int(m.group(1)) if m else 0


def main() -> int:
    ap = argparse.ArgumentParser(description="Single-pass ffmpeg stitch of per-scene clips + narrations.")
    ap.add_argument("--event-dir", required=True, help="Event folder containing videos/ and audio/ subdirs.")
    ap.add_argument("--output", default="final.mp4", help="Output filename (relative to event-dir). Default: final.mp4")
    ap.add_argument("--no-audio", action="store_true", help="Skip narration overlay; concat silent videos only.")
    ap.add_argument("--width", type=int, default=1080, help="Output width (default: 1080).")
    ap.add_argument("--height", type=int, default=1920, help="Output height (default: 1920 for 9:16 TikTok).")
    ap.add_argument("--fps", type=int, default=30, help="Output framerate (default: 30).")
    ap.add_argument("--crf", type=int, default=18, help="H.264 CRF quality (lower = better; default: 18).")
    args = ap.parse_args()

    event_dir = Path(args.event_dir).resolve()
    videos_dir = event_dir / "videos"
    audio_dir = event_dir / "audio"
    output_path = event_dir / args.output

    if not videos_dir.exists():
        print(f"ERROR: {videos_dir} not found.", file=sys.stderr)
        return 1

    # Collect scene videos, sorted by scene number
    video_files = sorted(videos_dir.glob("scene_*.mp4"), key=natural_scene_num)
    if not video_files:
        print(f"ERROR: no scene_*.mp4 files in {videos_dir}", file=sys.stderr)
        return 1

    # Match audio files per scene if --no-audio not set
    include_audio = not args.no_audio
    audio_files: list[Path | None] = []
    if include_audio:
        for v in video_files:
            scene_n = natural_scene_num(v)
            a = audio_dir / f"scene_{scene_n}.mp3"
            if a.exists():
                audio_files.append(a)
            else:
                audio_files.append(None)
        # If NO audio files found at all, degrade to silent stitch
        if all(a is None for a in audio_files):
            print(f"WARNING: no audio files found in {audio_dir}. Stitching silent.", file=sys.stderr)
            include_audio = False
    else:
        audio_files = [None] * len(video_files)

    n = len(video_files)
    print(f"Stitching {n} scene(s) from {event_dir}", file=sys.stderr)

    # Probe durations and compute per-scene timing
    targets: list[dict] = []
    for i, v in enumerate(video_files):
        vdur = ffprobe_duration(v)
        adur = ffprobe_duration(audio_files[i]) if (include_audio and audio_files[i]) else 0.0
        tgt = max(vdur, adur)
        vpad = max(0.0, tgt - vdur)
        apad = max(0.0, tgt - adur)
        targets.append({
            "scene": natural_scene_num(v),
            "video": v, "audio": audio_files[i],
            "vdur": vdur, "adur": adur,
            "target": tgt, "vpad": vpad, "apad": apad,
        })
        print(f"  [scene {targets[-1]['scene']}] v={vdur:.3f}s a={adur:.3f}s → target={tgt:.3f}s (vpad={vpad:.3f}s apad={apad:.3f}s)", file=sys.stderr)

    # Build filter_complex
    # Inputs 0..n-1: videos. If audio: inputs n..2n-1: audios.
    filter_parts: list[str] = []
    scale_pad = (
        f"scale={args.width}:{args.height}:force_original_aspect_ratio=decrease,"
        f"pad={args.width}:{args.height}:(ow-iw)/2:(oh-ih)/2"
    )

    for i, t in enumerate(targets):
        filter_parts.append(
            f"[{i}:v]tpad=stop_mode=clone:stop_duration={t['vpad']:.6f},"
            f"trim=duration={t['target']:.6f},setpts=PTS-STARTPTS,"
            f"fps={args.fps},{scale_pad},format=yuv420p[v{i+1}]"
        )
        if include_audio and t["audio"] is not None:
            audio_idx = n + i
            filter_parts.append(
                f"[{audio_idx}:a]apad=pad_dur={t['apad']:.6f},"
                f"atrim=duration={t['target']:.6f},asetpts=PTS-STARTPTS[a{i+1}]"
            )
        elif include_audio:
            # Synthetic silent audio for this scene so concat stays aligned
            filter_parts.append(
                f"anullsrc=channel_layout=stereo:sample_rate=44100:d={t['target']:.6f}[a{i+1}]"
            )

    # Final concat
    if include_audio:
        concat_inputs = "".join(f"[v{i+1}][a{i+1}]" for i in range(n))
        concat_label = f"{concat_inputs}concat=n={n}:v=1:a=1[vout][aout]"
    else:
        concat_inputs = "".join(f"[v{i+1}]" for i in range(n))
        concat_label = f"{concat_inputs}concat=n={n}:v=1:a=0[vout]"

    filter_parts.append(concat_label)
    filter_complex = ";".join(filter_parts)

    # Build ffmpeg command
    cmd = ["ffmpeg", "-y"]
    for v in video_files:
        cmd += ["-i", str(v)]
    if include_audio:
        for a in audio_files:
            if a is not None:
                cmd += ["-i", str(a)]
            else:
                # Need a stable input count; use null audio input
                cmd += ["-f", "lavfi", "-i", "anullsrc=channel_layout=stereo:sample_rate=44100"]
    cmd += ["-filter_complex", filter_complex]
    cmd += ["-map", "[vout]"]
    if include_audio:
        cmd += ["-map", "[aout]", "-c:a", "aac", "-b:a", "192k"]
    cmd += [
        "-c:v", "libx264",
        "-crf", str(args.crf),
        "-preset", "medium",
        "-pix_fmt", "yuv420p",
        "-movflags", "+faststart",
        str(output_path),
    ]

    print("Running single-pass ffmpeg...", file=sys.stderr)
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        print("FFMPEG STDERR (tail):", file=sys.stderr)
        print("\n".join(r.stderr.splitlines()[-30:]), file=sys.stderr)
        return r.returncode

    print(f"✓ Wrote {output_path}", file=sys.stderr)
    final_dur = ffprobe_duration(output_path)
    size_mb = output_path.stat().st_size / (1024 * 1024)
    print(f"  Duration: {final_dur:.2f}s | Size: {size_mb:.1f}MB", file=sys.stderr)
    print(str(output_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
