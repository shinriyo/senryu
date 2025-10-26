#!/usr/bin/env bash
set -euo pipefail

# 使い方:
#   ./auto_three_phrase.sh "医者笑い  企業は拍手  肺が泣く"
#   ./auto_three_phrase.sh "医者笑い　企業は拍手　肺が泣く"
#   ./auto_three_phrase.sh "医者笑い  企業は拍手  肺が泣く" out.mp4 voicevox 2
#
# 区切り: 全角スペース「　」または 半角スペース2個以上
# フレーズ内では半角スペース1個までは自由に使えます。
# 音声エンジン: "voicevox" または "say" (デフォルト: say)
# VOICEVOX使用時: スピーカーID (デフォルト: 2=ずんだもん)

LINE="${1:-}"
OUT="${2:-out.mp4}"
ENGINE="${3:-say}"    # 音声エンジン: "say" または "voicevox"
VOICE="${4:-Kyoko}"   # say用: Kyoko(女), Otoya(男) など / voicevox用: スピーカーID
RATE="${5:-170}"      # 話速(目安 140-200) - say用のみ
PAUSE_MS="${6:-600}"  # 句間ポーズ(ms) - say用のみ

if [[ -z "$LINE" ]]; then
  echo "Usage: $0 \"フレーズ1  フレーズ2  フレーズ3\" [out.mp4] [ENGINE] [VOICE] [RATE] [PAUSE_MS]" >&2
  echo "  ENGINE: 'say' (default) or 'voicevox'" >&2
  echo "  VOICE: For say: Kyoko, Otoya, etc. / For voicevox: Speaker ID (default: 2)" >&2
  exit 1
fi

# --- 3フレーズに分割（全角 or 半角2スペ区切り） ---
# 全角スペース → タブに置換、半角2個以上のスペース → タブ1個に圧縮
TMP="$(printf "%s" "$LINE" \
  | sed -E 's/　+/\t/g; s/ {2,}/\t/g')"

# 3フィールドに切り出し（タブ区切り）
P1="$(printf "%s" "$TMP" | cut -f1)"
P2="$(printf "%s" "$TMP" | cut -f2)"
P3="$(printf "%s" "$TMP" | cut -f3)"

# フィールド欠損チェック
if [[ -z "${P1:-}" || -z "${P2:-}" || -z "${P3:-}" ]]; then
  echo "区切りが足りません。全角スペース『　』か半角スペース2個以上で3区切りにしてください。" >&2
  exit 1
fi

echo "▶ Phrase1: $P1"
echo "▶ Phrase2: $P2"
echo "▶ Phrase3: $P3"
echo "▶ Engine: $ENGINE"
echo "▶ Voice: $VOICE"

# --- 音声合成 → 1.aiff / 1.mp3 ---
if [[ "$ENGINE" == "voicevox" ]]; then
  # VOICEVOX使用
  echo "🎤 Using VOICEVOX (Speaker ID: $VOICE)"
  
  # 各フレーズを個別に音声合成
  for i in 1 2 3; do
    eval "PHRASE=\$P$i"
    echo "  Processing phrase $i: $PHRASE"
    
    # URLエンコード
    TEXT_ENC=$(printf '%s' "$PHRASE" | jq -sRr @uri)
    
    # audio_query
    curl --http1.1 -s -X POST \
      "http://127.0.0.1:50021/audio_query?text=$TEXT_ENC&speaker=$VOICE" \
      -H "Accept: application/json" \
      -o "query_$i.json"
    
    # synthesis
    curl --http1.1 -s -X POST \
      "http://127.0.0.1:50021/synthesis?speaker=$VOICE" \
      -H "Content-Type: application/json" \
      --data-binary @"query_$i.json" -o "voice_$i.wav"
  done
  
  # 3つの音声ファイルを結合（ポーズ付き）
  ffmpeg -y -hide_banner -loglevel error \
    -i voice_1.wav -i voice_2.wav -i voice_3.wav \
    -filter_complex "[0]apad=pad_len=48000[0p];[1]apad=pad_len=48000[1p];[0p][1p][2]concat=n=3:v=0:a=1[out]" \
    -map "[out]" -c:a pcm_s16le temp.wav
  
  # MP3に変換
  ffmpeg -y -hide_banner -loglevel error -i temp.wav -c:a libmp3lame -b:a 192k 1.mp3
  
  # 一時ファイル削除
  rm -f query_*.json voice_*.wav temp.wav
  
else
  # say使用（従来通り）
  echo "🎤 Using macOS say (Voice: $VOICE, Rate: $RATE)"
  TEXT="$P1 [[slnc $PAUSE_MS]] $P2 [[slnc $PAUSE_MS]] $P3"
  say -v "$VOICE" -r "$RATE" -o 1.aiff "$TEXT"
  ffmpeg -y -hide_banner -loglevel error -i 1.aiff -c:a libmp3lame -b:a 192k 1.mp3
fi

# 総尺
DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 1.mp3)"

# --- 無音検出（silencedetect）→ 区切り時刻 T1,T2 ---
ffmpeg -hide_banner -nostats -loglevel info -i 1.mp3 \
  -af silencedetect=noise=-30dB:d=0.35 -f null - 2> silences.log || true

read T1 T2 < <(grep -oE 'silence_start: [0-9.]+' silences.log | awk '{print $2}' | head -n 2)
# フォールバック（見つからなければ3等分）
: "${T1:=$(python3 - <<PY
d=$DUR
print(d/3)
PY
)}"
: "${T2:=$(python3 - <<PY
d=$DUR
print(d*2/3)
PY
)}"

echo "⏱  DUR=$DUR  T1=$T1  T2=$T2"

# --- テキスト焼き込み（ASS不要・drawtext） ---
FONT="Hiragino Sans"   # mac標準フォント名
SIZE=72

# コロンをエスケープ（drawtextの区切り対策）
esc() { printf "%s" "$1" | sed 's/:/\\:/g'; }
E1="$(esc "$P1")"; E2="$(esc "$P2")"; E3="$(esc "$P3")"

ffmpeg -y -hide_banner \
  -i 1.mp3 \
  -f lavfi -t "$DUR" -i "color=black:s=1280x720:r=30" \
  -filter_complex "[1:v]drawtext=font='$FONT':text='$E1':fontsize=$SIZE:fontcolor=white:borderw=3:box=1:boxcolor=black@0.35:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,0,$T1)',drawtext=font='$FONT':text='$E2':fontsize=$SIZE:fontcolor=white:borderw=3:box=1:boxcolor=black@0.35:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,$T1,$T2)',drawtext=font='$FONT':text='$E3':fontsize=$SIZE:fontcolor=white:borderw=3:box=1:boxcolor=black@0.35:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,$T2,$DUR)'[v]" \
  -map "[v]" -map 0:a -c:v libx264 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "$OUT"

echo "✅ 完成: $OUT"

