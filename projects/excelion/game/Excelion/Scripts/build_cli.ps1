# Excelion UE 5.4 CLI Build Script
param (
    [string]$UEPath = "C:\Program Files\Epic Games\UE_5.4",
    [string]$Configuration = "Development"
)

$ErrorActionPreference = "Stop"

$ProjectDir = Resolve-Path "$PSScriptRoot\.."
$UProjectFile = Join-Path $ProjectDir "Excelion.uproject"
$UBTPath = Join-Path $UEPath "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

if (-not (Test-Path $UBTPath)) {
    Write-Error "UnrealBuildTool not found at: $UBTPath. Please verify your UE 5.4 installation path."
    exit 1
}

Write-Host "Building ExcelionEditor ($Configuration)..." -ForegroundColor Cyan
& $UBTPath ExcelionEditor Win64 $Configuration -Project="$UProjectFile" -WaitMutex

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build Succeeded!" -ForegroundColor Green
} else {
    Write-Host "Build Failed with exit code $LASTEXITCODE" -ForegroundColor Red
}
