# Local Audio Tools

Two Bash scripts for transcribing Turkish audio and converting M4A recordings into MP4 videos. Audio processing runs locally on your computer.

## Scripts

| Script | Purpose | Output |
| --- | --- | --- |
| [transcribe.sh](transcribe.sh) | Transcribe Turkish speech with Whisper | Text, subtitles, structured transcript, and a log |
| [m4a-to-mp4.sh](m4a-to-mp4.sh) | Add a black video track to an audio recording | MP4 video with the original audio or an AAC conversion |

## Requirements

- Bash (the scripts can be launched from a Bash or Zsh terminal).
- FFmpeg and FFprobe, available on your `PATH`.
- FFmpeg built with the `libx264` encoder for MP4 conversion.
- The OpenAI Whisper command-line tool (`whisper`) for transcription only.
- Enough free disk space and memory for the Whisper model and generated files.
- Internet access for installing dependencies and downloading the Whisper model on first use. Once the model is cached, processing can run offline. No OpenAI API key is required.

These instructions target macOS. MP4 conversion does not require Whisper or its model.

## Installation on macOS

With [Homebrew](https://brew.sh/) already installed, run:

```bash
brew install ffmpeg openai-whisper
```

Homebrew manages the required Python runtime and package dependencies for Whisper.

Verify the commands are available:

```bash
ffmpeg -version
ffprobe -version
whisper --help
```

For other platforms or a Python-based installation, see the [official Whisper setup instructions](https://github.com/openai/whisper#setup). A Python installation requires Python, pip, and the Whisper/PyTorch dependencies in addition to FFmpeg. Activate the relevant Python environment before using the transcription script.

## Quick start

### 1. Download the project

If Git is installed, open Terminal and run:

```bash
git clone https://github.com/akinayturan/local-audio-tools.git
cd local-audio-tools
```

Alternatively, select **Code → Download ZIP** on GitHub, extract the archive, type `cd ` in Terminal, drag the extracted folder into the Terminal window, and press Return.

Install the dependencies listed in [Installation on macOS](#installation-on-macos) before running the scripts.

### 2. Add your audio file

Copy your downloaded recording into the project folder, beside `transcribe.sh` and `m4a-to-mp4.sh`. Rename the recording to **`voice.m4a`** for the examples below. Make sure the filename is not accidentally `voice.m4a.m4a`.

The folder should look like this before processing:

```text
local-audio-tools/
├── README.md
├── LICENSE
├── .gitignore
├── transcribe.sh
├── m4a-to-mp4.sh
└── voice.m4a          # Your recording; not included in the repository
```

### 3. Convert the recording to text

From the project folder in Terminal, run:

```bash
bash transcribe.sh voice.m4a
```

Wait for the command to finish. **`transcript/voice.txt` is written after the entire recording has been processed**, rather than updated live. To open the finished text file on macOS:

```bash
open transcript/voice.txt
```

Subtitle and structured transcript files are also saved in `transcript/`. See [Turkish transcription](#turkish-transcription) for output formats and progress monitoring.

### 4. Create an MP4 video, if needed

To create **`voice.mp4`** in the project folder, run:

```bash
bash m4a-to-mp4.sh voice.m4a
```

The resulting video contains a black image and the recording's audio. To open it on macOS:

```bash
open voice.mp4
```

### Using another filename

You do not have to rename your recording. Replace the input filename in either command, for example:

```bash
bash transcribe.sh "meeting recording.m4a"
bash m4a-to-mp4.sh "meeting recording.m4a" "meeting video.mp4"
```

These commands produce `transcript/meeting recording.txt` (plus subtitle and structured files) and `meeting video.mp4`.

Run only the command you need. The scripts are independent; transcription accepts the M4A file directly, so MP4 conversion is optional. Both scripts default to `voice.m4a` if no input argument is supplied. Quote filenames containing spaces.

## Turkish transcription

```bash
bash transcribe.sh voice.m4a
```

For a different recording:

```bash
bash transcribe.sh "/absolute/path/to/my recording.m4a"
```

The script uses these Whisper options:

```bash
whisper voice.m4a \
  --model turbo \
  --language tr \
  --task transcribe \
  --device cpu \
  --fp16 False \
  --threads 8 \
  --output_dir transcript \
  --output_format all \
  --verbose False
```

It transcribes Turkish speech into Turkish text using the multilingual `turbo` model. It currently uses the CPU with eight threads; no GPU is required. Processing time depends on the recording and computer. Keep the computer awake while processing.

Results are saved in the `transcript` folder beside the script:

| File for `voice.m4a` | Contents |
| --- | --- |
| `voice.txt` | Plain-text transcript |
| `voice.srt` | Subtitles with timestamps |
| `voice.vtt` | WebVTT subtitles |
| `voice.tsv` | Timestamped transcript in tab-separated format |
| `voice.json` | Structured transcription data |
| `whisper.log` | Progress and diagnostic messages |

Other input filenames produce output files with their own base name. Relative transcription input paths are resolved from the script's folder.

Check the latest log entries:

```bash
bash transcribe.sh --status
```

The status command displays recent log entries and checks whether `transcript/voice.txt` exists. It does not verify that a process is running, and an existing text file may be from an earlier run.

Follow the log continuously in another terminal:

```bash
tail -f transcript/whisper.log
```

Press `Ctrl+C` to stop following the log. This does not stop a transcription running in another terminal. Pressing `Ctrl+C` in the transcription terminal interrupts transcription itself.

Run one transcription at a time in this folder: the log is shared, each new run replaces it, and transcript files with matching names can be overwritten. Review names, numbers, and unclear speech in the generated text; automatic transcription can contain errors.

## M4A to MP4 conversion

Use the default output name:

```bash
bash m4a-to-mp4.sh voice.m4a
```

This creates `voice.mp4` beside the input file. To choose an output path:

```bash
bash m4a-to-mp4.sh "my recording.m4a" "my video.mp4"
```

The script creates a black 1280 × 720 H.264 video track at one frame per second. It copies AAC audio without re-encoding; other audio codecs are converted to AAC at 192 kbit/s. Video duration follows the audio duration, and the original recording is preserved.

Input and output paths for this script are resolved from the terminal's current directory. The destination folder must already exist. The script refuses to overwrite an existing output file; choose a new filename if needed.

## References

- [OpenAI Whisper documentation](https://github.com/openai/whisper)
- [Homebrew: openai-whisper](https://formulae.brew.sh/formula/openai-whisper)
- [Homebrew: ffmpeg](https://formulae.brew.sh/formula/ffmpeg)

## License

The scripts and documentation in this repository are licensed under the [MIT License](LICENSE). Third-party dependencies, including Whisper, FFmpeg, and their models, retain their own licenses.
