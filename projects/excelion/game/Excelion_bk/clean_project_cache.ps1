$ErrorActionPreference = "Stop"

$projectRoot = $PSScriptRoot

$targets = @(
    "Binaries",
    "Intermediate",
    ".vs",
    "Saved\Logs",
    "DerivedDataCache"
)

foreach ($target in $targets) {
    $path = Join-Path $projectRoot $target

    if (-not (Test-Path $path)) {
        Write-Host "Skipped (not found): $path"
        continue
    }

    Write-Host "Removing: $path"

    try {
        Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
    }
    catch {
        Write-Warning "Could not remove $path : $($_.Exception.Message)"
        Write-Host "This usually means an editor/IDE process is still holding the folder open."
        Write-Host "Close Unreal Editor and Visual Studio, then run this script again."
    }
}

Write-Host ""
Write-Host "Project cache cleanup finished."
Write-Host "If any path failed, close IDEs and rerun the script."
