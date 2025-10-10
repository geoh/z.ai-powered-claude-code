# Configuration File Example

This document explains the example configuration file (`.zai.json.example`) and how to use it.

## Quick Start

1. Copy the example file to one of the supported locations:

   **Linux/macOS (recommended):**
   ```bash
   mkdir -p ~/.config/zai
   cp .zai.json.example ~/.config/zai/config.json
   ```

   **Linux/macOS (legacy):**
   ```bash
   cp .zai.json.example ~/.zai.json
   ```

   **Windows (recommended):**
   ```cmd
   mkdir %APPDATA%\zai
   copy .zai.json.example %APPDATA%\zai\config.json
   ```

   **Windows (legacy):**
   ```cmd
   copy .zai.json.example %USERPROFILE%\.zai.json
   ```

2. Edit the file and replace `"your-api-key"` with your actual Z.AI API key

3. Adjust other settings as needed

4. Set secure permissions (Linux/macOS):
   ```bash
   chmod 600 ~/.config/zai/config.json
   ```

## Configuration Options Explained

### apiKey
```json
"apiKey": "your-api-key"
```

**Description:** Your Z.AI API key for authentication.

**Security Warning:** 
- ⚠️ **NEVER commit this file with a real API key to version control!**
- Consider using the `ZAI_API_KEY` environment variable instead (more secure)
- If storing in a file, ensure permissions are restrictive (chmod 600 on Unix)

**Alternative (Recommended):**
```bash
# Set as environment variable instead
export ZAI_API_KEY="your-actual-api-key"
```

Then you can omit `apiKey` from the config file or leave it as `"your-api-key"`.

---

### opusModel
```json
"opusModel": "glm-4.6"
```

**Description:** The Z.AI model to use when Claude Code requests the "opus" tier model.

**Default:** `"glm-4.6"`

**Use Case:** Highest quality, most capable model for complex tasks.

**Alternatives:**
- `"glm-4.6"` - Latest and most capable (recommended)
- `"glm-4.5"` - Slightly older but still very capable

---

### sonnetModel
```json
"sonnetModel": "glm-4.5"
```

**Description:** The Z.AI model to use when Claude Code requests the "sonnet" tier model.

**Default:** `"glm-4.5"`

**Use Case:** Balanced performance and speed for most tasks.

**Alternatives:**
- `"glm-4.5"` - Good balance (recommended)
- `"glm-4.5-air"` - Faster, lighter weight

---

### haikuModel
```json
"haikuModel": "glm-4.5-air"
```

**Description:** The Z.AI model to use when Claude Code requests the "haiku" tier model.

**Default:** `"glm-4.5-air"`

**Use Case:** Fast, lightweight model for simple tasks.

**Alternatives:**
- `"glm-4.5-air"` - Fastest, most efficient (recommended)
- `"glm-4.5"` - More capable but slower

---

### subagentModel
```json
"subagentModel": "glm-4.6"
```

**Description:** The Z.AI model to use for Claude Code's subagent operations (background tasks, tool use, etc.).

**Default:** `"glm-4.6"`

**Use Case:** Background operations that benefit from higher capability.

**Alternatives:**
- `"glm-4.6"` - Best for complex subagent tasks (recommended)
- `"glm-4.5"` - Good balance
- `"glm-4.5-air"` - Faster but less capable

---

### defaultModel
```json
"defaultModel": "opus"
```

**Description:** The default model tier to use when you run `z` without specifying `--model`.

**Default:** `"opus"`

**Options:**
- `"opus"` - Highest quality (uses `opusModel`)
- `"sonnet"` - Balanced (uses `sonnetModel`)
- `"haiku"` - Fastest (uses `haikuModel`)
- Or specify a direct model name like `"glm-4.5"`

**Examples:**
```bash
# Uses defaultModel
z

# Explicitly specify model (overrides defaultModel)
z --model sonnet
z --model haiku
```

---

### enableThinking
```json
"enableThinking": "true"
```

**Description:** Enable AI thinking capabilities (if supported by Z.AI API).

**Default:** `"true"`

**Options:**
- `"true"` - Enable thinking mode
- `"false"` - Disable thinking mode

**Note:** This is an experimental feature. Its effectiveness depends on Z.AI API support.

---

### enableStreaming
```json
"enableStreaming": "true"
```

**Description:** Enable streaming responses for real-time output.

**Default:** `"true"`

**Options:**
- `"true"` - Stream responses as they're generated (recommended)
- `"false"` - Wait for complete response before displaying

**Use Case:** Streaming provides better user experience with immediate feedback.

---

### reasoningEffort
```json
"reasoningEffort": "high"
```

**Description:** The level of reasoning effort for AI thinking.

**Default:** `"high"`

**Options:**
- `"auto"` - Let the AI decide
- `"low"` - Minimal reasoning (faster)
- `"medium"` - Moderate reasoning
- `"high"` - Significant reasoning (recommended)
- `"max"` - Maximum reasoning (slowest, most thorough)

**Trade-off:** Higher effort = better quality but slower responses.

**Note:** Experimental feature. These settings are passed through to the API, but actual behavior depends on the Z.AI API's implementation and may not be fully supported.

---

### maxThinkingTokens
```json
"maxThinkingTokens": ""
```

**Description:** Maximum number of tokens allocated for thinking/reasoning.

**Default:** `""` (empty string = no limit)

**Examples:**
- `""` - No limit (recommended)
- `"1000"` - Limit to 1000 tokens
- `"2000"` - Limit to 2000 tokens

**Use Case:** Limit thinking tokens to control costs or response time.

**Note:** Experimental feature. These settings are passed through to the API, but actual behavior depends on the Z.AI API's implementation and may not be fully supported.

---

### maxOutputTokens
```json
"maxOutputTokens": ""
```

**Description:** Maximum number of tokens for the output response.

**Default:** `""` (empty string = no limit)

**Examples:**
- `""` - No limit (recommended)
- `"4000"` - Limit to 4000 tokens
- `"8000"` - Limit to 8000 tokens

**Use Case:** Limit output length to control costs or ensure concise responses.

---

## Common Configuration Scenarios

### Scenario 1: Security-Focused (Recommended)

**Config file** (`~/.config/zai/config.json`):
```json
{
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.5",
  "haikuModel": "glm-4.5-air",
  "subagentModel": "glm-4.6",
  "defaultModel": "sonnet"
}
```

**Environment variable:**
```bash
export ZAI_API_KEY="your-actual-api-key"
```

**Benefits:**
- API key not stored in file
- Can be shared/committed safely
- More secure

---

### Scenario 2: Performance-Focused

```json
{
  "apiKey": "your-api-key",
  "opusModel": "glm-4.5",
  "sonnetModel": "glm-4.5-air",
  "haikuModel": "glm-4.5-air",
  "subagentModel": "glm-4.5-air",
  "defaultModel": "haiku",
  "reasoningEffort": "medium"
}
```

**Benefits:**
- Faster responses
- Lower costs
- Good for simple tasks

---

### Scenario 3: Quality-Focused

```json
{
  "apiKey": "your-api-key",
  "opusModel": "glm-4.6",
  "sonnetModel": "glm-4.6",
  "haikuModel": "glm-4.5",
  "subagentModel": "glm-4.6",
  "defaultModel": "opus",
  "reasoningEffort": "max"
}
```

**Benefits:**
- Best quality responses
- Maximum reasoning
- Good for complex tasks

---

### Scenario 4: Per-Project Override

**Global config** (`~/.config/zai/config.json`):
```json
{
  "defaultModel": "opus",
  "reasoningEffort": "high"
}
```

**Project config** (`./.zai.json` in project directory):
```json
{
  "defaultModel": "haiku",
  "reasoningEffort": "low"
}
```

**Benefits:**
- Different settings per project
- Fast model for simple projects
- Quality model for complex projects

**Important:** Add `.zai.json` to your project's `.gitignore`!

---

## Security Best Practices

1. **Use environment variables for API keys:**
   ```bash
   export ZAI_API_KEY="your-api-key"
   ```

2. **Set restrictive file permissions:**
   ```bash
   chmod 600 ~/.config/zai/config.json
   ```

3. **Never commit API keys:**
   - Add `.zai.json` to `.gitignore`
   - Use `.zai.json.example` for sharing

4. **Use per-project configs without API keys:**
   ```json
   {
     "defaultModel": "sonnet"
   }
   ```

5. **Regularly rotate API keys:**
   - Change your API key periodically
   - Update environment variable or config file

---

## Troubleshooting

### "Valid API key not found"

**Problem:** The wrapper can't find a valid API key.

**Solutions:**
1. Set `ZAI_API_KEY` environment variable
2. Ensure `apiKey` in config is not `"your-api-key"`
3. Check config file exists and is readable

### "Configuration file not found"

**Problem:** No config file found in any location.

**Solutions:**
1. Run `z` to start interactive setup wizard
2. Copy `.zai.json.example` to a supported location
3. Create config file manually

### Permission warnings

**Problem:** "Config file has overly permissive permissions"

**Solution:**
```bash
chmod 600 ~/.config/zai/config.json
```

---

## Additional Resources

- [README.md](README.md) - Overview and quick start
- [INSTALL.md](INSTALL.md) - Installation guide
- [CONFIGURATION.md](CONFIGURATION.md) - Detailed configuration reference

