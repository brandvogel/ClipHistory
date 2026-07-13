# ClipHistory

A lightweight macOS menu bar app that remembers your recent clipboard entries so you can paste something you copied a few items ago. macOS only keeps the *most recent* clipboard item natively — ClipHistory quietly records the last 15 text copies and lets you put any of them back with a click.

## Features

- Lives in the menu bar — no Dock icon, no window clutter (runs as a menu bar "accessory").
- Records the **last 15** unique text copies, most recent first, with automatic de-duplication.
- Click any entry (or press **⌘1–⌘9**) to copy it back to the clipboard.
- **Open History as Text… (⌘O)** — dumps all entries into a clean, numbered `.txt` file and opens it, so you can read long or multi-line copies in full.
- **Clear History** and **Quit (⌘Q)**.
- History persists across restarts in `~/.clip_history.json`.
- Pure AppKit, zero third-party dependencies.

## Requirements

- macOS 13.0 (Ventura) or later.
- Apple's Swift toolchain — the Command Line Tools are enough:
  ```bash
  xcode-select --install
  ```
  (Full Xcode is **not** required.)

## Build

```bash
cd ClipHistory
chmod +x build.sh
./build.sh
open ClipHistory.app
```

`build.sh` compiles the sources with `swiftc`, assembles a `.app` bundle, and applies an ad-hoc code signature so it runs locally.

On first launch, if Gatekeeper blocks the unsigned app: right-click `ClipHistory.app` → **Open**, or go to **System Settings → Privacy & Security → Open Anyway**.

The app has no Dock icon or window by design — look for the clipboard icon in your **menu bar** (top-right). If your menu bar is crowded, ⌘-drag icons to reveal it.

## Run at login

**System Settings → General → Login Items → +**, then add `ClipHistory.app`.

## How it works

macOS has no clipboard-change notification, so ClipHistory polls `NSPasteboard`'s cheap `changeCount` twice a second. When it changes, the new text is prepended to the history (deduped, capped at 15) and saved to `~/.clip_history.json`.

## Privacy & security

- Everything stays **local**. Nothing is sent anywhere.
- History is stored **unencrypted** in `~/.clip_history.json`. Anything you copy — including passwords or tokens — can land there. Use **Clear History** after copying secrets, and be aware of this if you sync your home folder.
- Text only; images and files are ignored.

## Acknowledgements

The initial implementation of this project was developed with the assistance of Claude, an AI assistant by Anthropic (Anthropic, 2026). All code was reviewed and tested by the author before release.

## References

Anthropic. (2026). *Claude* (Opus 4.6) [Large language model]. https://www.anthropic.com
