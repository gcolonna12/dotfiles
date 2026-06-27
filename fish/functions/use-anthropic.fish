# Switch Claude Code to use Anthropic's native API (personal subscription)
# Unsets OpenRouter overrides so Claude Code uses its default API and auth
function use-anthropic
    set -e ANTHROPIC_BASE_URL
    set -e ANTHROPIC_AUTH_TOKEN
    set -e ANTHROPIC_API_KEY
    set -e ANTHROPIC_DEFAULT_OPUS_MODEL
    set -e ANTHROPIC_DEFAULT_SONNET_MODEL
    set -e ANTHROPIC_DEFAULT_HAIKU_MODEL
    set -e CLAUDE_CODE_SUBAGENT_MODEL

    echo "→ Claude Code switched to Anthropic API (personal subscription)"
    echo "   Run /model in Claude Code to pick a specific model"
end