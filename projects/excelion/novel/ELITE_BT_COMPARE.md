# ELITE BT 상세 비교

> 2026-08-07 · M2b  
> 근거: `SETH_BATTLE_FIXED` · `CREIL/SETH/AEGIS_MECHA_SPEC` · `ORD_REMNANT_AI_BT`  
> 대상: **세스 · 크레일 · 아이기스** (잔당 BT와 분리)

**상태: 분석 초안**

---

## 0. 한 줄

| 기 | BT 한 줄 |
|----|----------|
| **세스** | 전선을 **읽어 닫는** 차단 실행자 |
| **크레일** | 거점을 **방패로 고정**하는 도구 |
| **아이기스** | 입구를 **게이지로 지키는** 위계 대행 |
| 잔당 | 수·각도·기능 스위치 (지능 없음) |

공통: 숭배·비극·네메시스 오만 **없음**. 패배 = 기동 정지 (+보고 문장 가능).

---

## 1. 공통 ELITE Root

```
ELITE_Root (Selector)
├─ Dead? → Halt (+ optional 「…보고, 끝.」)
├─ PhaseTransition? → EnterP2
└─ RoleSubtree
```

잔당과 차이:
- **Phase** 존재 (P1→P2)
- **차단/방패/게이지** 상태 머신
- 웨이브 매니저 종속 아님 (단독 보스 슬롯)

---

## 2. 세스 BT (EP6)

**목표:** 전선 차단 · 변수 처리 · 격파 가능(계단)

```
SETH (Selector)
├─ P2? (HP≤30% or 차단게이지 붕괴)
│   └─ Sequence: PressureUp → ProcessStrike → Reassess
├─ BlockGaugeActive?
│   └─ Sequence: AnalyzeLane → CloseFront → SealPlate
├─ PlayerCommit?
│   └─ Sequence: Intercept → ShortReport
└─ Default: HoldClose (압박·차단 · 돌진 광기 유도 아님)
```

| 노드 | 의미 |
|------|------|
| AnalyzeLane | 플레이어 축 1개 읽기 (세스급만) |
| CloseFront | 전선 닫기 |
| SealPlate | 차단 게이지 유지 |
| ProcessStrike | 「처리한다」 타이밍 일격 |
| ShortReport | 대사 슬롯 극소 |

**약점 창:** 집념 돌파 · 과부하 지연 → Seal 붕괴 → P2 압박 중 격파.

**감정:** 균열 ≤1 (말 반 박 / 시선 1회). BT에 Emotion 노드 남발 금지.

---

## 3. 크레일 BT (EP15)

**목표:** 거점·전선 **사수** · 방패면 차단 · 사연 0

```
CREIL (Selector)
├─ P2? (방패 내구 임계)
│   └─ Sequence: ShieldOverdrive → WiderCone → Reassess
├─ ShieldUp?
│   └─ Sequence: FaceThreat → ExpandShield → DenyApproach
├─ FlankExposed?
│   └─ Sequence: RotateShield → Replant
└─ Default: AnchorPoint (거점 앞 고정)
```

| 노드 | 의미 |
|------|------|
| ExpandShield | 가로 차단면 · 직선 거부 |
| DenyApproach | 돌입 각 닫기 |
| RotateShield | 측면 찔림 대응 (세스 Analyze와 다름) |
| AnchorPoint | 이동 최소 · “막아선다” |

**약점 창:** 방패 소모 + 팀 각(엄호·관측) → 노출 창에 집념.

**세스와 차이:** 읽기(Analyze) 없음 · **방패 기하**만. 승리 조건이 섬멸이 아니라 사수 쪽에 기울 수 있음(플레이어 목표).

---

## 4. 아이기스 BT (EP21)

**목표:** 게이트 입구 **방패** · 반격 게이지 · 격파=문 개방

```
AEGIS (Selector)
├─ P2? (게이지 2단계)
│   └─ Sequence: CounterWindowWider → HeavyCounter → Reassess
├─ GuardGauge>0?
│   └─ Sequence: FaceGateAxis → GuardIdle → TelegraphedCounter
├─ GuardBroken?
│   └─ Sequence: BriefStagger → PartialReguard or OpenPath
└─ Default: WallStance (접지 · 오만 연출 없음)
```

| 노드 | 의미 |
|------|------|
| GuardIdle | 방어 게이지 유지 |
| TelegraphedCounter | 예고 있는 반격 (공정 창) |
| OpenPath | 격파 시 기동 정지 = 길 열림 |
| WallStance | 가로 정면 · 네메시스 원격 복제 금지 |

**약점 창:** 반격 예고 구간 · 게이지 브레이크 후 스태거.

**금지:** 「급이 아니다」 · 손 완전 숨김 · 오만 Selector.

---

## 5. 비교표

| 축 | 세스 | 크레일 | 아이기스 | 잔당 |
|----|------|--------|----------|------|
| 층 | ELITE | ELITE 동급 | 위계 대행 (ELITE↑) | 양산 |
| 핵심 상태 | 차단 게이지 | 방패 내구 | 가드·반격 게이지 | 없음 |
| 지능 | 축 1개 읽기 | 기하 회전만 | 게이지·예고만 | 없음 |
| 이동 | 닫기·압박 | 최소(앵커) | 최소(벽) | 전진/홀드 |
| 페이즈 | P1→P2 | P1→P2 | P1→P2 | 없음 |
| 패배 문장 | 「…보고, 끝.」 | 동계열 | 문 열림 (보고 선택) | 무음 Halt |
| 재투입 | 잔재만 | EP20 도구 가능 | EP21 1회 | 웨이브 |
| 플레이어 목표 | 격파(계단) | 사수+격파 | 격파=진입 | 경로/신호 |

---

## 6. 잔당 BT와 경계

| 잔당에 없는 것 | ELITE에만 |
|----------------|-----------|
| Phase | ○ |
| 차단/방패/가드 게이지 | ○ |
| AnalyzeLane (세스) | ○ |
| TelegraphedCounter (아이기스) | ○ |
| 단독 보스 슬롯 | ○ |

잔당 Root를 ELITE에 재사용하지 말 것. **역할 모듈이라도 트리 깊이·상태가 다름.**

---

## 7. 네메시스와의 선

ELITE BT에 넣지 말 것:
- 공간 봉쇄 · 원격 일격 주력
- 등급 판정 대사 루프
- 손 숨김 전제 기동
- 「아직 급이 아니다」 / 「시작에 불과하다」

네메시스 = 별도 BT (위계·판정).

---

## 8. 검증

| # | 체크 |
|---|------|
| 1 | 세스≠크레일 (읽기 vs 방패 기하) |
| 2 | 아이기스≠네메시스 (가드 벽 vs 등급) |
| 3 | 잔당 BT 공유 없음 |
| 4 | 패배 연출·문장 SoR 정합 |

**분석 초안 고정.** 실기 시 세스→크레일→아이기스 순으로 상태 머신 재사용 가능(게이지 계열).
