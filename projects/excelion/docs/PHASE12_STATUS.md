# PHASE12 — Addiction Polish

## DoD

- [x] PERFECT hitstop 0.12~0.15 + combo 가변 · zoom hold · 1f white flash
- [x] MISS ±ms 표시 + telegraph 0.3s 재표시
- [x] PERFECT 화음 1/2/코드 (streak 4 / 10)
- [x] Telegraph pulse (impact<0.4) · 페인트 흔들림
- [x] Combo50 vignette + player ring
- [x] Adaptive telegraphScale (고숙련 짧게 / MISS 많으면 길게)
- [x] `sessionStats.js` · `window.debug.sessionStats()`

## main.js 연결 메모

```js
import { estimateDeltaMs } from './systems/feedback.js';
import { createSessionStats } from './systems/sessionStats.js';

// onPerfect:
fb.onPerfect(stage.combo);

// onMiss / hurt:
fb.onMiss(estimateDeltaMs(p.dashAge));

// session:
const session = createSessionStats();
window.debug = window.debug || {};
window.debug.sessionStats = () => console.table(session.snapshot());
```

## 실행

```bash
cd projects/excelion/prototype/v4 && npx --yes serve .
```
