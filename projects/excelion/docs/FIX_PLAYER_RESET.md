# Fix: playerSys.reset is not a function

## 원인

1. **구버전 캐시** — 브라우저/CDN이 예전 `player.js`를 들고 있음
2. **로드 전 호출** — `loadData()` 완료 전 `startBoss` 실행
3. **브랜치 불일치** — `main`에 v4 player 없을 수 있음 → **feature/prototype-v12-addiction** 사용

## 해결 (이미 반영)

`systems/player.js` 에 `reset()` 명시 정의 + bind.
`systems/safeStart.js` 폴백 제공.

## 로컬 확인

```bash
cd projects/excelion/prototype/v4
git fetch && git checkout feature/prototype-v12-addiction
npx --yes serve .
```

브라우저 **강제 새로고침** (Ctrl+Shift+R).

콘솔:

```js
// load 후
playerSys // should show reset: ƒ
```

## main 한 줄 방어 (선택)

```js
import { safePlayerReset } from './systems/safeStart.js';
// startBoss 안:
safePlayerReset(playerSys, W, H);
```
