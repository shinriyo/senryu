#!/bin/bash
# voicevox_say.sh
TEXT="$*"
TEXT_ENC=$(printf '%s' "$TEXT" | jq -sRr @uri)

curl --http1.1 -s -X POST "http://127.0.0.1:50021/audio_query?text=$TEXT_ENC&speaker=2" -o query.json
ACCENT_COUNT=$(jq '.accent_phrases | length' query.json)
echo "accent_phrases: $ACCENT_COUNT"

if [ "$ACCENT_COUNT" -gt 0 ]; then
  curl --http1.1 -s -X POST "http://127.0.0.1:50021/synthesis?speaker=2" \
    -H "Content-Type: application/json" \
    --data-binary @query.json -o voice.wav
  afplay voice.wav
else
  echo "❌ Failed: no accent_phrases (check encoding or quotes)"
fi

