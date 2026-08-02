# makerfac 1세션 실행 (Task Scheduler / 수동 공통)
# 전제: 크롬이 --remote-debugging-port=9222 로 이미 실행·로그인된 상태

$ErrorActionPreference = "Stop"
$ToolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ToolsDir

$LogDir = Join-Path (Split-Path $ToolsDir -Parent) "notes"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
$OutLog = Join-Path $LogDir ("run-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".log")

Write-Host "=== makerfac collect_safe $(Get-Date -Format 'yyyy-MM-dd HH:mm') ==="
try {
    $null = Invoke-WebRequest -Uri "http://127.0.0.1:9222/json/version" -UseBasicParsing -TimeoutSec 5
} catch {
    Write-Host "크롬 9222 연결 실패. 디버깅 모드 크롬을 먼저 켜세요."
    "CDP fail: $_" | Out-File -FilePath $OutLog -Encoding utf8
    exit 1
}

# 기본 50개 / 일 100 상한은 collect_safe.py 내부
python collect_safe.py --limit 50 2>&1 | Tee-Object -FilePath $OutLog
exit $LASTEXITCODE
