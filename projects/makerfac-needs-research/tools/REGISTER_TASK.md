# 자동 실행 (Windows 작업 스케줄러)

**한 번 실행 = 최대 25개.** 하루 상한 50개(스크립트 내장).

## 전제 (중요)

스케줄러는 **크롬을 대신 로그인하지 않습니다.**

1. PC 켜둔 동안 디버깅 크롬을 한 번 실행해 두고 네이버 로그인 유지  
   또는 작업 전에 직접 크롬(9222)을 켠다.
2. 로그인 만료·캡차 시 해당 세션은 실패하거나 빈 페이지가 될 수 있음 → 로그 확인.

크롬 실행 예 (수동, 로그인용):

```powershell
& "$env:ProgramFiles\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:LOCALAPPDATA\chrome-makerfac-debug"
```

## 권장 스케줄 (안전)

| 항목 | 권장 |
|------|------|
| 횟수 | **하루 1회** (여유 있으면 2회, 최소 6시간 간격) |
| 시각 | 오후 등 본인이 PC 앞에 있을 때 |
| 세션당 | 25개 |
| 일 상한 | 50개 (초과 시 스크립트가 바로 종료) |

## 등록 방법

### 1) 한 줄로 등록 (관리자 아님, 현재 사용자)

PowerShell:

```powershell
$action = New-ScheduledTaskAction `
  -Execute "powershell.exe" `
  -Argument "-NoProfile -ExecutionPolicy Bypass -File `"D:\Atlas\projects\makerfac-needs-research\tools\run_session.ps1`""

$trigger = New-ScheduledTaskTrigger -Daily -At "15:00"

Register-ScheduledTask `
  -TaskName "makerfac-collect-safe" `
  -Action $action `
  -Trigger $trigger `
  -Description "makerfac 안전 수집 1세션(25개)" `
  -Force
```

시각은 `-At "15:00"` 을 원하는 시간으로 바꾸면 됩니다.

### 2) GUI

1. `taskschd.msc` 실행
2. 기본 작업 만들기 → 이름 `makerfac-collect-safe`
3. 트리거: 매일 1회
4. 동작: 프로그램 `powershell.exe`
5. 인수:
   `-NoProfile -ExecutionPolicy Bypass -File "D:\Atlas\projects\makerfac-needs-research\tools\run_session.ps1"`

## 실행 전 체크

- [ ] 크롬 9222 + 네이버 로그인
- [ ] `http://127.0.0.1:9222/json/version` 응답
- [ ] 오늘 이미 50개 가까이 돌리지 않았는지

## 로그

- 콘솔 복사본: `notes/run-YYYYMMDD-HHMMSS.log`
- 세션 요약: `notes/session-log.md` (스크립트가 append)

## 끄기

```powershell
Unregister-ScheduledTask -TaskName "makerfac-collect-safe" -Confirm:$false
```
