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
