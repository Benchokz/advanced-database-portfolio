# Benchokz Bank Limited - Portfolio 5: stop ONLY the 3 replica-set servers (not your normal 27017 server)
Get-CimInstance Win32_Process |
  Where-Object { $_.Name -eq "mongod.exe" -and $_.CommandLine -like "*benchokzRS*" } |
  ForEach-Object { Write-Host "Stopping process $($_.ProcessId)"; Stop-Process -Id $_.ProcessId }
# Optional clean-up of the data folders:  Remove-Item -Recurse -Force "$env:USERPROFILE\benchokz-rs"
