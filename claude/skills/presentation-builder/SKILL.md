---
name: presentation-builder
description: Build standalone HTML presentations from a markdown outline or bullet list, with reliable PDF export. Use this skill whenever the user wants to make a slide deck, talk, slideshow, pitch, lecture, conference presentation, or "turn these notes into slides" — even when they don't say the word "presentation". Also use when the user has an existing HTML deck and wants to enhance, restyle, or convert it. Produces a single self-contained HTML file plus a PDF that matches the browser preview pixel-for-pixel.
---

# Presentation Builder

Build single-file HTML presentations that survive the round-trip from browser to PDF without layout drift.

## Core principles

1. **Single file, zero dependencies.** One HTML file with inline CSS and JS. Open it in any browser. No build step, no npm.
2. **Fixed-canvas layout.** Every slide is a fixed-pixel rectangle (e.g., 1123×794 for A4 landscape, or 1920×1080 for 16:9). JS scales the whole canvas to fit the viewport. **Do not reflow content per device.** This is the single most important architectural choice — it's what makes the browser preview pixel-accurate to the PDF.
3. **PDF via screenshot, not print CSS.** Use the bundled `export_pdf.sh` which screenshots each slide via headless Chromium and assembles the PDF. This is more reliable than `@media print` overrides — see the [PDF export notes](#why-screenshot-based-pdf-export) below.
4. **Author from an outline.** The user gives you a markdown outline or bullet list. You turn it into slides — preserving their voice, not paraphrasing.
5. **Density matches purpose.** Speaker decks (live audience, big type, 1–3 bullets) and reading decks (handouts, dense, 4–6 bullets) want different layouts. Ask which one before generating.

## When to use this skill

Triggers strongly:

- "Make me a presentation about X"
- "Turn these notes into slides"
- "I'm giving a talk on X — help me build the deck"
- "Convert this outline to slides"
- "Make me a pitch deck / conference talk / lecture / keynote"

Also triggers (less obvious):

- "Help me prepare for my presentation tomorrow"
- "I have these bullets — can you make them look good?"
- "Build me a slideshow from this markdown"
- The user shares a markdown file structured as `## Slide N — Title` followed by bullets

Should NOT trigger for:

- A single static image or poster (use a graphics tool)
- Static text reports (use a doc/markdown formatter)
- Live web pages or dashboards (different design constraints)

---

## Phase 0: Detect mode

Determine which of three modes applies:

- **Mode A — New from outline:** The user has bullets / markdown / a brief. Go to Phase 1.
- **Mode B — Enhance existing:** The user has an HTML deck and wants edits, restyling, or new slides. Read the existing file first, understand its layout system, then make changes that preserve its conventions. **Critical:** the existing deck may already be a fixed-canvas layout — don't change the canvas dimensions or layout strategy unless asked.
- **Mode C — Convert from another format:** The user has a `.md`, `.txt`, or pasted text. Same as Mode A — treat the text as the outline.

If unclear, ask one short question to disambiguate, then proceed.

---

## Phase 1: Capture intent

Ask these questions together (use AskUserQuestion if available, otherwise one numbered list) — don't ask one at a time:

**Q1 — Page format**
Default: **A4 landscape** (1123×794 px). Offer also: 16:9 widescreen (1920×1080), 4:3 (1024×768).
A4 if they'll print or distribute as PDF for handouts. 16:9 if it's purely a projector/screen talk.

**Q2 — Density**
- *Speaker-led / low density:* live audience, big type, 1–3 bullets per slide. Slides are anchors; the speaker carries the content.
- *Reading-first / high density:* async distribution, dense slides with 4–6 bullets, captions, comparison tables. Slides carry the content.

**Q3 — Style**
Default: **Minimal Cream** (warm cream `#faf8f4` background, charcoal text, `#b8860b` accent — calm, conference-ready). Offer also:
- *Editorial Dark* (charcoal background, off-white text, single accent)
- *Swiss Modern* (white, black, red accent, Inter, structured grid)
- *Custom* (the user names a vibe; you generate something specific)

If the user names a style, try to honor it. The bundled `assets/styles.md` has the full preset definitions with colors and fonts.

**Q4 — Output destination**
- *HTML only* (they'll open in a browser, present from there)
- *HTML + PDF* (run the export script after generating)
- *Both, plus speaker notes* (each slide gets a `data-notes` attribute for the on-screen notes panel)

---

## Phase 2: Read the outline carefully

When the user provides an outline, read it as authored material — preserve their language. Common author-given structures:

```markdown
## Slide A1 — Title
- bullet
- bullet

> *Speaker note:* ...
```

Or a flatter list:

```markdown
# Topic
- key point
- key point
- key point
```

**Translation rules:**
- Each `## Slide N — Title` block becomes one slide. The text after the dash becomes `<h2>`. Bullets become `<li>`.
- Sub-bullets (indented) become nested `<ul>`. Render them smaller.
- Lines starting with `> *Speaker note:*` go into `data-notes` attribute on the slide, not on the slide itself.
- Quoted lines (`> "..."`) become `<div class="quote">` blocks — useful for citations, receipts, third-party endorsements.
- Image references like `![[name.png]]` (Obsidian-style) or `![alt](path)` become `<img src="...">`. Look for the file in adjacent `assets/` or `images/` directories.
- A line of just `# Title` at the top is the deck title.

**Don't paraphrase the user's bullets.** Their wording is intentional. Only adjust if a bullet literally doesn't fit on the slide — then ask before cutting.

If the outline is flat (no slide breaks), propose a slide structure and confirm with the user before generating. Don't silently invent slide breaks.

---

## Phase 3: Choose the canvas dimensions

Map the user's Q1 answer to fixed pixel dimensions:

| Format | Logical px (96 DPI) | Use case |
|---|---|---|
| A4 landscape | **1123 × 794** | print-friendly, handouts, conferences with paper materials |
| 16:9 widescreen | **1920 × 1080** | modern projectors, screen-only talks |
| 4:3 | **1024 × 768** | older projectors, internal classrooms |

These are *logical* px values — the canvas scales to the viewport at runtime via JS transform. The pixel values matter only as the design coordinate system; everything inside the canvas is sized in `px`/`rem`/`em` and stays consistent.

---

## Phase 4: Generate the HTML

Read `assets/template-base.html` and use it as the starting point. The template includes:

- The fixed-canvas CSS scaffold (deck wrapper + slide rules)
- The runtime JS (scale-to-fit, keyboard navigation, slide counter, speaker notes panel)
- Minimal print CSS (only handles page breaks, not layout)
- A placeholder for slides

Then for each slide in the outline, emit:

```html
<section class="slide" data-notes="speaker note text">
  <h3>kicker / section label (optional)</h3>
  <h2>The slide title</h2>
  <ul>
    <li>bullet</li>
    <li>bullet</li>
  </ul>
  <!-- optional: image, quote block, etc. -->
</section>
```

For special slide types, add a class:
- `class="slide title-slide"` — the deck cover (different typography)
- `class="slide demo-slide"` — a single-word slide ("Demo", "Q&A") with huge type
- `class="slide split"` — two-column: text left, image right (use `<div class="text">` and `<div class="visual">` inside)
- `class="slide image-only"` — full-bleed image, no text

For details on each layout pattern, see `assets/layouts.md`.

For the style preset (Q3), read `assets/styles.md` and include the matching CSS variable block at the top of the `<style>` section.

**Image handling:**
- If the outline references images (`![[file]]` or `![alt](path)`), check whether the files exist in the project's `assets/` or `images/` directory.
- If they do, use the relative path. If they don't, leave a comment in the HTML and tell the user.
- Constrain images: stacked layouts cap at ~380px height; split layouts cap at ~600px in the visual column. The template includes per-image overrides for known cases.

**Speaker notes:**
- Always preserve `data-notes` even if the user didn't ask for them on screen. They're harmless when hidden and useful for rehearsal.

---

## Phase 5: Export to PDF

Run the bundled script:

```bash
bash scripts/export_pdf.sh path/to/presentation.html
```

Optional second argument for the output path; otherwise it writes `presentation.pdf` next to the HTML.

The script:
1. Starts a tiny local HTTP server (so fonts and relative-path assets load)
2. Launches headless Chromium via Playwright
3. For each `.slide`, makes it visible and screenshots at the canvas dimensions
4. Assembles the screenshots into a single PDF with one slide per page

**First run** installs Playwright and downloads Chromium (~150 MB) into a temp directory. This takes 30–60 seconds; tell the user. Subsequent runs are fast.

Use `--compact` flag if file size matters (renders at 1280×720 — about 60% smaller).

### Why screenshot-based PDF export

Browser print-to-PDF and `@media print` CSS are unreliable: viewport units (`vh`, `vw`) translate poorly, fonts can break, layouts drift between screen and print, and image caps in `mm` vs `vh` get inconsistent.

The screenshot approach sidesteps all of this. The PDF is a snapshot of what the browser actually renders at the canvas dimensions. This means:

- ✓ Layout matches the browser preview pixel-for-pixel
- ✓ Custom fonts render correctly (browser already loaded them)
- ✓ Animations are captured at their final state (the screenshot waits for `prefers-reduced-motion`-friendly settle time)
- ✗ Live animations and interactivity are lost (acceptable tradeoff for a printable artifact)

If the user complains about animations missing in the PDF, that's a **feature** of the static export — point them at the HTML for the live version.

---

## Phase 6: Deliver

Tell the user:

1. **File location** of the HTML (and PDF if exported)
2. **How to open it** (`open path/to/file.html` or just double-click)
3. **Keyboard shortcuts** in the HTML viewer:
   - ← / → / Space — navigate
   - `f` — fullscreen
   - `n` — toggle speaker notes
   - `?` — help
4. **How to re-export PDF** if they edit the HTML manually

Don't dump the entire HTML into the chat. Just summarise: slide count, format, style, and where the file lives.

---

## Common pitfalls

These are mistakes I've seen and you should avoid:

**Mixing units.** Don't write `vh`/`vw` inside slide content. Stay in `px`/`rem`/`em`. The whole canvas scales, so percentages of viewport don't make sense at the slide level.

**Print CSS divergence.** Don't try to "fix" overflow by writing different rules in `@media print`. The screenshot-based export means print CSS is barely used. If a slide overflows on screen, fix it on screen — the PDF will inherit the fix.

**Image overflow.** Images larger than the slide canvas overflow silently. Always cap with `max-width: 100%; max-height: <value>px`. For split layouts, the visual column should cap around 600 px height.

**Too many bullets.** If a slide has more than ~6 bullets at speaker density or ~8 at reading density, split it. Cramming makes the slide unreadable in both formats.

**Paraphrasing the author.** If the user wrote "I was limited to one issue at a time", don't change it to "Working serially blocks parallel progress." Their voice is the talk.

**Inventing slides.** If the outline has 12 slides, generate 12 slides. Don't add a "thank you" or "questions?" unless they asked for one.

**Adding things that weren't requested.** No fade-in animations unless asked. No gradient overlays unless asked. No "let me also add a table of contents." Match the brief.

---

## Bundled assets

| File | Purpose | When to read |
|---|---|---|
| `assets/template-base.html` | Starting HTML with fixed-canvas scaffold and runtime JS | Phase 4 (always) |
| `assets/styles.md` | Three style presets (Minimal Cream, Editorial Dark, Swiss Modern) with CSS variable blocks | Phase 4, after the user picks a style |
| `assets/layouts.md` | Detailed reference for the 5 layout patterns (default, title, demo, split, image-only) with HTML examples | Phase 4, when emitting slides with non-trivial layout |
| `scripts/export_pdf.sh` | Playwright-based PDF exporter | Phase 5 |
| `references/troubleshooting.md` | Common issues and fixes (overflow, font loading, image paths) | Only when something breaks |
