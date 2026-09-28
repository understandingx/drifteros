# DrifterOS

**The AI operating system you own.**

DrifterOS is a complete operating environment that runs on your own computer: a windowed
desktop with built-in apps, AI agents that can use the whole system with your approval, a
permission system that every app and agent goes through, installable packages, and an MCP
server for your own AI tools. There is no cloud service behind it. Your files, your
accounts and your keys stay on your machine.

[**Download the latest release**](https://github.com/understandingx/drifteros/releases/downloads-20260928-205848) &nbsp;·&nbsp; [Website](https://drifteros.laxtic.com) &nbsp;·&nbsp; [Quick start](README.txt) &nbsp;·&nbsp; [Support](mailto:info@laxtic.com)

---

## Download

Everything is on the [**releases page**](https://github.com/understandingx/drifteros/releases/downloads-20260928-205848). Pick the file for your computer:

| System | Download | What it is |
|---|---|---|
| **macOS**, Apple silicon (M1 and later) | `DrifterOS-<version>-mac-arm64.dmg` | The DrifterOS app, with the operating system inside it |
| **macOS**, Intel | `DrifterOS-<version>-mac-x64.dmg` | The same, for Intel Macs |
| **Windows** 10 and 11, 64-bit | `DrifterOS-<version>-win-x64.exe` | The installer: the app, with the operating system inside it |
| **Linux** x64 | `drifteros-<version>-linux-x64` | The operating system: one file, the web desktop built in |
| | `DrifterOS-<version>-linux-x86_64.AppImage`, `-amd64.deb` or `-x86_64.rpm` | The desktop app (optional) |

**macOS and Windows: one download.** The app carries the operating system. Opening the
app starts it; quitting the app stops it. Nothing else to install.

**Linux: the operating system, and optionally the app.** The executable runs the whole
system and serves the desktop to any browser on the machine, so a server without a screen
needs nothing else. The desktop app, if you want it, finds the running system by itself.
Keep the `setup/` folder from [`Linux/`](Linux) beside the executable, and see
[`Linux/README.md`](Linux/README.md) for the full guide.

Not sure which Mac you have? Apple menu > **About This Mac**: "Chip: Apple M..." is Apple
silicon, "Processor: Intel" is Intel.

## Getting started

1. **Install and open DrifterOS.** macOS: open the `.dmg` and drag DrifterOS to
   Applications. Windows: run the installer. Linux: `chmod +x` the executable and run it,
   then open the address it prints. The first time, your system asks you to confirm an app
   from the internet: [README.txt](README.txt) shows exactly what to click.
2. **Set it up.** A short wizard creates the owner account for this machine, a passcode
   and your recovery codes, then asks for your **licence key** (`LX-XXXXX-XXXXX-XXXXX-XXXXX`,
   emailed after you buy; activating needs an internet connection).
3. **Connect an AI provider** (optional) and start using the apps.

Some features use programs your computer installs and keeps up to date itself: a
Chromium-family browser (Chrome, Brave, Edge or Chromium) for the Browser app and computer
use, and git and Node.js for code and developer tools. Every download carries a setup script
that checks for them and offers to install the missing ones; `drifter setup` runs it.

## System requirements

- **macOS** 11 Big Sur or later, Apple silicon or Intel.
- **Windows** 10 or 11, 64-bit (Windows on ARM runs the x64 app under emulation).
- **Linux** x64 (or arm64) with glibc 2.28 or newer: Ubuntu 20.04, Debian 10, Fedora 29,
  RHEL 8 and later.
- An internet connection to activate the licence and for its periodic check.

## Verify your download

Each system's folder in this repository ([`macOS`](macOS), [`Windows`](Windows),
[`Linux`](Linux)) has a `SHA256SUMS.txt` listing every file in it. Downloaded files keep
their names, so in the folder you downloaded to:

```
shasum -a 256 -c SHA256SUMS.txt      # macOS
sha256sum -c SHA256SUMS.txt          # Linux
```

On Windows, in PowerShell: `Get-FileHash .\DrifterOS-<version>-win-x64.exe` and compare it
with the line in `Windows/SHA256SUMS.txt`. Lines for files you did not download report as
missing; every file you have should say `OK`.

---

## Privacy

DrifterOS runs on your computer and listens on `127.0.0.1` only, unless you deliberately
serve it to your network. There is no account with us and no usage tracking. The only
connection it makes to us is the licence check, which sends your licence key, a random ID
for this machine, the machine's name, the platform and the DrifterOS version; nothing about
your files, apps or usage.

## Licence

DrifterOS is commercial software. The [terms of service](https://drifteros.laxtic.com/terms/)
are the licence agreement; the `LICENSE` file beside the Linux executable says the same.
Plans and prices: [drifteros.laxtic.com](https://drifteros.laxtic.com/pricing/).

## Support

**info@laxtic.com** &nbsp;·&nbsp; [drifteros.laxtic.com](https://drifteros.laxtic.com)

DrifterOS is published by Laxtic Software Services.
