$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$pythonPath = Join-Path $root '.venv/Scripts/python.exe'
Get-Command $pythonPath -ErrorAction Stop | Out-Null
& $pythonPath -m uvicorn app.presentation.server:app --host 127.0.0.1 --port 8000 --workers 1
exit $LASTEXITCODE
