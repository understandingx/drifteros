# DrifterOS 1.0.10 for Linux

DrifterOS is the AI operating system you own: a windowed desktop with built-in
apps and AI agents, running on your own machine. On Linux it comes as two
downloads, because it often runs on a server with no screen:

| file | what it is |
|---|---|
| `drifteros-1.0.10-linux-x64` | **The operating system.** One file with everything inside it, the web desktop included. Nothing else to install, not even Node.js. x64, glibc 2.28 or newer. |
| `drifteros-1.0.10-linux-arm64` | The same for 64-bit ARM (ARM servers, Raspberry Pi 4/5 with a 64-bit OS), when this folder carries it. |
| `setup/setup.sh` | Checks the programs some features use (a browser, git, Node.js...) and offers to install the missing ones. |
| `DrifterOS-1.0.10-linux-x86_64.AppImage` | **The desktop app** (optional), runs without installing. |
| `DrifterOS-1.0.10-linux-amd64.deb` | The desktop app for Debian and Ubuntu. |
| `DrifterOS-1.0.10-linux-x86_64.rpm` | The desktop app for Fedora, RHEL and openSUSE. |
| `SHA256SUMS.txt` | Checksums of every file here. |
| `LICENSE` | The licence agreement. |

The desktop app is a window onto the operating system: it finds the one running
on this machine by itself. The operating system does not need the app: any
browser shows the same desktop.

## Start the operating system

Keep the executable and `setup/` together in a folder you like, then:

```bash
chmod +x drifteros-1.0.10-linux-x64
./drifteros-1.0.10-linux-x64
```

It prints the address of the desktop when it is ready, `http://127.0.0.1:3692`
by default, and where its logs are (`~/.drifter/logs`).

Open that address in a browser on this machine (or add `--open` to have it
opened for you). The first time, DrifterOS walks you through a short setup: the
owner account for this machine, a passcode, optional two-factor authentication,
your recovery codes, and your **licence key** (it looks like
`LX-XXXXX-XXXXX-XXXXX-XXXXX` and arrives by email after you buy; activating needs
an internet connection). The first start can take up to a minute.

DrifterOS runs until you press **Ctrl+C** in that terminal (or send it SIGTERM),
then shuts down cleanly and saves everything. Your data lives in
`~/.drifter` (set `DRIFTER_HOME` to move it); nothing is ever written beside the
executable.

```
./drifteros-1.0.10-linux-x64 --help        every option
./drifteros-1.0.10-linux-x64 --ports       the ports and data folder it would use (starts nothing)
./drifteros-1.0.10-linux-x64 --version
./drifteros-1.0.10-linux-x64 --open        open the desktop in the browser once ready
./drifteros-1.0.10-linux-x64 --verbose     the full log in the terminal too
```

A port that is already taken moves to the next free one by itself; the address
it prints is always the right one. `--shell-port` (or `DRIFTER_SHELL_PORT`) pins
the desktop's port; `--help` lists the options that pin the others.

Exit codes: `0` stopped normally; `1` DrifterOS failed to start (its last log lines
are printed); `2` bad arguments; `3` DrifterOS is already running (the copy you
started left the running one alone); `4` a port is held by another program;
`5` the file was modified or damaged (download it again); `78` it stopped for
licensing (the message says why).

## The `drifter` command

The executable is also the command line. Put it on your PATH once:

```bash
./drifteros-1.0.10-linux-x64 cli install --user --update-profile   # ~/.local/bin, added to your PATH
./drifteros-1.0.10-linux-x64 cli install --system                  # /usr/local/bin, with sudo
```

Then, in a new terminal: `drifter status`, `drifter doctor`, `drifter help`.

## Extras: `setup/setup.sh`

DrifterOS needs nothing else to run. A few features use programs your system
installs and keeps up to date itself: a Chromium-family browser (Chrome, Brave,
Edge or Chromium) for the Browser app, web search and computer use; git and
Node.js for code, MCP servers and the software agents build; and, if you want
them, Ollama, Python, a container engine and the cloud command lines. The
script checks for each and offers to install what is missing with apt, dnf,
pacman or zypper, asking first:

```bash
./setup/setup.sh            # check, then offer each missing item
./setup/setup.sh --check    # report only, install nothing
./setup/setup.sh --yes      # install every missing recommended item without asking
```

Running it again changes nothing that is already there. `drifter doctor --deps`
runs the same check.

## The desktop app

Start the operating system first (above); the app connects to it by itself, and
leaves it running when you quit the app.

- **AppImage**: `chmod +x DrifterOS-1.0.10-linux-x86_64.AppImage` and run it.
  It needs FUSE 2 (`sudo apt install libfuse2`, or `libfuse2t64` on Ubuntu
  24.04); without it, run it with `--appimage-extract-and-run`.
- **.deb**: `sudo apt install ./DrifterOS-1.0.10-linux-amd64.deb`, then
  DrifterOS is in your applications menu.
- **.rpm**: `sudo dnf install ./DrifterOS-1.0.10-linux-x86_64.rpm`.

On Ubuntu 23.10 and newer, the AppImage may refuse to start because of the
system's restriction on unprivileged user namespaces; the `.deb` sets up the
sandbox helper it needs, so prefer it there.

## On a server

By default DrifterOS listens on `127.0.0.1` only, which nobody else can reach.
To serve the desktop to other computers, turn on authentication and bind the
network interface deliberately:

```bash
export DRIFTER_REQUIRE_AUTH=1
export DRIFTER_GATEWAY_TOKEN="$(openssl rand -base64 32)"   # keep it secret
export DRIFTER_SHELL_ALLOWED_HOSTS=os.example.com           # the name people will type
./drifteros-1.0.10-linux-x64 --host 0.0.0.0
```

Never expose DrifterOS without `DRIFTER_REQUIRE_AUTH=1`. Put a TLS reverse proxy
in front of it for anything beyond a private network. The full guide is in the
Docs app inside DrifterOS ("Getting started", "On a server").

## Check your download

In this folder:

```bash
sha256sum -c SHA256SUMS.txt
```

Every line should say `OK`. (A file downloaded from the releases page carries
the same name as in the list.)

## Privacy

DrifterOS runs on your machine. The only thing it sends to us is the licence
check: your key, a random ID for this machine, the machine's name, the platform
and the DrifterOS version. Nothing about your files, apps or usage.

## Support

https://drifteros.laxtic.com  ·  info@laxtic.com

DrifterOS is published by Laxtic Software Services.
