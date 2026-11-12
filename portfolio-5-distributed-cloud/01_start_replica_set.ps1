# Benchokz Bank Limited - Portfolio 5: start a 3-node MongoDB replica set on this laptop
# Run in PowerShell:  powershell -ExecutionPolicy Bypass -File .\01_start_replica_set.ps1
# It starts 3 extra mongod servers on ports 27018, 27019, 27020. Your normal server on 27017 is NOT touched.

$mongod = (Get-Command mongod -ErrorAction SilentlyContinue).Source
if (-not $mongod) {
  $mongod = Get-ChildItem "C:\Program Files\MongoDB\Server\*\bin\mongod.exe" -ErrorAction SilentlyContinue |
            Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $mongod) { Write-Host "Could not find mongod.exe. Find it in C:\Program Files\MongoDB\Server\<version>\bin and set `$mongod by hand."; exit 1 }
Write-Host "Using: $mongod"

$root = Join-Path $env:USERPROFILE "benchokz-rs"
$ports = 27018, 27019, 27020
$i = 1
foreach ($p in $ports) {
  $dir = Join-Path $root "node$i"
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $log = Join-Path $dir "mongod.log"
  Start-Process -FilePath $mongod -WindowStyle Minimized -ArgumentList @(
    "--replSet", "benchokzRS", "--port", "$p", "--bind_ip", "localhost",
    "--dbpath", "`"$dir`"", "--logpath", "`"$log`""
  )
  Write-Host "Started node$i on port $p"
  $i++
}
Write-Host "Done. Next: connect Compass to mongodb://localhost:27018/?directConnection=true and run 02_init_replica_set.js"
