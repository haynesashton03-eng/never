#!/usr/bin/env bash
# Sets up OpenClaw as an always-on service on a fresh Ubuntu 24.04 server.
# Run it as a normal user with sudo rights:  bash setup-openclaw-server.sh
# It asks for your OpenRouter key and Telegram bot token; neither is echoed or saved in shell history.
set -euo pipefail

MAIN_MODEL="openrouter/nvidia/nemotron-3-ultra-550b-a55b:free"
FALLBACKS=(
  "openrouter/nvidia/nemotron-3.5-super-vl:free"
  "openrouter/baidu/ernie-5.5-flash-preview:free"
  "openrouter/recursive/flint-v1.0:free"
)
IMAGE_MODEL="openrouter/nvidia/nemotron-3.5-super-vl:free"

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as a normal user, not root (create one with: adduser claw && usermod -aG sudo claw)." >&2
  exit 1
fi

echo "== 1/6 Installing Node 24 =="
if ! command -v node >/dev/null || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 24 ]; then
  curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
  sudo apt-get install -y nodejs
fi
node -v

echo "== 2/6 Installing OpenClaw =="
sudo npm install -g openclaw
openclaw --version

echo "== 3/6 Your keys (typing is hidden) =="
read -r -s -p "OpenRouter API key (starts with sk-or-): " OPENROUTER_KEY; echo
read -r -s -p "Telegram bot token from BotFather: " TELEGRAM_TOKEN; echo
[ -n "$OPENROUTER_KEY" ] && [ -n "$TELEGRAM_TOKEN" ] || { echo "Both values are required." >&2; exit 1; }

echo "== 4/6 Keeping the service alive after you log out =="
sudo loginctl enable-linger "$USER"

echo "== 5/6 Onboarding OpenClaw and installing the background service =="
# --accept-risk acknowledges OpenClaw's warning that its agents can run commands on this server.
openclaw onboard --non-interactive --accept-risk --flow quickstart --mode local \
  --auth-choice openrouter-api-key --openrouter-api-key "$OPENROUTER_KEY" \
  --gateway-bind loopback --gateway-auth token --install-daemon

openclaw models set "$MAIN_MODEL"
for m in "${FALLBACKS[@]}"; do openclaw models fallbacks add "$m"; done
openclaw models set-image "$IMAGE_MODEL"

echo "== 6/6 Linking Telegram =="
openclaw channels add --channel telegram --token "$TELEGRAM_TOKEN"
unset OPENROUTER_KEY TELEGRAM_TOKEN

openclaw daemon restart || true
openclaw daemon status || true
openclaw channels status || true

cat <<'EOF'

Done. Last step:
  1. Message your bot in Telegram. It replies with a pairing code.
  2. On this server run:  openclaw pairing approve telegram <CODE>
After that the bot answers you, and it restarts by itself if the server reboots.
EOF
