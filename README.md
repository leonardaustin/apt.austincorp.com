# apt.hitoric.com

APT package repository for Hitoric's projects.

## Setup

```bash
# Add the signing key
curl -fsSL https://apt.hitoric.com/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/hitoric.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/hitoric.gpg] https://apt.hitoric.com stable main" | sudo tee /etc/apt/sources.list.d/hitoric.list

# Install packages
sudo apt update
sudo apt install clusterfudge
```

## Available packages

- **clusterfudge** — Kubernetes cluster management desktop app

## Hosting: Cloudflare Pages + GitHub Pages split

`apt.hitoric.com` is served by Cloudflare Pages, built from this repo via
`build-pages.sh` — but that build deliberately **excludes `pool/`**. Cloudflare
Pages rejects a deploy containing any single asset over 25 MiB
(https://developers.cloudflare.com/pages/platform/limits/), and the `.deb`
files in `pool/` routinely exceed that (`mezite_0.2.24_amd64.deb` is ~34.7 MB).

Instead:

- Cloudflare Pages serves `dists/`, `index.html`, and `pubkey.gpg` — the
  small stuff, built by `build-pages.sh` into a `public/` output directory.
- `pool/` (the actual `.deb` packages) is served straight from GitHub Pages:
  https://leonardaustin.github.io/apt.hitoric.com/pool/
- `_redirects` bridges the two: a request to `apt.hitoric.com/pool/*` 302s to
  the same path on GitHub Pages. `Filename:` entries in
  `dists/stable/main/binary-*/Packages` are repo-relative
  (`pool/pkg_ver_arch.deb`), and `apt` follows HTTP redirects, so this is
  invisible to `apt install`.

**If you're about to add `pool/` back to the Pages build output: don't.** It
will deploy fine for small packages and then fail the moment any package
(or a new arch of an existing one) crosses 25 MiB — which is exactly the
failure mode this split exists to avoid. If a package's `.deb` needs to be
reachable from Cloudflare directly for some reason, that's a sign the
GitHub Pages split needs revisiting, not a reason to bypass it here.

`scripts/publish-apt.sh` in `mezite-mono` writes `_redirects` and
`build-pages.sh` on every publish, so they can't be silently dropped by a
future change to that script.
