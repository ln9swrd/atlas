# 안전 수집 가이드 (크롬 연결 반자동)

로그인만 직접 하고, Playwright가 **이미 열린 크롬**에 붙어 소량·저속으로 수집합니다.

## 안전 규칙 (필수)

| 항목 | 값 |
|------|-----|
| 세션당 최대 열람 | **20~30개** |
| 글 사이 대기 | **8~20초** 랜덤 |
| 일일 상한 | **50개 이하** |
| Headless | **사용 금지** (창 보이게) |
| 재열람 | `notes/viewed-ids.md`에 있으면 **스킵** |
| 실행 시간 | 낮~저녁, 사람처럼 짧게 |

의심되면 **즉시 중단**. 본 계정 보호가 데이터보다 우선입니다.

## 1. 크롬을 디버깅 모드로 실행

### Windows (PowerShell)

1. 기존 크롬을 **모두 종료**
2. 실행:

```powershell
& "$env:ProgramFiles\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:LOCALAPPDATA\chrome-makerfac-debug"
```

3. 열린 크롬에서 **네이버 로그인** 후 카페 접속 확인

> `--user-data-dir`를 따로 쓰면 평소 크롬과 프로필이 분리됩니다.  
> 평소 프로필을 쓰려면 경로를 본인 기본 User Data로 맞추되, **크롬을 모두 끈 뒤**에만 디버깅 포트로 실행하세요.

### macOS

```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/chrome-makerfac-debug"
```

## 2. 의존성

```bash
cd projects/makerfac-needs-research/tools
pip install playwright
playwright install chromium
```

(연결 모드는 설치된 크롬을 쓰므로, Chromium 설치는 선택입니다.)

## 3. 실행

```bash
cd projects/makerfac-needs-research/tools
python collect_safe.py
```

- 기본: 질문&답변 게시판, 키워드 없음(목록 순)
- 키워드 예:

```bash
python collect_safe.py --keyword "STL"
python collect_safe.py --keyword "모델링" --limit 20
```

## 4. 결과물

- 원문 요약 초안: `collected/_inbox/` (분류 전 임시)
- 열람 기록: `notes/viewed-ids.md` (자동 append)
- 세션 요약: 콘솔 출력 → `notes/session-log.md`에 수동 또는 스크립트 기록

## 5. 중단 기준

- 캡차 / 비정상 접근 안내
- 로그인 풀림·카페 접근 제한
- 로딩이 비정상적으로 느리거나 빈 페이지 반복

→ 스크립트 중지 후 당일 재시도하지 말 것.
