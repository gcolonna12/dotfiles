# Switch Claude Code to use DeepSeek models via OpenRouter
# Reads OPENROUTER_API_KEY from the session (set in extra.fish)
function use-deepseek
    if test -z "$OPENROUTER_API_KEY"
        echo "Error: OPENROUTER_API_KEY is not set."
        echo "Set it in ~/.config/fish/conf.d/extra.fish"
        return 1
    end

    set -gx ANTHROPIC_BASE_URL "https://openrouter.ai/api"
    set -gx ANTHROPIC_AUTH_TOKEN "$OPENROUTER_API_KEY"
    set -gx ANTHROPIC_API_KEY ""  # Must be explicitly empty to use AUTH_TOKEN
    set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "deepseek/deepseek-v4-pro"
    set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "deepseek/deepseek-v4-flash"
    set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "google/gemma-4-31b-it"
    set -gx CLAUDE_CODE_SUBAGENT_MODEL "deepseek/deepseek-v4-flash"

    echo "→ Claude Code switched to DeepSeek via OpenRouter"
    echo "   Run /model in Claude Code to pick a specific model"
end