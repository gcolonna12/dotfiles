# Style Presets

Three opinionated presets. Each is a CSS variable block you paste into `:root` of the template. The presets only override colors and fonts — layout, sizing, and structure stay the same across presets.

When the user picks a style, replace the `:root` block in `template-base.html` with the matching block below. If they ask for a custom style, design something new but still expose colors via the same variable names so the rest of the template keeps working.

---

## Preset 1 — Minimal Cream (default)

Calm, conference-ready, warm. Cream background, charcoal text, single warm accent. Default for technical talks.

```css
:root {
  --bg: #faf8f4;
  --ink: #1a1a1a;
  --muted: #5a5a5a;
  --accent: #b8860b;       /* warm amber */
  --rule: #d8d4ca;
  --code-bg: #f0ece2;
  --note-bg: #fff7e0;
  --frame-bg: #2a2a2a;     /* dark frame around scaled canvas */

  --font-body: "Inter", system-ui, sans-serif;
  --font-mono: ui-monospace, "SF Mono", Menlo, monospace;
}
```

Best for: software talks, technical content, conferences with a contemplative tone.

---

## Preset 2 — Editorial Dark

Charcoal background, off-white text, single accent. Higher contrast, more dramatic. Good for keynotes and pitches.

```css
:root {
  --bg: #1a1a1a;
  --ink: #f5f3ee;
  --muted: #9a9a9a;
  --accent: #e8c170;       /* warm gold */
  --rule: #3a3a3a;
  --code-bg: #2a2a2a;
  --note-bg: #2a2a2a;
  --frame-bg: #0a0a0a;

  --font-body: "Inter", system-ui, sans-serif;
  --font-mono: ui-monospace, "SF Mono", Menlo, monospace;
}
```

Add this rule to brighten code blocks against dark slides:

```css
.slide code { color: #f5f3ee; }
.slide a { color: var(--accent); }
.help-pill kbd { color: var(--ink); background: var(--code-bg); }
```

Best for: pitch decks, product launches, anything where impact > readability.

---

## Preset 3 — Swiss Modern

White, black, single red accent. Tight grid, no decoration, maximum legibility. Inspired by Müller-Brockmann, IBM design history.

```css
:root {
  --bg: #ffffff;
  --ink: #000000;
  --muted: #555555;
  --accent: #d62828;       /* signal red */
  --rule: #e0e0e0;
  --code-bg: #f4f4f4;
  --note-bg: #fffbe6;
  --frame-bg: #e0e0e0;

  --font-body: "Inter", "Helvetica Neue", Helvetica, sans-serif;
  --font-mono: "IBM Plex Mono", ui-monospace, Menlo, monospace;
}
```

Best for: research talks, structured analytical content, anything that benefits from feeling rigorous and uncluttered.

---

## Custom presets

If the user asks for a vibe that isn't covered (e.g., "make it feel like a 90s game manual" or "match our brand colors"), generate a new variable block. Stay disciplined:

- **Background**: high-contrast against text, no gradients unless explicitly asked
- **Accent**: ONE color, used for bullet markers, strong text underlines, and the help pill border
- **Fonts**: pick deliberately. Avoid generic stack defaults. If you cite a Google Font, add the `<link>` tag in `<head>` and use the font name in the variable
- **Frame background**: the color *outside* the slide canvas (visible on widescreen monitors). Usually a darker version of the bg, or a neutral

Test the preset by reading the existing demo slides — bullets, code, links, quote blocks, and the help pill should all remain legible. If anything fails, adjust the variable rather than restructuring the slide.

## Adding fonts

If the preset uses a non-system font, include the Google Fonts or Fontshare link in `<head>` before the `<style>` block:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
```

The PDF export script waits for `document.fonts.ready` before screenshotting, so web fonts render correctly in the PDF.
