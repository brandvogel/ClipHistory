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

## Build

Run the below commands in the repo to build the app.
```cd ClipHistory
chmod +x build.sh
./build.sh
open ClipHistory.app```
