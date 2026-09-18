# Excelion UE 5.4 Editor Launcher Script
param (
    [string]$UEPath = "C:\Program Files\Epic Games\UE_5.4",
    [string]$ScriptToRun = "",
    [switch]$RunBlueprintAutomation
)

$ErrorActionPreference = "Stop"

$ProjectDir = Resolve-Path "$PSScriptRoot\.."
$UProjectFile = Join-Path $ProjectDir "Excelion.uproject"
$UnrealEditorPath = Join-Path $UEPath "Engine\Binaries\Win64\UnrealEditor.exe"

if (-not (Test-Path $UnrealEditorPath)) {
    Write-Error "UnrealEditor.exe not found at: $UnrealEditorPath. Please verify your UE 5.4 installation path."
    exit 1
}

Write-Host "Launching Unreal Editor 5.4 with Excelion project..." -ForegroundColor Cyan

if ($ScriptToRun) {
    Write-Host "Running Python Script: $ScriptToRun" -ForegroundColor Yellow
    Start-Process -FilePath $UnrealEditorPath -ArgumentList "`"$UProjectFile`"", "-ExecutePythonScript=`"$ScriptToRun`""
} elseif ($RunBlueprintAutomation) {
    $PythonScript = Join-Path $PSScriptRoot "create_blueprints_automation.py"
    Write-Host "Running Blueprint Automation script: $PythonScript" -ForegroundColor Yellow
    Start-Process -FilePath $UnrealEditorPath -ArgumentList "`"$UProjectFile`"", "-ExecutePythonScript=`"$PythonScript`""
} else {
    Start-Process -FilePath $UnrealEditorPath -ArgumentList "`"$UProjectFile`""
}

Write-Host "Unreal Editor launched successfully." -ForegroundColor Green

