#!/bin/bash

# GENERATE CLOUD COST RECOMMENDATIONS

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

echo "Generating cost recommendations with model: $MODEL..."

RESPONSE=$(curl -s -w "\n%{http_code}" https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
        \"model\": \"$MODEL\",
        \"messages\": [
          {
            \"role\": \"user\",
            \"content\": \"Provide 3 cloud cost optimization recommendations.\"
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