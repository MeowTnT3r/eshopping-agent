$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location (Join-Path $root 'frontend')
Get-Command node.exe -ErrorAction Stop | Out-Null
& node.exe 'node_modules/vite/bin/vite.js' --host 127.0.0.1 --port 5173 --strictPort
exit $LASTEXITCODE
