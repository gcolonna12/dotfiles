# Commit Messages
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters

# Code Style

**Pre-flight before writing code** (these restate rules below — run them as a gate):
1. **Placement** — does this belong in the file I'm editing, or in the module
   whose responsibility it is? Use codegraph/LSP before adding a function.
2. **Thin adapters** — no orchestration/scoring/logging logic in a CLI/HTTP
   handler; it delegates to the domain layer and logs at the source.
3. **No twins, no needless indirection** — consolidate two functions that do one
   job; don't add a helper/factory/param with a single caller.
4. **One source of truth** — don't pass a value the callee can already get from
   the data it's handed (e.g. a field already in `suite.json`).
5. **Docstring/comment describes THIS object only** — no callers, no hypothetical
   siblings, no invented terms, no unbacked rankings.

- DO NOT over-engineer
- DO NOT add features I didn't request — no speculative flexibility such as
  configurable/overridable parameters, extra options, or hooks "just in case".
  Solve exactly the problem in front of you, as simply as possible.
- Keep solutions simple and direct
- Prefer boring, readable code
- Before adding a function/class, find the module whose responsibility it matches
  (use codegraph, LSP, or read a sibling) and put it there — don't drop it into the
  file you happen to be editing.
- Keep layers honest: thin adapters (CLI commands, HTTP handlers) parse input,
  delegate, and map the result — real logic (orchestration, scoring, I/O policy)
  lives in the domain/runtime layer they call, not in the adapter.
- DO NOT update tests without explicit confirmation
- Do NOT hard-wrap Markdown prose at a fixed column. Use one sentence per line, or leave paragraphs unwrapped. Only wrap to a specific width if I explicitly ask.
- When writing Markdown prose, follow Semantic Line Breaks (https://sembr.org/): break lines at sentence and clause boundaries.

## Python conventions
- Prefer pydantic for validation / (de)serialisation / settings.
- Choose model kind by intent: `BaseModel` for data parsed from external input
  or recorded for reproducibility (anything with a real constraint); plain
  frozen dataclass for values the code computes itself from already-valid data.
- Let types carry constraints instead of prose: `num_trials: int = Field(ge=1)`.
- Be strict; don't coerce. Enforce the type at the validation boundary, not with
  `str(...)` deep in the code.
- Use `NewType` for IDs and similar primitives (`UserId = NewType("UserId", str)`).
- Enum members are `ALL_CAPS`; prefer enums over bare string literals.
- Avoid empty strings as defaults; prefer `None` (they hide bugs).
- No raw `dict` + magic strings for known shapes — use a dataclass / model.
- Take the smallest set of params a function needs; don't pass whole config bags.
- Avoid `Any`; confine any unavoidable `Any` to the third-party seam and say why.
- Docstrings on every small function are an antipattern — prefer clear names/types.
- A docstring states what a function is/returns — not how, where, or why callers use
  its result. Keep caller-context and downstream behavior at the call site, not in the
  callee (e.g. don't write "X is bound to this run's responder"; the signature shows that).
- A docstring describes only its own object. Don't repeat rationale the base
  class/module already owns (a concrete `Criteria`/scorer shouldn't re-explain the
  plugin architecture), and don't describe hypothetical siblings that don't exist
  ("a richer capability grades artifacts instead").
- No unbacked editorial claims in docstrings: skip superlatives and definite-article
  rankings the file can't substantiate ("the code-based grader", "the minimal
  capability") — they bit-rot the moment a second implementation lands.
- Every concrete claim in a docstring must match the code now. Don't list fields
  that don't exist (e.g. a "prompt builder" the type never had), and don't lean on a
  term that isn't a local name — if you mean the return value, say so, don't invent
  "Credit".
- Pick collection types by semantics (`tuple`/`set`/`Sequence`), not habit.
- Use structlog with structured key/value fields, not string-formatted log lines
  (`logger.warning("...", item_id=item.id, exception=str(e))`).

## Merge requests / PRs
- Keep every MR/PR small and atomic. Two small MRs are easier to review than one
  big one; break a large branch into conceptual pieces. Defer tangential
  refactors to their own change.
- Title every MR/PR as `type(TICKET): description` (Conventional Commits), e.g.
  `refactor(QED-135): restyle the agent thread`. `type` is one of
  feat/fix/refactor/hotfix/etc.; the scope in parentheses is the ticket ID.
- Always apply this when opening an MR/PR — don't ask about the format each time.
- If there's no ticket to link, stop and prompt me to create one before opening
  the MR/PR.

My dev environment is: macOS + iTerm2 + tmux + fish shell + VS Code (with terminal). When troubleshooting keybindings, input, or display issues, always consider the full chain (iTerm2 → tmux → fish/app) and which layer is responsible.

My dotfiles repo manages configs via symlinks and an install/bootstrap script. When modifying any config (tmux, fish, iTerm2, VS Code, Claude Code settings), always check the dotfiles repo structure first and make changes there — not in the local config files directly.

Before making changes, prefer a focused approach: ask clarifying questions if the scope is ambiguous rather than exploring the repo extensively with many sequential bash/read commands. Act, don't over-investigate.

# Bash Commands
- Never use `python3 -c` or `python -c` with multiline inline code. Write a temp `.py` file and execute it instead.
- Avoid `#` characters inside quoted Bash arguments (triggers a security heuristic that cannot be allowlisted).
- When searching for or fetching code/content from GitHub, prefer the `gh` CLI (`gh search`, `gh api`) over `curl`. List paths via `gh api repos/<owner>/<repo>/git/trees/<branch>?recursive=1` before fetching specific files.

## Git Worktrees
- Create worktrees with `fish -c 'wt add <branch>'`, never raw `git worktree add`. The `wt` helper anchors to the main repo via `--git-common-dir` and flattens the branch slug, so worktrees always land flat at `<main-repo>/.worktrees/<slug>/` and never nest — even when invoked from inside another worktree. (Raw `git worktree add` resolves `.worktrees/` against the *current* worktree, which nests.)
- Always create git worktrees INSIDE the main project's working directory (a gitignored `.worktrees/<slug>/`), never in a sibling or parent directory. Only the working directory is writable under the command sandbox, so a worktree placed outside it breaks writes (file edits, moves, archives) and forces sandbox overrides.
- Remove worktrees with `fish -c 'wt clean'` (dry-run; add `--force` to apply) — it removes only worktrees merged into `origin/HEAD` and skips dirty ones. Reserve `git worktree prune` for repairing metadata after a manual `rm -rf`.
- Ignore the worktree location via `.git/info/exclude` (local, uncommitted) rather than the tracked `.gitignore`, unless a shared convention is explicitly wanted.

## Code Navigation
LSP servers are available for Python (.py, .pyi) and TypeScript/JavaScript (.ts, .tsx, .js, .jsx).

For these file types, always prefer LSP over Grep/Glob/Read for code navigation:
- Finding symbol definitions → LSP goToDefinition
- Finding usages → LSP findReferences
- Listing symbols in a file → LSP documentSymbol
- Type information → LSP hover
- Errors and warnings → LSP diagnostics

For all other file types, use Grep/Glob/Read as normal.