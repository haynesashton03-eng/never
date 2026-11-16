#!/usr/bin/env bash
# Step 2 of 2. Runs inside the Ubuntu environment (android-1-termux.sh starts it for you).
# Installs Node 24 and OpenClaw, then connects OpenRouter (free models) and Telegram.
set -euo pipefail

MAIN_MODEL="openrouter/nvidia/nemotron-3-ultra-550b-a55b:free"
FALLBACKS=(
  "openrouter/nvidia/nemotron-3.5-super-vl:free"
  "openrouter/baidu/ernie-5.5-flash-preview:free"
  "openrouter/recursive/flint-v1.0:free"
)
IMAGE_MODEL="openrouter/nvidia/nemotron-3.5-super-vl:free"

echo "== 1/4 Installing Node 24 =="
if ! command -v node >/dev/null || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 24 ]; then
  curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
  apt-get install -y nodejs
fi
node -v

echo "== 2/4 Installing OpenClaw (several minutes on a phone) =="
npm install -g openclaw
openclaw --version

echo "== 3/4 Your keys (typing is hidden) =="
read -r -s -p "OpenRouter API key (starts with sk-or-): " OPENROUTER_KEY; echo
read -r -s -p "Telegram bot token from BotFather: " TELEGRAM_TOKEN; echo
[ -n "$OPENROUTER_KEY" ] && [ -n "$TELEGRAM_TOKEN" ] || { echo "Both values are required." >&2; exit 1; }

echo "== 4/4 Configuring OpenClaw =="
# --accept-risk acknowledges OpenClaw's warning that its agents can run commands on this device.
openclaw onboard --non-interactive --accept-risk --flow quickstart --mode local \
  --auth-choice openrouter-api-key --openrouter-api-key "$OPENROUTER_KEY" \
  --gateway-bind loopback --gateway-auth token --no-install-daemon --skip-health

openclaw models set "$MAIN_MODEL"
for m in "${FALLBACKS[@]}"; do openclaw models fallbacks add "$m"; done
openclaw models set-image "$IMAGE_MODEL"
openclaw channels add --channel telegram --token "$TELEGRAM_TOKEN"
unset OPENROUTER_KEY TELEGRAM_TOKEN

echo "OpenClaw is configured."
