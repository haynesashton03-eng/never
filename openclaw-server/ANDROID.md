# OpenClaw on a spare Android phone (free)

The phone becomes the always-on server. Everything here is free. These scripts have **not been run on a real phone
yet**: the OpenClaw commands in them were tested in the cloud session, but the Android parts were not. If a step stops
with an error, copy the last few lines and send them over.

## Before you start
- The phone should stay **on charge and on Wi-Fi**.
- Have ready: your **OpenRouter API key** (openrouter.ai → Keys) and a **new Telegram bot token**. For the token, send
  `/revoke` to @BotFather, pick your bot, and copy the new token it gives you. The old one was pasted into a chat.
- About 3 GB of free storage.

## 1. Install Termux
Install **Termux** from **F-Droid** (f-droid.org), not the Play Store. The Play Store version is a different build
and these steps are written for the F-Droid one.

## 2. Run the setup
Open Termux and paste these two lines, one at a time:

```
curl -fsSLO https://raw.githubusercontent.com/haynesashton03-eng/never/ccr-5627dfb2-onjrf2/openclaw-server/android-1-termux.sh
bash android-1-termux.sh
```

- If it asks questions while updating, press Enter to accept the default.
- When it asks for your OpenRouter key and Telegram token, paste each one and press Enter. Nothing shows while you
  paste; that's normal.
- Expect 10–20 minutes in total.

## 3. Start the bot
```
bash ~/android-start.sh
```
Leave it running. You'll see log lines scroll past.

## 4. Pair your Telegram account (first time only)
1. Message your bot in Telegram. It replies with a pairing code.
2. In Termux, swipe in from the left edge, tap **New session**, and run (with your code):
   ```
   proot-distro login ubuntu -- openclaw pairing approve telegram YOURCODE
   ```
3. Message the bot again. It should answer.

## 5. Stop Android from shutting it down
- Pull down the notification shade, find the Termux notification, and check it says **wake lock held**.
- In Android Settings → Apps → Termux → Battery, choose **Unrestricted** (wording varies by phone brand).
- Don't swipe Termux away from the recent-apps screen.

## Optional: start automatically after a reboot
Install **Termux:Boot** from F-Droid, open it once, then in Termux run:
```
mkdir -p ~/.termux/boot && cp ~/android-start.sh ~/.termux/boot/
```

## If something goes wrong
| Problem | Try |
|---|---|
| Bot stopped answering | Open Termux. If the log has stopped, run `bash ~/android-start.sh` again. |
| "billing" or "rate limit" in the log | The free models' daily limit is used up. It resets the next day. |
| Check health | New session → `proot-distro login ubuntu -- openclaw doctor` |
| Telegram not connected | New session → `proot-distro login ubuntu -- openclaw channels status` |

## Good to know
- Only one device can run the bot at a time, so don't also start it in the cloud session.
- OpenClaw can run commands inside the phone's Ubuntu environment. Use a spare phone without personal accounts on it.
