# Agentarium releases

Builds of [Agentarium](https://agentarium.adammorgan.ca), a pixel-art office where every
Claude Code session is a character at a desk. Each release has the desktop app for Linux
(`.deb`, `.rpm`, AppImage); macOS and Windows are to come. The app updates itself from here.

## Install

- Linux: `curl -fsSL https://agentarium.adammorgan.ca/install.sh | sh`

You need [Claude Code](https://claude.com/claude-code). On first run Agentarium asks before
adding its hooks to `~/.claude/settings.json`, and its tray menu's Disconnect from Claude
Code takes them out again.

## Credits

DOOM in the office runs on Chocolate Doom, as built for the web by Cloudflare's
[doom-wasm](https://github.com/cloudflare/doom-wasm), under the GNU GPL v2: its licence
ships with the app (`resources/web/doom/COPYING.md`), and its source is at that link.
No WAD ships with Agentarium.

This repo holds no source: its Build workflow builds each release from Agentarium's own
repo, at the tag that repo sends.
