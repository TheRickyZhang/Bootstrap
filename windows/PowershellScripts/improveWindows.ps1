<#
.SYNOPSIS
  Apply robust computer-literate Windows tweaks plus extras.
.DESCRIPTION
  Must be run as Administrator. Exits if not elevated.
#>

function Ensure-RegistryKey {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

function Set-RegistryProperty {
    param(
        [string]$Path,
        [string]$Name,
        [string]$PropertyType,
        [object]$Value
    )
    Ensure-RegistryKey $Path
    New-ItemProperty -Path $Path -Name $Name -PropertyType $PropertyType -Value $Value -Force | Out-Null
    Write-Host "Set $Name in $Path to $Value"
}

# 0) Elevation check
if (-not (
    [Security.Principal.WindowsPrincipal]::new(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
)) {
    Write-Error "Administrator rights required. Rerun as Admin."
    exit 1
}
Write-Host "Step 0: Elevation check passed."

# 1) Auto-start Chrome at login
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (Test-Path $chrome) {
    Set-RegistryProperty `
        -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
        -Name "Chrome" `
        -PropertyType "String" `
        -Value "`"$chrome`""
    Write-Host "Step 1: Chrome auto-start configured."
} else {
    Write-Host "Step 1: Chrome not found, skipping."
}

# 2) Skip
Write-Host "Step 2: skipped."

# 3) Turn off Bing/web in Start Search
$searchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
foreach ($name in "BingSearchEnabled","AllowSearchToUseWeb","CortanaConsent") {
    Set-RegistryProperty -Path $searchKey -Name $name -PropertyType "DWord" -Value 0
}
Write-Host "Step 3: Disabled web integration in Start Search."

# 4-8) Explorer "Advanced" tweaks
$advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$advProps = @{
    ShowSearch = 1
    ConfirmFileDelete = 0
    WarnOnExtensionChange = 0
    HideFileExt = 0
    EnableBalloonTips = 0
}
foreach ($k in $advProps.Keys) {
    Set-RegistryProperty -Path $advKey -Name $k -PropertyType "DWord" -Value $advProps[$k]
}
Write-Host "Step 4-8: Explorer advanced tweaks applied."

# 9) Disable Start-menu app suggestions
$contentKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
foreach ($name in "SystemPaneSuggestionsEnabled","SubscribedContent-338388Enabled") {
    Set-RegistryProperty -Path $contentKey -Name $name -PropertyType "DWord" -Value 0
}
Write-Host "Step 9: Start-menu suggestions disabled."

# 10) Disable Telemetry & related services
$dataKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
Set-RegistryProperty -Path $dataKey -Name "AllowTelemetry" -PropertyType "DWord" -Value 0
foreach ($svc in "DiagTrack","dmwappushsvc") {
    if (Get-Service $svc -ErrorAction SilentlyContinue) {
        Stop-Service $svc -Force
        Set-Service $svc -StartupType Disabled
        Write-Host "Stopped and disabled service $svc"
    } else {
        Write-Host "Service $svc not found"
    }
}
Write-Host "Step 10: Telemetry services handled."

# 11) Prevent Windows Update auto-restart
$wuKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
Set-RegistryProperty -Path $wuKey -Name "NoAutoRebootWithLoggedOnUsers" -PropertyType "DWord" -Value 1
Write-Host "Step 11: Windows Update auto-restart prevented."

# 12) Disable Microsoft Store auto-updates
$storeKey = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
Set-RegistryProperty -Path $storeKey -Name "AutoDownload" -PropertyType "DWord" -Value 2
Write-Host "Step 12: Microsoft Store auto-updates disabled."

# 13) Remove specific bloatware packages
$bloatList = @(
    "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga",
    "king.com.CandyCrushFriends",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.SkypeApp",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxSpeechToTextOverlay"
)
foreach ($f in $bloatList) {
    $userPkg = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFamilyName -like "$f*" }
    if ($userPkg) {
        $userPkg | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Host "Uninstalled per-user $f"
    }
    $provPkg = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "$f*" }
    if ($provPkg) {
        $provPkg | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Host "Uninstalled provisioned $f"
    }
}
Write-Host "Step 13: Bloatware removal complete."

# 15) Disable Lock-Screen Spotlight & ads
$cloudKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Set-RegistryProperty -Path $cloudKey -Name "DisableWindowsSpotlight" -PropertyType "DWord" -Value 1
Set-RegistryProperty -Path $cloudKey -Name "DisableConsumerFeatures" -PropertyType "DWord" -Value 1
Write-Host "Step 15: Spotlight and ads disabled."

# 16) Prevent UWP apps from running in background
$appPrivKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"
Set-RegistryProperty -Path $appPrivKey -Name "LetAppsRunInBackground" -PropertyType "DWord" -Value 2
Write-Host "Step 16: Blocked UWP apps from background."


# 18) Restart Explorer
Stop-Process -Name explorer -Force
Start-Process explorer.exe
Write-Host "Step 18: Explorer restarted."

Write-Host "All tweaks applied - script complete."
