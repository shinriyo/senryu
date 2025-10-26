# Senryu Video Generator

A bash script that automatically creates video content from Japanese senryu (川柳) poems with text-to-speech and visual text overlay.

## What is Senryu?

Senryu (川柳) is a form of Japanese poetry similar to haiku, but focuses on human nature and emotions rather than nature. It follows a 5-7-5 syllable pattern and often contains humor or social commentary.

## Features

- **Automatic Text-to-Speech**: Converts Japanese text to natural-sounding speech
- **Smart Phrase Detection**: Automatically detects pauses between phrases for timing
- **Video Generation**: Creates MP4 videos with text overlay synchronized to speech
- **Dual TTS Engines**: Choose between macOS `say` or VOICEVOX for speech synthesis
- **Customizable Voice**: Choose from different Japanese voices and characters
- **Adjustable Timing**: Control speech rate and pause duration between phrases

## Requirements

- macOS (uses `say` command for text-to-speech)
- ffmpeg (for audio/video processing)
- Python 3 (for calculations)
- **For VOICEVOX integration**: VOICEVOX Engine running on localhost:50021, `jq` command-line tool

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
./auto_three_phrase.sh "フレーズ1  フレーズ2  フレーズ3" [output.mp4] [ENGINE] [VOICE] [RATE] [PAUSE_MS]
```

### Parameters

- **Input Text**: Three phrases separated by full-width spaces (　) or multiple regular spaces
- **Output File** (optional): Output video filename (default: `out.mp4`)
- **Engine** (optional): TTS engine to use - `say` (default) or `voicevox`
- **Voice** (optional): Voice to use
  - For `say` engine: `Kyoko` (female, default), `Eddy`, `Flo`, `Reed`, `Rocko`, `Sandy`, `Shelley`, etc.
  - For `voicevox` engine: Speaker ID (default: `2` for Zundamon)
- **Rate** (optional): Speech rate for `say` engine, 140-200 recommended (default: `170`)
- **Pause Duration** (optional): Pause between phrases in milliseconds for `say` engine (default: `600`)

### Examples

```bash
# Basic usage (macOS say with Kyoko)
./auto_three_phrase.sh "春の雨  傘を忘れて  濡れて帰る"

# macOS say with male voice
./auto_three_phrase.sh "夏の夜  花火を見て  涙が出る" "summer_say.mp4" "say" "Eddy"

# VOICEVOX with Zundamon
./auto_three_phrase.sh "秋の風  葉っぱが舞って  心も舞う" "autumn_voicevox.mp4" "voicevox" "2"

# VOICEVOX with Shikoku Metan (Sweet)
./auto_three_phrase.sh "冬の雪  静かに降って  心も静か" "winter.mp4" "voicevox" "1"

# Adjust speech rate and pause (say engine only)
./auto_three_phrase.sh "桜散る  スマホ見ながら  花見かな" "hanami.mp4" "say" "Flo" "150" "800"
```

### Available Voices

#### macOS say Engine

- **Kyoko** (女性, デフォルト)
- **Eddy** (男性)
- **Flo** (女性)
- **Reed** (男性)
- **Rocko** (男性)
- **Sandy** (女性)
- **Shelley** (女性)
- **Grandma** (女性)
- **Grandpa** (男性)

#### VOICEVOX Engine

See the [VOICEVOX Integration section](#voicevox-integration-voicevox_saysh) for the complete speaker list.

## How It Works

1. **Text Processing**: Splits input into three phrases using space detection
2. **Speech Synthesis**:
   - **say engine**: Uses macOS `say` command to generate audio with pauses
   - **voicevox engine**: Uses VOICEVOX API to generate high-quality Japanese speech
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
