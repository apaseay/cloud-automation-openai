#!/bin/bash

# MAIN AUTOMATION SCRIPT
# Reads a prompt > Sends to OpenAI > Saves output > Logs the run

# 0. Load Config
CONFIG_FILE="config/settings.json"
if [ -f "$CONFIG_FILE" ]; then
  MODEL=$(jq -r '.model // "gpt-4o"' "$CONFIG_FILE")
else
  MODEL="gpt-4o"
fi

# 1. Check for API key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "ERROR: OPENAI_API_KEY is not set. Export it first:"
  echo 'export OPENAI_API_KEY="sk-proj-xxxx"'
  exit 1
fi

# 2. Read prompt from template file
PROMPT_FILE="prompts/automation_prompt.txt"
if [ ! -f "$PROMPT_FILE" ]; then
    echo "ERROR: Prompt file not found at $PROMPT_FILE"
    exit 1
fi
PROMPT=$(cat "$PROMPT_FILE")

# 3. Make OpenAI API request
echo "Sending request to OpenAI using model: $MODEL..."
RESPONSE=$(curl -s -w "\n%{http_code}" https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {\"role\": \"user\", \"content\": \"$PROMPT\"}
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

# 4. Save result to output file
echo "$CONTENT" > output.txt

# 5. Log the run
mkdir -p logs
echo "$(date "+%Y-%m-%d %H:%M:%S") | Main automation executed successfully with model $MODEL." >> logs/run.log

# 6. Notify user
echo "Automation complete. Output saved to output.txt"
echo "Log entry added to logs/run.log"