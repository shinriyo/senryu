#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 テキスト... [4 | speaker=4]" >&2
  exit 1
fi

# 引数の最後が speaker指定なら抜き出す
last="${!#}"
if [[ "$last" =~ ^([0-9]+)$ ]]; then
  SPEAKER="${BASH_REMATCH[1]}"
  # テキスト=最後以外
  TEXT="${*:1:$(($#-1))}"
elif [[ "$last" =~ ^speaker=([0-9]+)$ ]]; then
  SPEAKER="${BASH_REMATCH[1]}"
  TEXT="${*:1:$(($#-1))}"
else
  SPEAKER="2"          # 省略時はずんだもん(2)
  TEXT="$*"
fi

# URLエンコード（jq 推奨。無ければ brew install jq）
TEXT_ENC=$(printf '%s' "$TEXT" | jq -sRr @uri)

echo "▶ text: $TEXT"
echo "▶ speaker: $SPEAKER"

# audio_query（POST, URLにtext&speakder）
curl --http1.1 -s -X POST \
  "http://127.0.0.1:50021/audio_query?text=$TEXT_ENC&speaker=$SPEAKER" \
  -H "Accept: application/json" \
  -o query.json

# 成功確認
if command -v jq >/dev/null; then
  jq '.accent_phrases | length' query.json
fi

# synthesis
curl --http1.1 -s -X POST \
  "http://127.0.0.1:50021/synthesis?speaker=$SPEAKER" \
  -H "Content-Type: application/json" \
  --data-binary @query.json -o voice.wav

afplay voice.wav

