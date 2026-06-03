# Layout Patterns

Five layout patterns are built into the template. Pick the right one for each slide; don't invent new ones unless asked. Keeping the vocabulary small makes the deck feel coherent.

---

## 1. Default content slide

The workhorse. Header + bullets, optionally with an image stacked below.

```html
<section class="slide" data-notes="speaker note">
  <h3>Section kicker</h3>
  <h2>The slide title</h2>
  <ul>
    <li>First bullet</li>
    <li>Second bullet</li>
    <li>Third bullet — emphasis with <strong>bold</strong> or <em>italic</em></li>
  </ul>
</section>
```

With an image below the bullets (image caps at 380 px height):

```html
<section class="slide">
  <h3>Section kicker</h3>
  <h2>Title</h2>
  <ul><li>...</li></ul>
  <img src="assets/diagram.svg" alt="...">
</section>
```

Use when: 3–6 bullets, content is the focus.

---

## 2. Title slide

The deck cover. Big type, centered, no bullets.

```html
<section class="slide title-slide active">
  <h1>The Talk Title</h1>
  <div class="subtitle">A subtitle — italicised, in muted color</div>
  <div class="byline">Speaker Name · Conference Name · Date</div>
</section>
```

Always use `title-slide` for the first slide and add `active` so it shows on load.

---

## 3. Demo / single-word slide

Massive single word for visual punctuation: "Demo", "Q&A", "Thanks", a number, etc.

```html
<section class="slide demo-slide">
  <h1>Demo</h1>
</section>
```

Use sparingly — once or twice per deck. Power comes from contrast with the dense slides around it.

---

## 4. Split layout — text left, image right

Two-column layout: bullets on the left, image on the right. Use when the image deserves equal weight with the text.

```html
<section class="slide split">
  <div class="text">
    <h3>Kicker</h3>
    <h2>Title</h2>
    <ul>
      <li>Bullet 1</li>
      <li>Bullet 2</li>
    </ul>
  </div>
  <div class="visual">
    <img src="assets/photo.jpg" alt="...">
  </div>
</section>
```

The split is 55% text / 45% image by default. If the image is the focus and bullets are short, swap the proportions per-slide:

```html
<section class="slide split visual-heavy">...</section>
```

…and add this CSS once (per the talk deck we built earlier):

```css
.slide.split.visual-heavy .text   { flex: 0 1 38%; }
.slide.split.visual-heavy .visual { flex: 1 1 62%; }
.slide.split.visual-heavy .visual img { max-height: 660px; }
```

Use when: image and text are roughly equal in importance.

---

## 5. Overlay-right — image floating on the right, text in default column

Like the split, but the text occupies its normal full width *up to a cap*, and the image is absolutely positioned. Useful when you want the same text layout as the previous slide (so the audience isn't visually reset) but with an image added.

```html
<section class="slide overlay-right">
  <h3>Kicker</h3>
  <h2>Title</h2>
  <ul>
    <li>Bullet 1</li>
    <li>Bullet 2</li>
  </ul>
  <img src="assets/photo.jpg" class="overlay-image" alt="...">
</section>
```

The image is centered vertically on the right side. Text is constrained to ~600 px width so it doesn't run under the image.

Use when: a slide N has bullets-only and slide N+1 keeps the same bullets but adds a visual punchline.

---

## 6. Image-only — full bleed

Just an image. No padding, no text.

```html
<section class="slide image-only">
  <img src="assets/big-image.jpg" alt="...">
</section>
```

Use for: a meme that needs to dominate, a cover photo, a product shot. Sparingly.

---

## Quote blocks (within any layout)

For citations, README receipts, or third-party endorsements:

```html
<div class="quote">
  <strong>Source name</strong>: "The literal quoted text."
</div>
```

Quote blocks have a left accent border and muted text. Stack 2–4 quotes for a "receipts" slide.

---

## Layout selection rules

For each slide in the outline, pick the layout this way:

1. **Is it the first slide and the deck has a title?** → `title-slide`
2. **Is it just a single word/number/punchline?** → `demo-slide`
3. **Does it have an image?**
   - No image → default
   - Image is the point → `image-only`
   - Image deserves equal space with text → `split`
   - Slide N+1 needs the same text layout as slide N but with an image added → `overlay-right`
4. **Otherwise** → default

Don't mix multiple layout classes on one slide unless explicitly designed (e.g., `split visual-heavy` is fine; `split image-only` is contradictory).

---

## Density guidelines

Apply these caps based on the user's Q2 (density) answer:

| Slide type | Speaker density | Reading density |
|---|---|---|
| Default | 3–4 bullets | 5–8 bullets |
| Split | 3 bullets in text col | 5 bullets in text col |
| Title | 1 line + subtitle | same |
| Demo | 1 word | same |

If a slide overflows the cap, **split it into two slides**, don't shrink the type. Cramped slides are unreadable in both formats.

If the user's outline gives you 8 bullets for one slide and they're at speaker density, ask before splitting — they may have intended exactly 8.
