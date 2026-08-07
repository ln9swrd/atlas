# ORD 잔당 — AI 행동 트리 분석

> 2026-08-07 · M2b  
> 근거: `ORD_REMNANT_TACTICS` · `BALANCE_ENEMY_MULT` · `ORD_SPEC`  
> 용도: 실기 AI · EP17 맵 클리어 · 소설 연출 동기화

**상태: 분석 초안 (구현 전 · 전술 패턴과 1:1)**

---

## 0. 설계 원칙

| 원칙 | 내용 |
|------|------|
| 단순 | Selector / Sequence 위주 · 깊은 트리 금지 |
| 무감정 | 도주·항복·사연 노드 없음 |
| 역할 고정 | 타입별 루트 목표 1개만 |
| 재배치 빠름 | 사망 시 슬롯만 비움 · 대열 AI는 상위 스폰/웨이브 |
| ELITE 분리 | 세스·크레일 BT와 **공유 금지** |

한 줄: **기능 스위치**. 지능형 보스 아님.

---

## 1. 공통 루트 (모든 잔당)

```
Root (Selector)
├─ [Priority] Dead? → Halt (기동 정지 · 연출 없음)
├─ [Priority] Stunned/Overload? → Recover
└─ RoleSubtree  ← 타입별
```

- HP≤0 → 즉시 Halt. 보고·절규 노드 없음.
- 상위 웨이브 매니저가 스폰·동시 수·목표 좌표만 주입.

---

## 2. GRUNT 행동 트리

**루트 목표:** 플레이어/목표 축에 **수 압박**

```
GRUNT (Selector)
├─ InMeleeRange?
│   └─ Sequence: Face → Attack (근접 화기/블레이드) → ShortCooldown
├─ HasLaneTarget?
│   └─ Sequence: MoveStraight (짧은 대시 허용) → Reassess
└─ Default: AdvanceToFrontline
```

| 노드 | 행동 |
|------|------|
| MoveStraight | 직선·최소 회피 · 기동 1.0× |
| Attack | DMG 4–6 · 콤보 짧게 |
| Reassess | 0.3–0.5s · 줄 재정렬은 웨이브 측 |

**약점 노출:** 한 축에 밀집 → 플레이어 끊기(필살/돌파)에 다수 동시 피격.

---

## 3. HEAVY 행동 트리

**루트 목표:** 지정 **축/통로 봉쇄**

```
HEAVY (Selector)
├─ AxisBreached?
│   └─ Sequence: RepositionToAxis → PlantShield
├─ EnemyInFrontCone?
│   └─ Sequence: Hold · HeavyFire/ShieldBash
└─ Default: HoldPosition (둔 · 0.6×)
```

| 노드 | 행동 |
|------|------|
| PlantShield | 축 고정 · ARM 유리 |
| HoldPosition | 이동 최소화 |
| HeavyFire | DMG 8–12 · 느린 주기 |

**약점 노출:** 측면·후면 창 · 기동 느림 → 우회·팀 각에 붕괴.

---

## 4. GUN 행동 트리

**루트 목표:** **원거리 견제** · 접근 지연

```
GUN (Selector)
├─ TooClose?
│   └─ Sequence: BackstepOrStrafe → KeepRange
├─ HasLOS?
│   └─ Sequence: Aim → Fire (포신) → Cooldown
└─ Default: SeekHighGroundOrCoverEdge
```

| 노드 | 행동 |
|------|------|
| KeepRange | 원거리 밴드 유지 · 기동 0.9× |
| Fire | DMG 5–8 · 탄도 단순 |
| SeekHighGround | 시야 우선 · 근접 실루엣 약함 |

**약점 노출:** LOS 차단·근접 돌입 시 화력 급감.

---

## 5. 웨이브 매니저 (잔당 상위)

잔당 개별 BT에는 **전황 판단 없음**. 상위에서만:

```
WaveManager
├─ Spawn slots (GRUNT 4–8 / HEAVY 0–2 / GUN 0–3)
├─ Assign axis / lane targets
├─ On slot empty → optional refill (잔당 웨이브 한도 내)
└─ WinCheck: player path clear OR signal stable → stop spawn
```

EP17: 스폰 한도 짧게 · 경로/신호 조건으로 종료 (섬멸 강제 아님).

---

## 6. 금지 노드 (전 타입)

| 금지 | 이유 |
|------|------|
| Flee / Surrender | 무감정 · 도구 |
| Taunt / Speech | 사연 없음 |
| ReadPlayerPattern (세스급) | ELITE 전용 |
| SpatialSeal (네메시스급) | 위계 전용 |
| SelfBuffGrowth | 성장 없음 |
| CallElite | 잔당≠소환 주체 |

---

## 7. 소설·AI 동기화

| 소설 키 | BT 대응 |
|---------|---------|
| “많이 나온다” | GRUNT 동시 수 + Advance |
| “한 대가 무겁다” | HEAVY Hold + Shield |
| “멀리서 쏜다” | GUN LOS + Fire |
| 끊기면 재배치 | Wave refill / lane reassign |
| 기동 정지 | Dead → Halt |

---

## 8. 검증

| # | 체크 |
|---|------|
| 1 | 타입별 목표 1개 · 트리 얕음 |
| 2 | 전술 패턴 문서와 1:1 |
| 3 | ELITE/네메시스 노드 혼입 없음 |
| 4 | EP17 승리 조건(경로/신호)과 웨이브 종료 연동 가능 |

**분석 초안 고정.** 실기 구현 시 이 BT를 출발점으로 한다.
