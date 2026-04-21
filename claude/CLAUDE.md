# Commit Messages
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters

# Code Style
- DO NOT over-engineer
- DO NOT add features I didn't request
- Keep solutions simple and direct
- Prefer boring, readable code
- DO NOT update tests without explicit confirmation

My dev environment is: macOS + iTerm2 + tmux + fish shell + VS Code (with terminal). When troubleshooting keybindings, input, or display issues, always consider the full chain (iTerm2 → tmux → fish/app) and which layer is responsible.

My dotfiles repo manages configs via symlinks and an install/bootstrap script. When modifying any config (tmux, fish, iTerm2, VS Code, Claude Code settings), always check the dotfiles repo structure first and make changes there — not in the local config files directly.

Before making changes, prefer a focused approach: ask clarifying questions if the scope is ambiguous rather than exploring the repo extensively with many sequential bash/read commands. Act, don't over-investigate.

# Bash Commands
- Never use `python3 -c` or `python -c` with multiline inline code. Write a temp `.py` file and execute it instead.
- Avoid `#` characters inside quoted Bash arguments (triggers a security heuristic that cannot be allowlisted).

## Code Navigation
LSP servers are available for Python (.py, .pyi) and TypeScript/JavaScript (.ts, .tsx, .js, .jsx).

For these file types, always prefer LSP over Grep/Glob/Read for code navigation:
- Finding symbol definitions → LSP goToDefinition
- Finding usages → LSP findReferences
- Listing symbols in a file → LSP documentSymbol
- Type information → LSP hover
- Errors and warnings → LSP diagnostics

For all other file types, use Grep/Glob/Read as normal.