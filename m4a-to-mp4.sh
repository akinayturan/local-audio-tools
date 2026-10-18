#!/usr/bin/env bash
set -euo pipefail

# Usage: bash m4a-to-mp4.sh [input.m4a] [output.mp4]
# Adds a black video track to an MP4; preserves AAC audio without re-encoding.
input="${1:-voice.m4a}"
output="${2:-${input%.*}.mp4}"

command -v ffmpeg >/dev/null || { echo "ffmpeg command not found." >&2; exit 1; }
command -v ffprobe >/dev/null || { echo "ffprobe command not found." >&2; exit 1; }
[[ -f "$input" ]] || { echo "Input file not found: $input" >&2; exit 1; }
[[ ! -e "$output" ]] || { echo "Output file already exists: $output" >&2; exit 1; }

codec="$(ffprobe -v error -select_streams a:0 \
  -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input")"
[[ -n "$codec" ]] || { echo "No audio stream found in the input file." >&2; exit 1; }
audio_options=(-c:a aac -b:a 192k)
if [[ "$codec" == "aac" ]]; then
  audio_options=(-c:a copy)
fi

ffmpeg -hide_banner -nostdin -n \
  -f lavfi -i 'color=c=black:s=1280x720:r=1' \
  -i "$input" \
  -map 0:v:0 -map 1:a:0 \
  -c:v libx264 -preset ultrafast -tune stillimage -crf 30 -pix_fmt yuv420p \
  "${audio_options[@]}" \
  -shortest -movflags +faststart "$output"

echo "Done: $output"
