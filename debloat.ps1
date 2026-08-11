$appsToRemove = @(
    "Microsoft.BingWeather",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.3DBuilder",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.Print3D",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingFinance",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone"
)

Write-Host "Uninstalling bloatware apps..."
foreach ($app in $appsToRemove) {
    Write-Host "Attempting to remove $app..."
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $app } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

$servicesToDisable = @(
    "DiagTrack",
    "dmwappushservice",
    "MapsBroker",
    "XboxNetApiSvc",
    "XblAuthManager",
    "XblGameSave"
)

Write-Host "`nDisabling unnecessary services..."
foreach ($service in $servicesToDisable) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Write-Host "Stopping and disabling $service..."
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    } else {
        Write-Host "Service $service not found."
    }
}

Write-Host "`nCleanup complete! Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
