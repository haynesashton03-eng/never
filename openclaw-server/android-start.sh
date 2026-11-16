#!/data/data/com.termux/files/usr/bin/bash
# Run in Termux to start the bot:  bash ~/android-start.sh
# Keeps the phone awake for Termux and restarts OpenClaw if it stops. Press Ctrl+C twice to quit.

termux-wake-lock
trap 'termux-wake-unlock; exit 0' INT TERM

while true; do
  echo "[$(date '+%H:%M:%S')] starting OpenClaw gateway"
  proot-distro login ubuntu -- openclaw gateway run
  echo "[$(date '+%H:%M:%S')] gateway stopped, restarting in 10 seconds"
  sleep 10
done
