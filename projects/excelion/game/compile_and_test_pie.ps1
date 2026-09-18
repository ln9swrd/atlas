# Compile Excelion and run PIE to test AXION visibility fix
# Run this from Windows PowerShell (NOT WSL)

$UEPath = "C:\Program Files\Epic Games\UE_5.4"
$ProjectPath = "D:\Atlas\projects\excelion\game\Excelion"
$SourcePath = "$ProjectPath\Source"

Write-Host "=== Excelion AXION PIE Visibility Test ===" -ForegroundColor Green
Write-Host "Project: $ProjectPath" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if project file exists
$ProjectFile = "$ProjectPath\Excelion.uproject"
if (-not (Test-Path $ProjectFile)) {
    Write-Host "ERROR: Project file not found: $ProjectFile" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Project file found" -ForegroundColor Green

# Step 2: Regenerate Visual Studio project files
Write-Host ""
Write-Host "[STEP 1] Regenerating Visual Studio project files..." -ForegroundColor Yellow
$GenerateFilesExe = "$UEPath\Engine\Build\BatchFiles\GenerateProjectFiles.bat"
if (Test-Path $GenerateFilesExe) {
    & $GenerateFilesExe -VS2022 "$ProjectFile"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Project files generated" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Project file generation exited with code $LASTEXITCODE" -ForegroundColor Yellow
    }
} else {
    Write-Host "[WARN] GenerateProjectFiles.bat not found at $GenerateFilesExe" -ForegroundColor Yellow
}

# Step 3: Compile using UnrealBuildTool
Write-Host ""
Write-Host "[STEP 2] Compiling Excelion..." -ForegroundColor Yellow
$UBTExe = "$UEPath\Engine\Build\BatchFiles\Build.bat"

$BuildParams = @(
    "Excelion",
    "Win64",
    "Development",
    "$ProjectFile",
    "-WaitMutex"
)

Write-Host "Command: $UBTExe $BuildParams" -ForegroundColor Cyan
& $UBTExe @BuildParams

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Compilation successful" -ForegroundColor Green

# Step 4: Run PIE test
Write-Host ""
Write-Host "[STEP 3] Launching PIE test..." -ForegroundColor Yellow
Write-Host "Note: The Editor will open. Press Play (Space) to start PIE test." -ForegroundColor Cyan

$EditorExe = "$UEPath\Engine\Binaries\Win64\UnrealEditor.exe"
$LogFile = "$ProjectPath\Saved\Logs\Excelion.log"

# Launch editor (PIE will require manual Play button press)
Write-Host "Starting UnrealEditor..." -ForegroundColor Green
& $EditorExe "$ProjectFile"

# After editor closes, check log
Write-Host ""
Write-Host "[STEP 4] Checking debug output..." -ForegroundColor Yellow
if (Test-Path $LogFile) {
    Write-Host ""
    Write-Host "=== Latest AXION PIE Debug Output ===" -ForegroundColor Cyan
    $DebugLines = @(Get-Content $LogFile | Select-String "AXION PIE DEBUG" -LastIndex 20)
    if ($DebugLines.Count -gt 0) {
        foreach ($line in $DebugLines) {
            Write-Host $line -ForegroundColor White
        }
    } else {
        Write-Host "(No AXION PIE DEBUG lines found - character may not have spawned)" -ForegroundColor Yellow
    }
} else {
    Write-Host "Log file not found: $LogFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Green
