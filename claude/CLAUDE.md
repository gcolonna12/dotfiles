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
- Do NOT hard-wrap Markdown prose at a fixed column. Use one sentence per line, or leave paragraphs unwrapped. Only wrap to a specific width if I explicitly ask.
- When writing Markdown prose OR docstrings/block comments, follow Semantic Line Breaks (https://sembr.org/): break lines at sentence and clause boundaries, not at a fixed column.

## Engineering principles
These are the values behind the rules above — apply them when a rule doesn't
settle a call. (The DRY, deep-modules, small-functions, and comments-explain-why
principles already live in the rules above; not repeated here.)
- **ETC is the tie-breaker.** When two designs are otherwise equal, pick the one
  that's Easier To Change. "Good design" = "easy to change."
- **Strategic over tactical.** Don't just make the feature work; spend design
  effort finding the clean solution and fixing the underlying issue. A little
  proactive design now beats compounding cruft later.
- **Boy Scout Rule / no broken windows.** Leave code cleaner than you found it,
  and fix bad designs the moment you spot them — small continuous cleanups stop
  the rot. (Litter-pickup is fine mid-task; a *large* refactor is its own change.)
- **Two hats.** Adding functionality and refactoring are separate acts — never do
  both in one change. This is the "why" behind the atomic-PR rule below: split a
  preparatory or comprehension refactor into its own commit/PR before the feature.
- **Refactor in tiny, safe steps.** Behavior-preserving transformations, one at a
  time; run the check (compile/test/lint) after each so a break is easy to locate.
- **Law of Demeter / Tell, Don't Ask.** No `a.getB().getC()` train wrecks — talk
  to immediate collaborators, tell an object to act rather than reaching through
  it. Keep components orthogonal so a change in one doesn't ripple into others.
- **Separate construction from use.** Wiring/startup (DI, factories) stays out of
  the runtime logic it assembles.
- **Crash early (Design by Contract).** On an impossible condition, fail loudly at
  the problem site — never let corrupted state propagate. Complements "be strict
  at the validation boundary" below.
- **Allocator owns deallocation.** Whatever acquires a resource (file, socket,
  lock, temp dir) is responsible for releasing it; prefer a scoped construct
  (`with`, RAII, `defer`) over manual paired cleanup.
- **Tests-first as a design tool.** For genuinely new code, write the test first —
  it's the first user of your API and forces decoupling and a clear contract. Keep
  tests F.I.R.S.T. (Fast, Independent, Repeatable, Self-Validating, Timely).
- **Data/object anti-symmetry.** Pick one per type: an *object* hides its data and
  exposes behavior; a *data structure* exposes its data and has no behavior. Don't
  build hybrids that half-expose state and half-wrap it.
- **Composition over inheritance.** Has-A trumps Is-A. Reach for interfaces/mixins/
  delegation for polymorphism; subclass only for a genuine is-a with a stable base.
- **Command-Query Separation.** A function either changes state (command, returns
  nothing) or answers a question (query, no side effects) — never both.
- **No primitive obsession.** Wrap domain concepts in small value objects instead
  of bare `str`/`int`/`dict` (extends the `NewType` rule below to things with
  constraints or behavior — `Money`, `Coordinate`).
- **Don't use null as a lazy sentinel.** Returning null to mean "nothing" forces
  defensive checks at every call site; prefer an empty collection or a Null Object.
  (Language-aware: a *typed* `Optional`/`None` that the signature advertises is fine
  — see the Python `None` rules below; the smell is the unadvertised null.)
- **No flag arguments.** A boolean param that switches behavior means the function
  does two things — split it into two named functions.
- **Shared mutable state is a bug waiting to happen.** Concurrency bugs come from
  threads touching shared mutable data. Keep data thread-local, pass copies, or use
  an actor/queue model — don't reach for locks around shared memory by default.
- **Tracer bullets over big-bang.** Build a thin end-to-end skeleton first to prove
  the architecture and get feedback, then flesh it out — don't build one layer fully
  before the others exist.
- **Rule of Three for abstraction.** Don't abstract on the first or second
  occurrence; extract the shared abstraction on the third. Premature DRY couples
  things that only looked alike.
- **Prove it, don't assume it.** When debugging, verify the failing code in context
  rather than trusting it works. "Select isn't broken" — suspect your own code
  before the OS, compiler, or a mature library.
- **Different layer, different abstraction.** Adjacent layers must each add real
  abstraction. A method/variable that only forwards to the next layer is a
  pass-through smell — collapse it.
- **No temporal decomposition.** Structure modules around a piece of *knowledge*
  they own, not around the time-order of operations (do-A-then-B-then-C). Time
  order in the module structure leaks information across boundaries.
- **Design it twice.** For a non-trivial design, sketch at least two approaches and
  compare before committing to one — the first idea is rarely the simplest.
- **Clean narrow interface, not over-fitted.** Shape an interface around the
  concept, not around one caller's exact current need — that's what makes a module
  deep and reusable. This is NOT license for speculative knobs: it still obeys "no
  parameters/options just in case" below. General in *shape*, minimal in *surface*.
- **Maintain reversibility.** Assume big decisions (DB, vendor, deploy target,
  third-party API) will change — hide them behind your own seam so they can be
  swapped without rippling through the codebase.
- **Assert what can't happen.** If a state is "impossible", assert it explicitly so
  it fails loudly if it ever occurs; keep assertions on in production. Pairs with
  "crash early" above.
- **Small critical sections; spurious failure = concurrency bug.** Keep locked/
  synchronized regions as small as possible. Treat any intermittent/random failure
  as a threading issue to hunt down, never a one-off to shrug off.
- **Automate builds/tests/deploys.** Never rely on a manual procedure for anything
  repeatable — humans aren't repeatable. Put it in a script.

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