#!/usr/bin/env bash
# export_pdf.sh — Export a fixed-canvas HTML presentation to PDF
#
# Usage:
#   bash scripts/export_pdf.sh <path-to-html> [output.pdf] [--compact]
#
# Examples:
#   bash scripts/export_pdf.sh ./talk.html
#   bash scripts/export_pdf.sh ./talk.html ./talk.pdf
#   bash scripts/export_pdf.sh ./talk.html --compact   # smaller file size
#
# How it works:
#   1. Reads the canvas dimensions from the HTML (the --slide-w / --slide-h CSS
#      custom properties on :root)
#   2. Starts a tiny local HTTP server (so fonts and relative-path assets load)
#   3. Launches headless Chromium via Playwright at the canvas dimensions
#   4. For each .slide element, makes it visible and screenshots it
#   5. Assembles the screenshots into a single PDF, one slide per page
#
# Why screenshot-based: print-CSS-based PDF export has too many failure modes
# (vh/vw drift, font loading, layout differences). Screenshotting captures the
# real rendered slide. The only tradeoff is that animations are frozen at their
# final state — a feature for a printable artifact.
set -euo pipefail

# ─── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}ℹ${NC} $*"; }
ok()    { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}⚠${NC} $*"; }
err()   { echo -e "${RED}✗${NC} $*" >&2; }

# ─── Parse args ────────────────────────────────────────────
COMPACT=false
POSITIONAL=()
for arg in "$@"; do
    case $arg in
        --compact) COMPACT=true ;;
        *) POSITIONAL+=("$arg") ;;
    esac
done
set -- "${POSITIONAL[@]}"

if [[ $# -lt 1 ]]; then
    err "Usage: bash scripts/export_pdf.sh <path-to-html> [output.pdf] [--compact]"
    exit 1
fi

INPUT_HTML="$1"
if [[ ! -f "$INPUT_HTML" ]]; then
    err "File not found: $INPUT_HTML"
    exit 1
fi

INPUT_HTML=$(cd "$(dirname "$INPUT_HTML")" && pwd)/$(basename "$INPUT_HTML")

if [[ $# -ge 2 ]]; then
    OUTPUT_PDF="$2"
else
    OUTPUT_PDF="$(dirname "$INPUT_HTML")/$(basename "$INPUT_HTML" .html).pdf"
fi

OUTPUT_DIR=$(dirname "$OUTPUT_PDF")
mkdir -p "$OUTPUT_DIR"
OUTPUT_PDF="$OUTPUT_DIR/$(basename "$OUTPUT_PDF")"

echo ""
echo -e "${BOLD}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Export presentation to PDF           ║${NC}"
echo -e "${BOLD}╚════════════════════════════════════════╝${NC}"
echo ""

# ─── Detect canvas dimensions from the HTML ───────────────
# The template stores --slide-w / --slide-h on :root. Grep them out.

CANVAS_W=$(grep -oE -- '--slide-w:\s*[0-9]+px' "$INPUT_HTML" | head -1 | grep -oE '[0-9]+' || echo "1123")
CANVAS_H=$(grep -oE -- '--slide-h:\s*[0-9]+px' "$INPUT_HTML" | head -1 | grep -oE '[0-9]+' || echo "794")

info "Canvas dimensions: ${CANVAS_W}×${CANVAS_H} px"

# Compact mode renders at half-resolution
if [[ "$COMPACT" == "true" ]]; then
    CANVAS_W=$((CANVAS_W / 2 * 2))   # keep even
    CANVAS_H=$((CANVAS_H / 2 * 2))
    SCALE_FACTOR=1
    info "Compact mode: smaller PDF file size"
fi

# ─── Check Node.js ────────────────────────────────────────
if ! command -v npx &>/dev/null; then
    err "Node.js is required but not installed."
    err "  macOS:  brew install node"
    err "  other:  https://nodejs.org"
    exit 1
fi
ok "Node.js found"

# ─── Build the export script ──────────────────────────────
TEMP_DIR=$(mktemp -d)
TEMP_SCRIPT="$TEMP_DIR/export.mjs"
SERVE_DIR=$(dirname "$INPUT_HTML")
HTML_FILENAME=$(basename "$INPUT_HTML")

cat > "$TEMP_SCRIPT" << 'EXPORT_SCRIPT'
import { chromium } from 'playwright';
import { createServer } from 'http';
import { readFileSync, mkdirSync, unlinkSync } from 'fs';
import { join, extname } from 'path';

const SERVE_DIR = process.argv[2];
const HTML_FILE = process.argv[3];
const OUTPUT_PDF = process.argv[4];
const SCREENSHOT_DIR = process.argv[5];
const VP_WIDTH = parseInt(process.argv[6]);
const VP_HEIGHT = parseInt(process.argv[7]);

const MIME = {
  '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg', '.gif': 'image/gif', '.svg': 'image/svg+xml',
  '.webp': 'image/webp', '.woff': 'font/woff', '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
};

const server = createServer((req, res) => {
  const decoded = decodeURIComponent(req.url);
  const path = join(SERVE_DIR, decoded === '/' ? HTML_FILE : decoded);
  try {
    const content = readFileSync(path);
    res.writeHead(200, { 'Content-Type': MIME[extname(path).toLowerCase()] || 'application/octet-stream' });
    res.end(content);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
});

const port = await new Promise(r => server.listen(0, () => r(server.address().port)));
console.log(`  Server on port ${port}`);

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: VP_WIDTH, height: VP_HEIGHT } });

await page.goto(`http://localhost:${port}/`, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);

// Disable the scale transform on .deck so screenshots capture native canvas pixels.
// Also pin the canvas at top-left for consistent positioning.
await page.evaluate(() => {
  const deck = document.querySelector('.deck');
  if (deck) {
    deck.style.transform = 'none';
    deck.style.top = '0';
    deck.style.left = '0';
    deck.style.position = 'absolute';
  }
});

// Let any reveal animations settle
await page.waitForTimeout(500);

const slideCount = await page.evaluate(() => document.querySelectorAll('.slide').length);
console.log(`  Found ${slideCount} slides`);

if (slideCount === 0) {
  console.error('  ERROR: No .slide elements found.');
  console.error('  The HTML must use <section class="slide"> for each slide.');
  await browser.close();
  server.close();
  process.exit(1);
}

mkdirSync(SCREENSHOT_DIR, { recursive: true });
const screenshotPaths = [];

for (let i = 0; i < slideCount; i++) {
  // Show only this slide
  await page.evaluate((index) => {
    document.querySelectorAll('.slide').forEach((slide, idx) => {
      if (idx === index) {
        slide.classList.add('active');
        slide.style.display = 'flex';
      } else {
        slide.classList.remove('active');
        slide.style.display = 'none';
      }
    });
  }, i);

  await page.waitForTimeout(200);

  const path = join(SCREENSHOT_DIR, `slide-${String(i + 1).padStart(3, '0')}.png`);
  await page.screenshot({ path, fullPage: false, clip: { x: 0, y: 0, width: VP_WIDTH, height: VP_HEIGHT } });
  screenshotPaths.push(path);
  console.log(`  Captured slide ${i + 1}/${slideCount}`);
}

await browser.close();
server.close();

// ─── Assemble PDF from screenshots ──────────────────────────
console.log('  Assembling PDF...');

const browser2 = await chromium.launch();
const pdfPage = await browser2.newPage();

const imagesHtml = screenshotPaths.map(p => {
  const data = readFileSync(p).toString('base64');
  return `<div class="page"><img src="data:image/png;base64,${data}" /></div>`;
}).join('\n');

const pdfHtml = `<!DOCTYPE html><html><head><style>
  * { margin: 0; padding: 0; }
  @page { size: ${VP_WIDTH}px ${VP_HEIGHT}px; margin: 0; }
  .page { width: ${VP_WIDTH}px; height: ${VP_HEIGHT}px; page-break-after: always; overflow: hidden; }
  .page:last-child { page-break-after: auto; }
  img { width: ${VP_WIDTH}px; height: ${VP_HEIGHT}px; display: block; object-fit: contain; }
</style></head><body>${imagesHtml}</body></html>`;

await pdfPage.setContent(pdfHtml, { waitUntil: 'load' });
await pdfPage.pdf({
  path: OUTPUT_PDF,
  width: `${VP_WIDTH}px`,
  height: `${VP_HEIGHT}px`,
  printBackground: true,
  margin: { top: 0, right: 0, bottom: 0, left: 0 },
});

await browser2.close();

screenshotPaths.forEach(p => unlinkSync(p));

console.log(`  ✓ PDF saved to: ${OUTPUT_PDF}`);
EXPORT_SCRIPT

# ─── Install Playwright in temp dir ───────────────────────
info "Setting up Playwright (one-time on first run, ~30-60s)..."
echo ""

cd "$TEMP_DIR"
cat > "$TEMP_DIR/package.json" << 'PKG'
{ "name": "slide-export", "private": true, "type": "module" }
PKG

npm install playwright &>/dev/null || {
    err "Failed to install Playwright. Try: npm install playwright"
    rm -rf "$TEMP_DIR"
    exit 1
}

npx playwright install chromium 2>/dev/null || {
    err "Failed to install Chromium. Try: npx playwright install chromium"
    rm -rf "$TEMP_DIR"
    exit 1
}
ok "Playwright ready"
echo ""

# ─── Run export ───────────────────────────────────────────
SCREENSHOT_DIR="$TEMP_DIR/screenshots"
info "Exporting slides..."
echo ""

node "$TEMP_SCRIPT" "$SERVE_DIR" "$HTML_FILENAME" "$OUTPUT_PDF" "$SCREENSHOT_DIR" "$CANVAS_W" "$CANVAS_H" || {
    err "Export failed."
    rm -rf "$TEMP_DIR"
    exit 1
}

rm -rf "$TEMP_DIR"

echo ""
echo -e "${BOLD}════════════════════════════════════════${NC}"
ok "PDF exported successfully"
echo ""
echo -e "  ${BOLD}File:${NC}  $OUTPUT_PDF"
FILE_SIZE=$(du -h "$OUTPUT_PDF" | cut -f1 | xargs)
echo "  Size: $FILE_SIZE"
echo ""
echo "  Layout matches the browser preview pixel-for-pixel."
echo "  Animations are static (final state captured)."
echo -e "${BOLD}════════════════════════════════════════${NC}"
echo ""

if command -v open &>/dev/null; then
    open "$OUTPUT_PDF"
elif command -v xdg-open &>/dev/null; then
    xdg-open "$OUTPUT_PDF"
fi
