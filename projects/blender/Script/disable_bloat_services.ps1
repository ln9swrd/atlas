# Windows Services and Widgets Disabling Script

# 1. User Registry (Current User - Taskbar Weather/Widgets Hide)
try {
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f | Out-Null
    reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "IsFeedsAvailable" /t REG_DWORD /d 0 /f | Out-Null
    Write-Host "HKCU Registry updated: Weather/News feed hidden on taskbar."
} catch {
    Write-Host "HKCU Registry update skipped: $_"
}

# 2. System Policy Registry (Require Admin Privilege)
try {
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f | Out-Null
    reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f | Out-Null
    Write-Host "HKLM Policy Registry updated successfully."
} catch {
    Write-Host "HKLM Policy update skipped (requires Admin execution)."
}

# 3. Disable Unnecessary Windows Services
$targetServices = @(
    "DiagTrack",
    "dmwappushservice",
    "MapsBroker",
    "RetailDemo",
    "XblAuthManager",
    "XblGameSave",
    "XboxGipSvc",
    "XboxNetApiSvc",
    "Fax",
    "RemoteRegistry",
    "wisvc"
)

foreach ($serviceName in $targetServices) {
    $svc = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "Processing Service: $serviceName"
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Service $serviceName stopped and disabled."
    }
}

# 4. Disable WpnUserService Notifications
$wpnServices = Get-Service | Where-Object { $_.Name -like "WpnUserService*" }
foreach ($wpnSvc in $wpnServices) {
    Stop-Service -Name $wpnSvc.Name -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($wpnSvc.Name)" -Name "Start" -Value 4 -ErrorAction SilentlyContinue
    Write-Host "WpnService disabled: $($wpnSvc.Name)"
}

Write-Host "All requested services and widgets have been disabled successfully."
