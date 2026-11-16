# OpenClaw on an always-on server

This puts the same setup that was tested in the cloud session (OpenRouter free models + Telegram bot) on a server
that stays on. The script has been syntax-checked but **not run on a real server yet**, so expect to send back an
error message or two the first time.

## What you need
| Thing | Notes |
|---|---|
| A Linux server running **Ubuntu 24.04** | 1 CPU and 2 GB of memory is enough. See "Getting a server" below. |
| An SSH app on your phone | For example Termius (iPhone and Android). |
| Your **OpenRouter API key** | From openrouter.ai → Keys. It has to be typed in on the server; it can't be copied from the cloud session. |
| A **Telegram bot token** | From @BotFather. Use a fresh one: send `/revoke` to BotFather for the old bot, because the old token was pasted into a chat. |

## Getting a server
- **Paid, simplest:** a small VPS from a provider such as Hetzner, DigitalOcean or Vultr. Roughly $4–6 a month; check
  the provider's current price.
- **Free:** Oracle Cloud's "Always Free" tier includes a small VM. Sign-up needs a card for identity checks and is
  sometimes refused.
- **A computer you already own** also works if it stays switched on and online. The script is for Ubuntu; on Windows,
  run it inside WSL.

When you create the server, pick Ubuntu 24.04 and note the IP address and login it gives you.

## Steps
1. Open the SSH app and connect to the server.
2. If you are logged in as `root`, make a normal user and switch to it:
   ```
   adduser claw && usermod -aG sudo claw && su - claw
   ```
3. Download and run the script:
   ```
   curl -fsSLO https://raw.githubusercontent.com/haynesashton03-eng/never/ccr-5627dfb2-onjrf2/openclaw-server/setup-openclaw-server.sh
   bash setup-openclaw-server.sh
   ```
   If the repo is private that download fails. In that case open the file on GitHub, copy its contents, run
   `nano setup-openclaw-server.sh` on the server, paste, save, and run the `bash` line.
4. Paste your OpenRouter key and Telegram token when asked. Nothing shows while you type; that's normal.
5. Message your bot in Telegram. It replies with a pairing code.
6. On the server run `openclaw pairing approve telegram <CODE>`.

## Day-to-day commands (on the server)
| Command | What it does |
|---|---|
| `openclaw daemon status` | Is the bot's service running? |
| `openclaw daemon restart` | Restart it |
| `openclaw channels status` | Is Telegram connected? |
| `openclaw doctor` | Health check with suggested fixes |
| `openclaw logs` | Recent activity |

## Things to know
- **Only one place can run the bot at a time.** A Telegram token can't be used by two OpenClaw installs at once, so
  don't restart the cloud-session copy after the server is live.
- **Free models have daily limits** on OpenRouter, and they're low for accounts with no credits. If the bot goes quiet,
  that's the likely cause. Adding credits and switching to a paid model fixes it:
  `openclaw models set openrouter/<model id>`.
- **OpenClaw can run commands on the server it lives on.** Keep that server for the bot only; don't store anything
  personal on it. The pairing step is what stops strangers from using your bot.
- **Keep the server updated:** `sudo apt update && sudo apt upgrade -y` now and then, and `sudo npm install -g openclaw`
  to update OpenClaw.
