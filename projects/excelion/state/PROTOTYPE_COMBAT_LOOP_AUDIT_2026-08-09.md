# PROTOTYPE COMBAT LOOP AUDIT — 2026-08-09

> 전제: main `d35e821e…` · S2 HOLD · Novel 미터치  
> 대상: `projects/excelion/prototype/` · V4 및 feature/prototype-v* · combat-prototype-v1

**조사·판정만 · 본 PR에서 코드 수정 없음 · 승인 전 merge 금지**

---

## 0. 판정 요약

| 코드 | 의미 | 본 감사 |
|------|------|--------|
| A | 기존 구현을 main에 이식 | — |
| B | 일부 재사용 + 최소 수정 | — |
| C | 전투 루프 신규 구현 | — |
| **D** | **전투 부재가 아님 · 다른 요인(근접 전용·압박 밀도)** | **채택** |

**실제 코드 수정 필요 (긴급): 0** — 루프는 main V4에 이미 존재.

---

## 1. MAIN V4 구조 (코드 근거)

| 항목 | 위치 | 상태 |
|------|------|------|
| 입력 이동 | `systems/player.js` `update` · WASD/Arrow | **있음** |
| 대시/회피 | `tryDash` · Space/Shift · invuln | **있음** |
| 공격 입력 | `queueAttack` · **J/Z · mousedown** | **있음** |
| 공격 버퍼 | `bufferAttack` · `consumeAttackBuffer` | **있음** |
| 공격 판정 | `main.js` `playerAttack()` | **있음** |
| 보스 HP 감소 | `boss.hp -= 14` (근접 시) | **있음** |
| 보스 사망 | `boss.hp <= 0` → `alive=false` → `onClear` | **있음** |
| 플레이어 피격 | `onHitPlayer` · `p.hp -= e.damage` | **있음** |
| 플레이어 사망 | `p.hp <= 0` → `onFail` · YOU DIED | **있음** |
| 승패/재시작 | `finishResult` · Enter Retry · R Select | **있음** |
| 적 AI/패턴 | `boss.js` · `patternRunner` · JSON patterns | **있음** |
| 실제 루프 | select → fight → clear/fail → retry | **있음** |

### 1.1 `playerAttack` 핵심 (main.js)

- `stage.status === 'fight'` 이고 `boss.alive`일 때만.
- **거리 조건:** `(p.r + boss.r + 22)²` 이내만 데미지.
- 성공 시 HP −14 · 플래시 · PERFECT/GOOD/MISS 판정(대시 타이밍 연동).
- HP ≤ 0 → CLEAR.

### 1.2 플레이어 측

- 원거리 발사체 **없음**.
- 공격은 **근접 한 방**만.

### 1.3 README DoD

- V3 플레이 루프 유지 · 모듈/JSON · 타이밍 윈도우 — **공격 루프 누락으로 기술되지 않음.**

---

## 2. 「도망만 다닌다」원인 (추측 금지 · 코드)

| 가설 | 코드 판정 |
|------|-----------|
| 공격 시스템 부재 | **기각** — `playerAttack` + J/Z/클릭 |
| 입력만 있고 판정 없음 | **기각** — 거리 내 HP 감소·사망 처리 |
| 적 AI 추적만 | **부분** — 패턴 탄막/텔레그래프 중심 · 플레이어 추적형 근접 AI만이 전부가 아님 |
| 전투 상태머신 부재 | **기각** — stage status · boss phase · patternRunner |
| 피해/사망 루프 부재 | **기각** — onHitPlayer / onFail / onClear |
| **근접 전용 + 짧은 리치** | **채택** — 보스 반지름+22px 안만 히트 → 탄막 중 접근 부담 |
| **지속 패턴 압박** | **채택** — patternDriven 보스 연속 스폰 · 빈틈이 짧으면 공격 기회 < 회피 필요 |
| 밸런스(데미지/쿨)** | 보조 요인 — 1회 14 · 보스 maxHp는 JSON (다수 히트 필요) |

**한 줄:** 시스템은 「회피 타이밍 보스전」으로 구현되어 있고, **공격은 존재하나 근접 강제**라서 체감이 도망 위주로 굳기 쉬움.

---

## 3. 후속 브랜치 조사

| 브랜치 | SHA(조사 시점) | 비고 |
|--------|----------------|------|
| `feature/prototype-v4-structure` | b8f2793… | 구조 기반 |
| `feature/prototype-v6-game-loop` | c7fea6c… | `player.js`에 **동일** bufferAttack/queueAttack 계열 · 루프 계승 |
| `feature/prototype-v8-nemesis-feel` | 4a2fcc2… | 네메시스 피감 · main에 패턴/피드백 흡수된 이력 |
| `feature/prototype-v11-feel` | 1029c9e… | feel 레이어 |
| `feature/prototype-v12-addiction` | dfcdbb0… | adaptive와 동일 계열 tip |
| `feature/combat-prototype-v1` | 9419ff9… | **prototype 경로 트리 공백** (이 브랜치에 v4 경로 미존재 또는 다른 루트) |
| `fix/excelion-adaptive-v4` | dfcdbb0… | v12와 동일 tip |

**결론:** main의 `prototype/v4`는 이미 v6~v12 계열 기능(공격 버퍼·패턴·리플레이·고스트·adaptive)을 **통합한 상태**에 가깝다. 전투 루프를 위해 별도 브랜치를 통째로 머지할 **필수성 낮음**.

`combat-prototype-v1`은 경로상 prototype/v4를 제공하지 않아 **main 이식 소스로는 부적합(현 조사)**.

---

## 4. 판정 **D** 상세

- 플레이어: 이동 · 대시 · 공격 입력 · 버퍼 · 근접 히트 · 보스 처치 · 피격 · 사망 · 재시작 **전부 main에 존재**.
- 「도망만」체감의 1차 원인은 **시스템 부재가 아니라 교전 디자인**(근접 only + 패턴 밀도).
- 따라서 **A/B/C(이식·신규 루프) 불필요**.
- 개선이 필요하면 **별도 승인 후** 최소 변경 후보만 (아래 §6) — **본 감사 PR 범위 밖**.

---

## 5. 금지 준수

- Novel · S2 · 캐논 · 대규모 리팩터 · UI 전면 개편 · 임의 기능: **없음**
- 본 PR: **state 문서만**

---

## 6. 후속 후보 (실행 금지 · Master 지시 시)

| 후보 | 성격 | 위험 |
|------|------|------|
| 공격 리치 +8~16px | 밸런스 1줄 | 낮음 |
| 패턴 간 idle 간격 소폭 증가 | 데이터/runner | 중간 |
| 근접 성공 시 짧은 경직 | feel | 중간 |
| 원거리 기본탄 추가 | **신규 시스템** | 높음 · 비권장(최소 목표 초과) |

최소 목표「도망→교전→공격→피격→처치」는 **이미 코드상 가능** (근접 진입 필요).

---

## 7. 검증 (정적 · 실행 서버 미기동)

| 항목 | 결과 |
|------|------|
| 공격 입력 경로 | J/Z/mousedown → queueAttack → consume → playerAttack |
| hit 판정 | 거리 제곱 비교 |
| damage | boss.hp − 14 |
| enemy death | hp≤0 · onClear · CLEAR |
| restart | Enter / R / #restart |
| regression | 본 PR 코드 변경 **0** |

로컬 `npx serve` 플레이 검증은 **운영자 환경**에서 확인 권장.

---

## 8. Git / 보고 필드

| 항목 | 값 |
|------|-----|
| 현재 main 문제 | 체감 도망 편향 · **루프 부재 아님** |
| 원인 | 근접 전용 공격 + 패턴 압박 |
| 기존 브랜치 재사용 | main이 이미 통합 · 추가 이식 **불필요** |
| 판정 | **D** |
| 수정 파일 (구현) | **없음** |
| CONFLICT | **0** |
| 신규 캐논 | **0** |
| S2 | **HOLD** |

---

## 9. 한 줄

**main V4는 이미 완전한 보스전 루프를 갖고 있다. 「도망만」은 공격 부재가 아니라 근접+압박 설계 문제이며, 신규 전투 구현(C)이나 브랜치 강제 이식(A)은 해당하지 않는다 (D).**
