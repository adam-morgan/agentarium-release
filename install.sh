#!/bin/sh
# Installs codeArIum:  curl -fsSL https://codearium.dev/install.sh | sh
# It updates itself from then on. Nothing here touches ~/.claude: the app asks
# before connecting to Claude Code.
set -eu

SITE=https://codearium.dev
RELEASES=https://github.com/adam-morgan/agentarium-release/releases/latest/download

say() { printf '%s\n' "$*"; }
fail() {
  printf 'codearium: %s\n' "$*" >&2
  exit 1
}

command -v curl >/dev/null || fail "curl is needed to install codeArIum"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fetch() {
  say "Downloading $1"
  curl -fL --progress-bar -o "$tmp/$1" "$RELEASES/$1" || fail "couldn't download $RELEASES/$1"
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# TODO(move-over): each platform removes Agentarium's install, from before the rename (added 2026-10-07).

# A package manager installs what Electron needs and keeps Chromium's sandbox
# working; anything else gets the AppImage, which needs neither.
linux() {
  [ "$(uname -m)" = x86_64 ] || fail "only x86_64 Linux is built for now"

  if command -v apt-get >/dev/null; then
    fetch codeArIum-linux-amd64.deb
    as_root apt-get install -y "$tmp/codeArIum-linux-amd64.deb"
    ! dpkg -s agentarium >/dev/null 2>&1 || as_root apt-get remove -y agentarium
  elif command -v dnf >/dev/null; then
    fetch codeArIum-linux-x86_64.rpm
    as_root dnf install -y "$tmp/codeArIum-linux-x86_64.rpm"
    ! rpm -q Agentarium >/dev/null 2>&1 || as_root dnf remove -y Agentarium
  else
    appimage
  fi
}

appimage() {
  bin="$HOME/.local/bin"
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons"

  fetch codeArIum-linux-x86_64.AppImage
  mkdir -p "$bin" "$apps" "$icons"
  mv "$tmp/codeArIum-linux-x86_64.AppImage" "$bin/codeArIum.AppImage"
  chmod +x "$bin/codeArIum.AppImage"
  curl -fsSL -o "$icons/codearium.png" "$SITE/icon.png" || true
  cat >"$apps/codearium.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=codeArIum
Comment=Bring your AI coding environment to life
Exec=$bin/codeArIum.AppImage
Icon=$icons/codearium.png
Categories=Development;
StartupWMClass=codeArIum
DESKTOP
  rm -f "$bin/Agentarium.AppImage" "$apps/agentarium.desktop" "$icons/agentarium.png"
}

# curl leaves no quarantine mark, so macOS opens the unsigned app without
# sending you to System Settings.
mac() {
  fetch codeArIum-mac-universal.zip

  dest=/Applications
  [ -w "$dest" ] || dest="$HOME/Applications"
  mkdir -p "$dest"
  rm -rf "$dest/codeArIum.app" "$dest/Agentarium.app"
  ditto -x -k "$tmp/codeArIum-mac-universal.zip" "$dest"
  open "$dest/codeArIum.app"
}

case "$(uname -s)" in
  Linux) linux ;;
  Darwin) mac ;;
  *) fail "on Windows, run this in PowerShell: irm $SITE/install.ps1 | iex" ;;
esac

say "codeArIum is installed. Open it from your applications."

command -v claude >/dev/null ||
  say "Claude Code isn't on your PATH yet; codeArIum needs it: https://claude.com/claude-code"
