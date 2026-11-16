#!/data/data/com.termux/files/usr/bin/bash
# Step 1 of 2. Run this in Termux on the Android phone:  bash android-1-termux.sh
# It installs an Ubuntu environment inside Termux, then runs the OpenClaw setup inside it.
set -euo pipefail

RAW="https://raw.githubusercontent.com/haynesashton03-eng/never/ccr-5627dfb2-onjrf2/openclaw-server"

echo "== Updating Termux =="
pkg update -y
pkg upgrade -y
pkg install -y proot-distro curl

echo "== Installing Ubuntu inside Termux (a few minutes) =="
proot-distro install ubuntu || echo "Ubuntu already installed, continuing."

echo "== Saving the start script =="
curl -fsSLo "$HOME/android-start.sh" "$RAW/android-start.sh"
chmod +x "$HOME/android-start.sh"

echo "== Setting up OpenClaw inside Ubuntu =="
proot-distro login ubuntu -- bash -c "
  set -e
  apt-get update
  apt-get install -y curl ca-certificates
  curl -fsSLo /root/android-2-ubuntu.sh '$RAW/android-2-ubuntu.sh'
  bash /root/android-2-ubuntu.sh
"

cat <<'EOF'

Setup finished. Start the bot with:
  bash ~/android-start.sh
Leave that running, then follow the pairing step in ANDROID.md.
EOF
