# boot.js 연결

`main.js` loadData().then 끝에:

```js
import { wireBoot } from './boot.js';
// ...
wireBoot({
  startNemesis: () => startBoss('boss/nemesis.json'),
  getMeta: () => ({
    score: stage?.score || 0,
    rank: lastRank,
    acc: stage?.accuracy?.() || 0,
    boss: lastBossFile || 'nemesis',
  }),
});
```

`applyStyleAdaptive(boss, style.stats(), stage)` 로 stage 인자 추가.
`fb.drawOverlays(ctx, W, H, { combo: stage.combo, lowHp: playerSys.p.hp < 20 })`
`onPhaseChange`에서 `fb.onPhaseEnter(); sfx.phaseCut?.();`
