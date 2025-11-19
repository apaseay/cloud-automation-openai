# Testing Automation Engine v1

This project automates cloud engineering tasks using OpenAI's API. It includes:

- Cloud automation scripts
- Log analysis automation
- Cost optimization recommendations
- Reusable prompt templates
- Config-driven automation
- Logging system
- Docker container for cloud deployment

## Features

1. **Main Automation Script (`auto_chat.sh`)**
   - Reads a prompt from `prompts/automation_prompt.txt`
   - Sends it to the OpenAI API
   - Saves the result to `output.txt`
   - Logs execution history to `logs/run.log`

2. **Log Analysis (`scripts/analyze_logs.sh`)**
   - Loads the project's logs
   - Uses GPT to analyze automation history
   - Helpful for debugging and audit reporting

3. **Cost Optimization Engine (`scripts/cost_recommendation.sh`)**
   - Generates actionable cloud cost–saving recommendations

4. **Configuration System**
   - Easily change defaults using `config/settings.json`

5. **Secure Environment Variables**
   - `.env.example` shows how to set secrets correctly
   - The actual `.env` is ignored for security

6. **Docker Deployment**
   - The `docker/Dockerfile` containerizes the entire automation engine

---

## Setup Instructions

### 1. Install dependencies:

You will need:
- `curl`
- `jq`
- `bash`

Most macOS/Linux systems already have `curl` and `bash`.  
Install `jq` using:

```bash
brew install jq