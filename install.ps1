# Installs codeArIum:  irm https://codearium.dev/install.ps1 | iex
# A per-user install, so no admin prompt; it updates itself from then on.
# Nothing here touches Claude Code's settings: the app asks before connecting.
& {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'

  $url = 'https://github.com/adam-morgan/agentarium-release/releases/latest/download/codeArIum-Setup.exe'
  $setup = Join-Path $env:TEMP 'codeArIum-Setup.exe'

  Write-Host 'Downloading codeArIum...'
  Invoke-WebRequest -Uri $url -OutFile $setup -UseBasicParsing

  # Downloaded here rather than in a browser, it carries no mark of the web,
  # so SmartScreen doesn't stop the unsigned installer.
  Start-Process -FilePath $setup -ArgumentList '/S' -Wait
  Remove-Item $setup

  Write-Host 'codeArIum is installed. Open it from the Start menu.'

  if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Claude Code isn't on your PATH yet; codeArIum needs it: https://claude.com/claude-code"
  }
}
