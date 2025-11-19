#!/bin/bash

# GCP DEPLOYMENT / EXECUTION SCRIPT
# Executes commands against Google Cloud Platform

# 0. Load Config
CONFIG_FILE="config/settings.json"
if [ -f "$CONFIG_FILE" ]; then
  MODEL=$(jq -r '.model // "gpt-4o"' "$CONFIG_FILE")
else
  MODEL="gpt-4o"
fi

# 1. Check for API key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "ERROR: OPENAI_API_KEY not set."
  exit 1
fi

# 2. Check for gcloud
if ! command -v gcloud &> /dev/null; then
    echo "ERROR: gcloud CLI is not installed."
    exit 1
fi

echo "Generating GCP commands with model: $MODEL..."

# 3. Ask LLM for a command (Example: List buckets)
# In a real scenario, this prompt would be dynamic or come from a file
PROMPT="Generate a single gcloud command to list all storage buckets in the current project. Output ONLY the command, no markdown."

RESPONSE=$(curl -s -w "\n%{http_code}" https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"user\",
            \"content\": \"$PROMPT\"
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

COMMAND=$(echo "$BODY" | jq -r '.choices[0].message.content')

if [ -z "$COMMAND" ] || [ "$COMMAND" == "null" ]; then
    echo "ERROR: Failed to parse API response."
    exit 1
fi

echo "Generated Command: $COMMAND"

# 4. Execute the command (SAFE MODE: Ask for confirmation or use a flag)
# For now, we will just print it. To execute, uncomment the lines below.
# echo "Executing..."
# eval "$COMMAND"
