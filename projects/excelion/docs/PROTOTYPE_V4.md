# PROTOTYPE V4/V5 — 구조와 확장

## 실행

```bash
cd projects/excelion/prototype/v4
npx --yes serve .
```

키: **1/2/3** 보스 선택 · WASD · Space 대시 · J 공격 · R 메뉴

## 모듈

| 파일 | 역할 |
|------|------|
| `main.js` | 루프 · 보스 선택 |
| `systems/stage.js` | select/fight/clear/fail |
| `systems/boss.js` | JSON 패턴 AI · 실루엣 |
| `systems/player.js` | 이동 · 대시 · 입력 버퍼 |
| `systems/timing.js` | PERFECT/GOOD · 연출 |
| `systems/audio.js` | SFX 인터페이스 |
| `systems/ui.js` | HP/배너 |

## 보스 데이터

| 파일 | 표시 |
|------|------|
| `boss_brave.json` | MONTU |
| `boss_mass.json` | SETH |
| `boss_ashur.json` | **NEMESIS** (id만 ashur · 설정 폐기 반영) |

보스 추가: JSON 작성 → `roster.json`에 등록.

## 판정

- PERFECT ±0.05s (대시 직후)
- GOOD ±0.12s
- MISS / TOO LATE / FAKE READ

## Debug

F1 HB · F2 God · F3 Clear · F4 Speed · F5 Force phase · F6 Skip pattern
