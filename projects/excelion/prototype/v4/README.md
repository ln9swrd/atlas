# Excelion Prototype V4

모듈화 · JSON 패턴 · 확장 가능 구조

## 구조

```
v4/
  index.html
  main.js
  systems/  timing · player · boss · ui · audio
  data/     boss_patterns.json
```

## 실행

ES modules + fetch 때문에 **로컬 HTTP 필요** (file:// 불가).

```bash
cd projects/excelion/prototype/v4
npx --yes serve .
```

## DoD

- [x] HTML → JS 모듈 분리
- [x] 보스 패턴 JSON
- [x] 입력 버퍼 + PERFECT/GOOD 윈도우 정의
- [x] 쉐이크 · 플래시 · 성공 슬로모 0.1s
- [x] F1–F5 디버그
- [x] V3 플레이 루프 유지
