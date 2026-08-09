# Phase 12.1 튜닝 반영

## 1 HIT 타이밍 고정
- PERFECT → slow **0.15**
- GOOD → slow **0.10** (70%)

## 2 MISS 납득
- `LATE +34ms` / `EARLY -28ms` + 한글 라벨
- timing → 붉은 파형
- range → 찌그러진 링

## 3 Telegraph
- `timeToImpact < 0.1` → scale 1.2 · brightness 1.5

## 4 Combo
- 20+ hitWindowBonus
- 30+ saturation
- 50 vignette + ring

## 5 Adaptive
- telegraphScale **lerp** (×0.12)
- 샘플 5회 이전에는 변화 없음

## 6 Session
- `retries≥3 && avgRun<60s` → `applyEase(boss)`

## main 연결 예

```js
fb.onPerfect(stage.combo);
fb.onGood(stage.combo);
fb.onMiss(estimateDeltaMs(p.dashAge), 'timing');
// 거리 실패 시:
fb.onMiss(0, 'range', { x: p.x, y: p.y });
```
