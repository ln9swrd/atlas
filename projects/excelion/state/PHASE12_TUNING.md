# PHASE12_TUNING — Play Feel (Phase 12 → 12.1)

> Updated: 2026-08-09  
> Goal: **PERFECT는 보상, MISS는 납득 → 계속 하게 만드는 루프**

## 원칙

1. **한 순간에는 1개의 감각만 강하게**
2. **PERFECT = 감정 폭발**
3. **MISS = 이해 + 다음 기회 제공**

---

## 1. MISS 피드백 (최우선)

```js
// 기존: 숫자만
showTimingError(ms);

// 수정
showTimingError(ms, {
  text: ms > 0 ? `늦음 +${ms}ms` : `빠름 ${ms}ms`,
  color: "red",
  wave: true,        // 붉은 파형
  ringDistort: true  // 링 찌그러짐
});

// MISS 직후
telegraph.reappear(0.3); // 다음 기회 즉시 제공
```

의도:
- 왜 실패했는지 이해
- 다음 입력 타이밍 바로 제시

---

## 2. HIT 판정 구조

```js
const PERFECT = 0.15;
const GOOD    = 0.10;

function judgeHit(delta) {
  if (Math.abs(delta) <= PERFECT) return "PERFECT";
  if (Math.abs(delta) <= GOOD)    return "GOOD";
  return "MISS";
}
```

- PERFECT 범위가 GOOD보다 넓은 것은 유지
- 연출 차이를 크게 둔다

---

## 3. HIT 연출 — 선택적 적용 (중첩 제거)

### PERFECT (딱 3개만 강하게)
```js
function onPerfect() {
  applyHitStop(0.12);  // 핵심 1
  flashFrame();        // 핵심 2
  playChord();         // 핵심 3

  // 제거 또는 조건부
  // zoomHold   → Combo 20+ 에서만
  // wobble     → 제거 (과함)
}
```

### GOOD (흐름 유지)
```js
function onGood() {
  applyHitStop(0.06);
  playSingleNote();
}
```

---

## 4. Telegraph 임박 연출 (유지 + 정리)

```js
if (timeToHit < 0.1) {
  telegraph.scale     = 1.2;
  telegraph.brightness = 1.5;
  telegraph.pulseSpeed += 0.2; // +20%
}
```

---

## 5. Combo 시스템 (중독 핵심)

```js
if (combo >= 20) widenHitWindow(1.1);
if (combo >= 30) increaseSaturation(1.2);
if (combo >= 50) applyVignette(true);

if (combo % 10 === 0) {
  playAccentSound(); // “쾅”
}
```

---

## 6. Adaptive 난이도 (조기 개입)

```js
// 기존: samples >= 5
if (samples >= 3) {
  difficulty = lerp(difficulty, playerSkill, 0.05); // 완만 유지
}
```

- 초반 10초 안에 반응해야 함

---

## 7. Session 중독 트리거

```js
if (retryCount >= 3 && avgPlayTime < 60) {
  applyEase(); // 판정 살짝 완화
}

if (justFailed) {
  nextSpawnDelay *= 0.8; // 템포 빠르게 → “한 번만 더”
}
```

---

## 최종 핵심 구조 요약

| 순간     | 적용 요소                          | 목적              |
|----------|------------------------------------|-------------------|
| PERFECT  | HitStop + White Flash + Chord Sound | 감정 폭발 (3개만) |
| MISS     | ±ms + 붉은 파형 + 링 왜곡 + 다음 예고선 | 이해 + 기회      |
| Combo    | 시각 보상 + 10배수 악센트          | 중독              |
| Adaptive | samples ≥ 3 + 완만한 lerp          | 이탈 방지         |
| Session  | retry ≥ 3 시 Ease + Fail 후 템포↑  | “한 번만 더”      |

---

## 한 줄 결론

지금은 “좋은 기능들” 상태.  
만들어야 하는 것: **손이 멈추지 않는 리듬**.

---

## Next

- [ ] main.js / 프로토타입에 위 규칙 반영 (코드 패치)
- [ ] 플레이테스트로 감각 검증
