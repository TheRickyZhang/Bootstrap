Write-Host "Running PowerShell configuration..."
& .\powershell.ps1
Start-Sleep -Seconds 5

Write-Host "Running Git configuration..."
& .\git.ps1
Start-Sleep -Seconds 5

Write-Host "Improving Windows... (await 25s)"
& .\improveWindows.ps1
Start-Sleep -Seconds 25

Read-Host "Press Enter to exit..."
