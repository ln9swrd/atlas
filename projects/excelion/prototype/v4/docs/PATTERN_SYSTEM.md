# PATTERN_SYSTEM — 데이터 드리븐 패턴 DSL

## 경로

```
data/patterns/*.json     # 타임라인 패턴
data/boss/nemesis.json   # 페이즈 → 패턴 id 목록
systems/patternRunner.js
tools/pattern-editor.html
```

## 타임라인 이벤트

| action | 의미 |
|--------|------|
| spawn | 경고→돌진 |
| burst | 연속 n회 |
| redirect / redirect_chain | 재조준 연쇄 |
| feint / feint_cancel | 페인트 |
| shield | 일시 회복(정지) |
| delay | 대기 |

`t` = ms (패턴 시작 기준)

## 보스 연결

```json
"phases": [{ "id": 1, "patterns": ["nemesis_intro"], "modifier": { "speed_scale": 1.0 } }]
```

## Adaptive

```json
"onPerfectStreak": { "speedMultiplier": 1.2, "addPattern": "nemesis_pressure" },
"onMissSpike": { "feintChance": 0.4, "delayIncrease": 150 }
```

## Debug

- F7 패턴 타임라인 오버레이
- F8 히트박스 (기존 F1과 병행)

## 에디터

`tools/pattern-editor.html` — JSON 편집 · 타임라인 미리보기 (로컬 서버)
