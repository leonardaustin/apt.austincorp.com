# apt.austincorp.com

APT package repository for Austin Corp open source projects.

## Setup

```bash
# Add the signing key
curl -fsSL https://apt.austincorp.com/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/austincorp.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/austincorp.gpg] https://apt.austincorp.com stable main" | sudo tee /etc/apt/sources.list.d/austincorp.list

# Install packages
sudo apt update
sudo apt install clusterfudge
```

## Available packages

- **clusterfudge** — Kubernetes cluster management desktop app
