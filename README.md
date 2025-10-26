# Senryu Video Generator

A bash script that automatically creates video content from Japanese senryu (川柳) poems with text-to-speech and visual text overlay.

## What is Senryu?

Senryu (川柳) is a form of Japanese poetry similar to haiku, but focuses on human nature and emotions rather than nature. It follows a 5-7-5 syllable pattern and often contains humor or social commentary.

## Features

- **Automatic Text-to-Speech**: Converts Japanese text to natural-sounding speech
- **Smart Phrase Detection**: Automatically detects pauses between phrases for timing
- **Video Generation**: Creates MP4 videos with text overlay synchronized to speech
- **Customizable Voice**: Choose from different Japanese voices (Kyoko, Otoya, etc.)
- **Adjustable Timing**: Control speech rate and pause duration between phrases

## Requirements

- macOS (uses `say` command for text-to-speech)
- ffmpeg (for audio/video processing)
- Python 3 (for calculations)

## Installation

1. Clone or download this repository
2. Make the script executable:
   ```bash
   chmod +x auto_three_phrase.sh
   ```

## Usage

### Basic Usage

```bash
./auto_three_phrase.sh "医者笑い  企業は拍手  肺が泣く"
```

### Advanced Usage

```bash
./auto_three_phrase.sh "フレーズ1  フレーズ2  フレーズ3" [output.mp4] [VOICE] [RATE] [PAUSE_MS]
```

### Parameters

- **Input Text**: Three phrases separated by full-width spaces (　) or multiple regular spaces
- **Output File** (optional): Output video filename (default: `out.mp4`)
- **Voice** (optional): TTS voice to use (default: `Kyoko`)
  - Available voices: `Kyoko` (female), `Otoya` (male), and others
- **Rate** (optional): Speech rate, 140-200 recommended (default: `170`)
- **Pause Duration** (optional): Pause between phrases in milliseconds (default: `600`)

### Examples

```bash
# Basic usage
./auto_three_phrase.sh "春の雨  傘を忘れて  濡れて帰る"

# Custom output and voice
./auto_three_phrase.sh "夏の夜  花火を見て  涙が出る" "summer_senryu.mp4" "Otoya"

# Adjust speech rate and pause
./auto_three_phrase.sh "秋の風  葉っぱが舞って  心も舞う" "autumn.mp4" "Kyoko" "150" "800"
```

## How It Works

1. **Text Processing**: Splits input into three phrases using space detection
2. **Speech Synthesis**: Uses macOS `say` command to generate audio with pauses
3. **Audio Processing**: Converts to MP3 and detects silence points for timing
4. **Video Creation**: Generates black background video with synchronized text overlay
5. **Output**: Produces final MP4 file with audio and visual text

## Output

The script generates:

- `1.aiff` - Raw audio file
- `1.mp3` - Processed audio file
- `silences.log` - Silence detection log
- `[output].mp4` - Final video with text overlay

## Troubleshooting

- **"区切りが足りません"**: Make sure to use proper spacing between phrases (full-width spaces or multiple regular spaces)
- **Audio issues**: Check that `say` command works: `say "test"`
- **Video issues**: Ensure ffmpeg is installed: `ffmpeg -version`

## Additional Scripts

### VOICEVOX Integration (`voicevox_say.sh`)

This project also includes a VOICEVOX integration script for high-quality Japanese text-to-speech synthesis.

#### Requirements

- VOICEVOX Engine running on localhost:50021
- `jq` command-line JSON processor (install with `brew install jq`)
- `curl` for API communication
- `afplay` for audio playback (macOS built-in)

#### Usage

```bash
# Basic usage (defaults to ずんだもん speaker=2)
./voicevox_say.sh "おはよう！今日もがんばるのだ！"

# Specify speaker by ID
./voicevox_say.sh "ずんだもんはツンツンしてるぞ" 4

# Specify speaker with parameter name
./voicevox_say.sh "めたんだよ～" speaker=1
```

#### Available Speakers

| Speaker Name           | Speaker ID |
| :--------------------- | :--------: |
| Shikoku Metan (Normal) |     0      |
| Shikoku Metan (Sweet)  |     1      |
| Zundamon (Normal)      |     2      |
| Zundamon (Sweet)       |     3      |
| Zundamon (Tsuntsun)    |     4      |
| Zundamon (Sexy)        |     5      |
| Kasukabe Tsumugi       |     6      |
| Amami Haru             |     7      |
| Namine Ritsu           |     8      |
| Genno Takehiro         |     9      |
| Shirakami Kotaro       |     10     |
| Aoyama Ryusei          |     11     |
| Meimei Himari          |     12     |
| Kyushu Sora (Normal)   |     16     |
| Kyushu Sora (Sexy)     |     17     |
| Kyushu Sora (Tsuntsun) |     18     |

#### Examples

```bash
# Zundamon (Normal)
./voicevox_say.sh "おはよう！今日もがんばるのだ！" 2

# Shikoku Metan (Sweet)
./voicevox_say.sh "めたんだよ～" 1

# Kyushu Sora (Sexy)
./voicevox_say.sh "こんにちは、九州そらです。" 17
```

#### Output

The script generates:

- `query.json` - Audio query parameters
- `voice.wav` - Generated audio file
- Plays audio automatically using `afplay`

## License

This project is open source. Feel free to modify and distribute.
