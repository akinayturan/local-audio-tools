#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ "${1:-}" == "--status" ]]; then
  if [[ -f transcript/voice.txt ]]; then
    echo "Transcript file is available: $PWD/transcript/voice.txt"
  fi
  if [[ -f transcript/whisper.log ]]; then
    tr '\r' '\n' < transcript/whisper.log | tail -n 5
  else
    echo "No processing log is available yet."
  fi
  exit 0
fi

input="${1:-voice.m4a}"
[[ -f "$input" ]] || { echo "Audio file not found: $input" >&2; exit 1; }
command -v whisper >/dev/null || { echo "whisper command not found." >&2; exit 1; }
mkdir -p transcript

echo "Starting Turkish transcription: $input"
echo "Output directory: $PWD/transcript"
whisper "$input" \
  --model turbo \
  --language tr \
  --task transcribe \
  --device cpu \
  --fp16 False \
  --threads 8 \
  --output_dir transcript \
  --output_format all \
  --verbose False 2>&1 | tee transcript/whisper.log

echo "Done. Text (.txt) and timestamped subtitles (.srt, .vtt) are in the transcript directory."
