==============================================================================
DRIFTEROS - QUICK START
==============================================================================

Thank you for choosing DrifterOS, the AI operating system you own. It runs
entirely on your own computer: a desktop with built-in apps and AI agents,
and no cloud service behind it. Your files, accounts and keys stay on your
machine.

Downloads for every platform:  __RELEASES_URL__
Website and documentation:     https://drifteros.laxtic.com
Support:                       info@laxtic.com

This is the short version. Once DrifterOS is running, the Docs app inside it
has the full guide.


------------------------------------------------------------------------------
WHICH FILE DO I NEED?
------------------------------------------------------------------------------

  macOS, Apple silicon (M1 and later)   DrifterOS-<version>-mac-arm64.dmg
  macOS, Intel                          DrifterOS-<version>-mac-x64.dmg
  Windows 10 or 11, 64-bit              DrifterOS-<version>-win-x64.exe
  Linux x64                             drifteros-<version>-linux-x64
                                        (and, optionally, the desktop app:
                                        DrifterOS-<version>-linux-x86_64.AppImage,
                                        -amd64.deb or -x86_64.rpm)

Not sure which Mac you have? Apple menu > About This Mac. "Chip: Apple M..."
means Apple silicon; "Processor: Intel" means Intel.

On macOS and Windows the app carries the operating system inside it: one
download, nothing else to install. On Linux the operating system is one file
of its own (it also runs on servers without a screen), and the desktop app is
an optional extra.


------------------------------------------------------------------------------
MACOS
------------------------------------------------------------------------------

  1. Open the .dmg file and drag DrifterOS into your Applications folder.
  2. Open DrifterOS from Applications.

  The first time, macOS may refuse to open it with a message such as
  "Apple could not verify DrifterOS is free of malware" (or "DrifterOS
  cannot be opened because the developer cannot be verified"). This is
  macOS asking you to confirm an app from the internet that is not
  notarised by Apple. To allow it, once:

     a. Click Done (or Cancel) on that message.
     b. Open System Settings > Privacy & Security.
     c. Scroll down to Security. Next to the line about DrifterOS, click
        Open Anyway, then confirm with your password or Touch ID.
     d. Open DrifterOS again and click Open.

  If you prefer the Terminal, this does the same:
        xattr -dr com.apple.quarantine /Applications/DrifterOS.app

  DrifterOS then starts its operating system in the background and shows
  the desktop when it is ready. The first start can take up to a minute.

  Quitting DrifterOS (DrifterOS menu > Quit, or Cmd+Q) stops the operating
  system it started. Your data stays in the .drifter folder in your home
  folder, and everything is there again the next time you open the app.


------------------------------------------------------------------------------
WINDOWS
------------------------------------------------------------------------------

  1. Run DrifterOS-<version>-win-x64.exe.

  Windows may show "Windows protected your PC" (Microsoft Defender
  SmartScreen), because the installer is new to SmartScreen. Click
  More info, then Run anyway. This is a reputation check, not a virus
  warning.

  2. Follow the installer. Choose "Only for me" to install without
     administrator rights. It creates Start menu and desktop shortcuts and
     adds the `drifter` command to your Path.
  3. Open DrifterOS from the Start menu or the desktop shortcut.

  DrifterOS starts its operating system in the background and shows the
  desktop when it is ready (up to a minute the first time). Closing the
  app stops the operating system it started. Your data stays in the
  .drifter folder in your user folder (%USERPROFILE%\.drifter).

  To uninstall: Settings > Apps > Installed apps > DrifterOS > Uninstall.
  Your data folder is kept; delete it yourself if you want it gone.


------------------------------------------------------------------------------
LINUX
------------------------------------------------------------------------------

  The operating system (x64, glibc 2.28 or newer):

        chmod +x drifteros-<version>-linux-x64
        ./drifteros-<version>-linux-x64

  It prints the address of the desktop, http://127.0.0.1:3692 by default.
  Open it in any browser on that machine (or start it with --open). It runs
  until you press Ctrl+C in that terminal. Keep the setup/ folder from the
  Linux folder beside the executable.

  The desktop app (optional; start the operating system first):

    AppImage   chmod +x DrifterOS-<version>-linux-x86_64.AppImage, then run
               it. It needs FUSE 2 (sudo apt install libfuse2, or
               libfuse2t64 on Ubuntu 24.04); without it, add
               --appimage-extract-and-run.
    .deb       sudo apt install ./DrifterOS-<version>-linux-amd64.deb
    .rpm       sudo dnf install ./DrifterOS-<version>-linux-x86_64.rpm

  The app finds the running operating system by itself and leaves it
  running when you quit the app. The full Linux guide (servers, ports, the
  drifter command) is Linux/README.md, beside the executable.


------------------------------------------------------------------------------
FIRST START: THE SETUP WIZARD AND YOUR LICENCE
------------------------------------------------------------------------------

The first time the desktop appears, a short wizard sets up this machine:

  - your name and the owner account for this computer,
  - a passcode (it unlocks the screen and confirms system changes),
  - two-factor authentication (optional),
  - your recovery codes: save them somewhere safe,
  - your LICENCE KEY. It looks like LX-XXXXX-XXXXX-XXXXX-XXXXX and was
    emailed to you after you bought DrifterOS. Paste it and click Activate.
    Activating needs an internet connection.
  - a look, and an AI provider (both optional; change them later in
    Settings).

DrifterOS checks the licence every few hours while it runs and keeps
working through short outages. Buy or renew at
https://drifteros.laxtic.com/pricing/


------------------------------------------------------------------------------
OPTIONAL EXTRAS
------------------------------------------------------------------------------

DrifterOS needs nothing else to run. A few features use programs your
computer installs and keeps up to date itself:

  - a Chromium-family browser (Chrome, Brave, Edge or Chromium) for the
    Browser app, web search and computer use,
  - git and Node.js for code, MCP servers and the software agents build,
  - if you want them: Ollama (local AI models), Python, a container engine,
    and the Google Cloud and AWS command lines.

Every download includes a setup script that checks for them and offers to
install the missing ones with your own package manager (Homebrew, winget,
apt, dnf, pacman or zypper), asking before each one:

  macOS    Right-click DrifterOS in Applications > Show Package Contents,
           then double-click Contents/Resources/setup/setup.command
  Windows  Double-click setup.cmd in
           %LOCALAPPDATA%\Programs\DrifterOS\resources\setup
  Linux    ./setup/setup.sh   (beside the executable)
  Anywhere drifter setup      (drifter doctor --deps only checks)

Add --check (-Check on Windows) to report without installing anything.


------------------------------------------------------------------------------
CHECK YOUR DOWNLOAD (OPTIONAL)
------------------------------------------------------------------------------

Each folder (macOS, Windows, Linux) has a SHA256SUMS.txt listing every file
in it, under the same names the downloads have. In the folder you downloaded
to:

  macOS     shasum -a 256 -c SHA256SUMS.txt
  Linux     sha256sum -c SHA256SUMS.txt
  Windows   Get-FileHash .\DrifterOS-<version>-win-x64.exe   (PowerShell;
            compare with the line in SHA256SUMS.txt)

Every file you downloaded should say OK.


------------------------------------------------------------------------------
PRIVACY
------------------------------------------------------------------------------

DrifterOS runs on your computer and listens on 127.0.0.1 only unless you
deliberately serve it to your network. The only thing it sends to us is the
licence check: your key, a random ID for this machine, the machine's name,
the platform and the DrifterOS version. Nothing about your files, apps or
usage.


------------------------------------------------------------------------------
HELP
------------------------------------------------------------------------------

  Documentation   the Docs app inside DrifterOS, and
                  https://drifteros.laxtic.com/docs/
  Support         info@laxtic.com
  Terms           https://drifteros.laxtic.com/terms/

DrifterOS is published by Laxtic Software Services.
