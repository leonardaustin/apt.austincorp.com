#!/usr/bin/env bash
# build-pages.sh — Assemble the Cloudflare Pages deploy output for
# apt.hitoric.com, deliberately excluding pool/.
#
# Why: Cloudflare Pages rejects a deploy containing any single asset over
# 25 MiB (https://developers.cloudflare.com/pages/platform/limits/). The
# .deb packages under pool/ blow past that -- mezite_0.2.24_amd64.deb alone
# is ~34.7 MB -- so pool/ is never part of the Pages build. Cloudflare
# (apt.hitoric.com) serves dists/, index.html and pubkey.gpg; GitHub Pages
# (https://leonardaustin.github.io/apt.hitoric.com/) keeps serving pool/,
# and _redirects bridges the two so `apt install` never notices the split.
#
# DO NOT add pool/ to the output directory below. If a future package push
# apt.hitoric.com over the Pages asset cap indirectly (e.g. total deploy
# size), the fix is upstream of this script -- not by folding pool/ back in
# here. See README.md's "Why pool/ isn't part of the Pages build" section
# and _redirects for the full reasoning.
#
# Usage: build-pages.sh [output-dir]   (default: ./public)
#
# This is the build command Cloudflare Pages runs; the output directory
# argument must match what's configured as the project's build output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="${1:-$SCRIPT_DIR/public}"

# --- Build provenance ---------------------------------------------------
# Cloudflare Pages exposes CF_PAGES_COMMIT_SHA / CF_PAGES_BRANCH in its
# build environment. Fall back to git for local builds, and to "unknown"
# rather than fabricating a value if neither source has an answer -- see
# the 9 June stale-origin incident this stamp exists to make visible.
COMMIT_SHA="${CF_PAGES_COMMIT_SHA:-}"
if [ -z "$COMMIT_SHA" ]; then
  COMMIT_SHA="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null || true)"
fi
COMMIT_SHA="${COMMIT_SHA:-unknown}"

SHORT_SHA="$COMMIT_SHA"
if [ "$COMMIT_SHA" != "unknown" ]; then
  SHORT_SHA="${COMMIT_SHA:0:7}"
fi

BRANCH="${CF_PAGES_BRANCH:-}"
if [ -z "$BRANCH" ]; then
  BRANCH="$(git -C "$SCRIPT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
fi
BRANCH="${BRANCH:-unknown}"

BUILT_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ "$COMMIT_SHA" != "unknown" ]; then
  BUILD_STAMP_HTML="Built from <a href=\"https://github.com/leonardaustin/apt.hitoric.com/commit/${COMMIT_SHA}\">${SHORT_SHA}</a> (${BRANCH}) at ${BUILT_AT}"
else
  BUILD_STAMP_HTML="Built from ${COMMIT_SHA} (${BRANCH}) at ${BUILT_AT}"
fi

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp -R "$SCRIPT_DIR/dists" "$OUT_DIR/dists"
cp "$SCRIPT_DIR/pubkey.gpg" "$OUT_DIR/pubkey.gpg"
cp "$SCRIPT_DIR/_redirects" "$OUT_DIR/_redirects"

# Stamp the copy in $OUT_DIR only -- index.html in the repo carries the
# literal __BUILD_STAMP__ placeholder and must never be rewritten in place,
# or every build would dirty the working tree.
INDEX_HTML="$(cat "$SCRIPT_DIR/index.html")"
printf '%s\n' "${INDEX_HTML//__BUILD_STAMP__/$BUILD_STAMP_HTML}" > "$OUT_DIR/index.html"

# Machine-readable marker for automated delivery checks (curl + jq, no HTML
# scraping needed) -- see README.md's Cloudflare/GitHub Pages split section.
cat > "$OUT_DIR/version.json" <<EOF
{
  "commit": "${COMMIT_SHA}",
  "commit_short": "${SHORT_SHA}",
  "branch": "${BRANCH}",
  "built_at": "${BUILT_AT}"
}
EOF

echo "==> Pages output assembled at $OUT_DIR (pool/ excluded -- see build-pages.sh header)"
echo "==> Build stamp: ${COMMIT_SHA} (${BRANCH}) at ${BUILT_AT}"
