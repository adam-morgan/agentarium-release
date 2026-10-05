#!/bin/sh
# Installs Agentarium:  curl -fsSL https://agentarium.adammorgan.ca/install.sh | sh
# It updates itself from then on. Nothing here touches ~/.claude: the app asks
# before connecting to Claude Code.
set -eu

SITE=https://agentarium.adammorgan.ca
RELEASES=https://github.com/adam-morgan/agentarium-release/releases/latest/download

say() { printf '%s\n' "$*"; }
fail() {
  printf 'agentarium: %s\n' "$*" >&2
  exit 1
}

command -v curl >/dev/null || fail "curl is needed to install Agentarium"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fetch() {
  say "Downloading $1"
  curl -fL --progress-bar -o "$tmp/$1" "$RELEASES/$1" || fail "couldn't download $RELEASES/$1"
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then "$@"; else sudo "$@"; fi
}

# A package manager installs what Electron needs and keeps Chromium's sandbox
# working; anything else gets the AppImage, which needs neither.
linux() {
  [ "$(uname -m)" = x86_64 ] || fail "only x86_64 Linux is built for now"

  if command -v apt-get >/dev/null; then
    fetch Agentarium-linux-amd64.deb
    as_root apt-get install -y "$tmp/Agentarium-linux-amd64.deb"
  elif command -v dnf >/dev/null; then
    fetch Agentarium-linux-x86_64.rpm
    as_root dnf install -y "$tmp/Agentarium-linux-x86_64.rpm"
  else
    appimage
  fi
}

appimage() {
  bin="$HOME/.local/bin"
  apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  icons="${XDG_DATA_HOME:-$HOME/.local/share}/icons"

  fetch Agentarium-linux-x86_64.AppImage
  mkdir -p "$bin" "$apps" "$icons"
  mv "$tmp/Agentarium-linux-x86_64.AppImage" "$bin/Agentarium.AppImage"
  chmod +x "$bin/Agentarium.AppImage"
  curl -fsSL -o "$icons/agentarium.png" "$SITE/icon.png" || true
  cat >"$apps/agentarium.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Agentarium
Comment=A pixel-art office for your Claude Code sessions
Exec=$bin/Agentarium.AppImage
Icon=$icons/agentarium.png
Categories=Development;
StartupWMClass=Agentarium
DESKTOP
}

# curl leaves no quarantine mark, so macOS opens the unsigned app without
# sending you to System Settings.
mac() {
  fetch Agentarium-mac-universal.zip

  dest=/Applications
  [ -w "$dest" ] || dest="$HOME/Applications"
  mkdir -p "$dest"
  rm -rf "$dest/Agentarium.app"
  ditto -x -k "$tmp/Agentarium-mac-universal.zip" "$dest"
  open "$dest/Agentarium.app"
}

case "$(uname -s)" in
  Linux) linux ;;
  Darwin) mac ;;
  *) fail "on Windows, run this in PowerShell: irm $SITE/install.ps1 | iex" ;;
esac

say "Agentarium is installed. Open it from your applications."

command -v claude >/dev/null ||
  say "Claude Code isn't on your PATH yet; Agentarium needs it: https://claude.com/claude-code"
