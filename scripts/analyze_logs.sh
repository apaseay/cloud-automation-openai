#!/bin/bash

# ANALYZE LOGS USING GPT

# 0. Load Config
CONFIG_FILE="config/settings.json"
if [ -f "$CONFIG_FILE" ]; then
  MODEL=$(jq -r '.model // "gpt-4o"' "$CONFIG_FILE")
else
  MODEL="gpt-4o"
fi

if [ -z "$OPENAI_API_KEY" ]; then
  echo "ERROR: OPENAI_API_KEY not set."
  exit 1
fi

LOG_FILE="logs/run.log"
if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: Log file not found at $LOG_FILE"
    exit 1
fi

LOG_CONTENT=$(cat "$LOG_FILE")
if [ -z "$LOG_CONTENT" ]; then
    echo "Log file is empty."
    exit 0
fi

echo "Analyzing logs with model: $MODEL..."

RESPONSE=$(curl -s -w "\n%{http_code}" https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"user\",
            \"content\": \"Analyze the following automation logs and summarize key insights: $LOG_CONTENT\"
          }
        ]
      }")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ne 200 ]; then
    echo "ERROR: API request failed with status $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi

CONTENT=$(echo "$BODY" | jq -r '.choices[0].message.content')

if [ -z "$CONTENT" ] || [ "$CONTENT" == "null" ]; then
    echo "ERROR: Failed to parse API response."
    echo "Response: $BODY"
    exit 1
fi

echo "$CONTENT"