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

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp -R "$SCRIPT_DIR/dists" "$OUT_DIR/dists"
cp "$SCRIPT_DIR/index.html" "$OUT_DIR/index.html"
cp "$SCRIPT_DIR/pubkey.gpg" "$OUT_DIR/pubkey.gpg"
cp "$SCRIPT_DIR/_redirects" "$OUT_DIR/_redirects"

echo "==> Pages output assembled at $OUT_DIR (pool/ excluded -- see build-pages.sh header)"
