# SETH_BOSS_ARENA_PRODUCTION_TASK_BREAKDOWN — Excelion

> 2026-08-16 · 작업 단위 분해 전용
> Canon / Novel / Unreal 코드 / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: 승인된 Minimum Production Spec을 **실제 작업 단위로 쪼개고**, 각 단위의 선행조건·산출물·검증 기준을 명시
> 구현·콘텐츠 제작은 하지 않음

**상태: Task Breakdown 완료 · Master 제작 착수 지시 대기**

---

## STATUS

### 완료
- Minimum Spec 기반 작업 단위 분해
- 선행조건 / 산출물 / 검증 기준 정리
- 문서 저장: 본 파일

### 유지 조건 (Master 승인)
- Input fallback → IMPLEMENTED / UNVERIFIED (검증 보류)
- ORD-GRUNT → HOLD
- Canon / Novel → 변경 금지
- Core Gameplay Lock → 아직 선언하지 않음
- Placeholder → 최소 범위 허용 (최종 제작물로 간주 금지)
- AXION/SETH 핵심 외형 → 최종 디자인 대체 금지

### Master 결정 필요
- 제작 착수 지시 (어느 Task부터 시작할지)
- Placeholder 품질 기준 세부 확정

---

## 승인 범위 요약

```text
Seth Boss Arena VS
├─ Level          : Arena 최소 공간 · Collision · Spawn · 최소 Lighting
├─ AXION          : 기존 이동/전투 재사용 + VS 최소 모션
├─ SETH           : Boss Logic 재사용 + 공격/피격/사망 시각
└─ Presentation   : Camera · 최소 VFX · 최소 Audio · 최소 UI
```

근거:
- state/SETH_BOSS_ARENA_MINIMUM_PRODUCTION_SPEC.md (APPROVED)
- state/VERTICAL_SLICE_CANDIDATE_REVIEW.md
- state/CURRENT_STATE.md (P5-4 VERIFIED)

---

## 작업 순서 (권장)

```text
T1  Level Blockout
      ↓
T2  AXION / SETH 배치 + 기존 Gameplay 재사용 확인
      ↓
T3  Boss Arena 전투 흐름 (기존 로직)
      ↓
T4  최소 Animation
      ↓
T5  최소 VFX
      ↓
T6  최소 Audio
      ↓
T7  Presentation 정리
      ↓
T8  PIE 통합 검증
      ↓
T9  부족한 부분만 보강
```

**한 번에 여러 Task를 병렬로 크게 열지 않는다. T1부터 순차 진행을 기본으로 한다.**

---

## Task 상세

### T1 — Level Blockout

| 항목 | 내용 |
|------|------|
| 목적 | 플레이 가능한 최소 Arena 공간 확보 |
| 선행조건 | Minimum Spec 승인 |
| 작업 내용 | 평면/박스 기반 Arena · Player/Boss Spawn Point · 최소 Collision (낙하 방지) · 기본 Lighting |
| 산출물 | 플레이 가능 맵 (NewMap 기반 또는 신규 최소 맵) |
| 검증 기준 | PIE에서 Player/Boss Spawn 성공 · 이동 가능 · 낙하/이탈 없음 · 시야 확보 |
| Placeholder | 환경 Mesh 허용 |
| 금지 | 테마 디테일 · 파괴 오브젝트 · 대규모 지형 |

### T2 — AXION / SETH 배치 + 기존 Gameplay 재사용 확인

| 항목 | 내용 |
|------|------|
| 목적 | 기존 VERIFIED 시스템이 Arena에서 동작하는지 확인 |
| 선행조건 | T1 완료 |
| 작업 내용 | BP_ExcelionCharacter / BP_SethBoss 배치 · GameMode 연결 · 기존 Spawn/Combat/Damage/Death 로직 확인 |
| 산출물 | Arena에 배치된 플레이어·보스 · 기존 루프 동작 확인 기록 |
| 검증 기준 | Spawn → 이동 → 공격 → 피격 → Boss Phase 전환 → Death/Victory/Defeat/Retry 중 핵심 경로 동작 |
| Placeholder | 기존 placeholder 메쉬 유지 |
| 금지 | Core Gameplay 코드 변경 · Input 수정 |

### T3 — Boss Arena 전투 흐름

| 항목 | 내용 |
|------|------|
| 목적 | P5-4 / U4-B 검증된 전투 루프를 Arena 공간에 고정 |
| 선행조건 | T2 완료 |
| 작업 내용 | Phase 1→2 · Pattern 01/02 · Dash Invulnerability · Victory/Defeat 전이 확인 |
| 산출물 | 전투 흐름 체크리스트 PASS 기록 |
| 검증 기준 | U4-B / P5-4 시나리오와 동일한 핵심 동작이 Arena에서 재현됨 |
| Placeholder | 해당 없음 (로직 재사용) |
| 금지 | 보스 수치·패턴 로직 변경 |

### T4 — 최소 Animation

| 항목 | 내용 |
|------|------|
| 목적 | 이동·공격·피격·사망이 시각적으로 구분되도록 최소 모션 확보 |
| 선행조건 | T3 완료 (로직 안정) |
| 작업 내용 | AXION: Idle / Locomotion / Attack / Dash / Hit / Death 최소 · SETH: Phase 자세 / Attack 텔레그래프 / Hit / Death 최소 |
| 산출물 | 최소 Anim 세트 (또는 Placeholder 포즈) |
| 검증 기준 | 각 상태 전환 시 시각적 피드백 존재 |
| Placeholder | **조건부 허용** (포즈/단순 사이클 가능) |
| 금지 | 최종 퀄리티 애니 요구 · 핵심 외형 디자인 변경 |

### T5 — 최소 VFX

| 항목 | 내용 |
|------|------|
| 목적 | 타격·패턴·피격이 식별 가능하도록 최소 이펙트 |
| 선행조건 | T4 진행 중 또는 완료 |
| 작업 내용 | 타격/피격 · 대시 잔상 · 씰/빔/블라스트 최소 · 사망 최소 |
| 산출물 | 최소 VFX 세트 |
| 검증 기준 | 공격·피격 시 이펙트 발동 확인 |
| Placeholder | **허용** |
| 금지 | 고퀄 폴리시 · 환경 파괴 VFX |

### T6 — 최소 Audio

| 항목 | 내용 |
|------|------|
| 목적 | 타격·패턴 피드백용 최소 사운드 |
| 선행조건 | T5와 병행 가능 |
| 작업 내용 | 타격 SFX · 피격 · 대시 · Pattern Warning · 사망 (placeholder 가능) |
| 산출물 | 최소 SFX 세트 |
| 검증 기준 | 주요 액션 시 사운드 재생 (또는 의도적 무음 placeholder 명시) |
| Placeholder | **허용** |
| 금지 | 풀 BGM · 보이스 필수화 (보이스는 OPTIONAL) |

### T7 — Presentation 정리

| 항목 | 내용 |
|------|------|
| 목적 | Camera / HUD / Result UI가 Arena에서 안정적으로 동작 |
| 선행조건 | T3 완료 |
| 작업 내용 | Camera 추적 확인 · HUD 표시 · Victory/Defeat UI · Retry |
| 산출물 | Presentation 체크리스트 PASS |
| 검증 기준 | HUD 정상 · 결과 UI 전이 · Retry 후 재시작 |
| Placeholder | UI 허용 |
| 금지 | 신규 UI 시스템 · 스토리 컷신 |

### T8 — PIE 통합 검증

| 항목 | 내용 |
|------|------|
| 목적 | 전체 VS 루프가 Arena에서 한 번에 통과하는지 확인 |
| 선행조건 | T1~T7 최소 완료 |
| 작업 내용 | P5-4 시나리오 재실행 + Arena 콘텐츠 포함 검증 · (가능 시) Input fallback 회귀 확인 |
| 산출물 | 검증 로그 / PASS·FAIL 기록 |
| 검증 기준 | Spawn → Combat → Boss Phase → Victory 또는 Defeat → Retry 전 구간 동작 |
| Placeholder | 해당 없음 |
| 금지 | 검증 중 임의 코드/에셋 수정 (문제 발견 시 보고만) |

### T9 — 부족한 부분만 보강

| 항목 | 내용 |
|------|------|
| 목적 | T8에서 발견된 최소 결함만 수정 |
| 선행조건 | T8 FAIL 항목 존재 |
| 작업 내용 | FAIL 원인 분석 → Master 승인 후 최소 수정 |
| 산출물 | 보강 후 재검증 기록 |
| 검증 기준 | 해당 FAIL 항목 PASS |
| 금지 | 범위 확대 · 신규 기능 추가 |

---

## 공통 규칙

1. **구현 착수 전** Master의 명시적 착수 지시 필요
2. 각 Task 완료 시 **검증 기준 PASS** 후에만 다음 Task 진행
3. 문제 발견 시 **수정하지 말고 보고** (특히 Input / Core Gameplay / Canon)
4. Placeholder는 파이프라인·플레이 가능성 검증용이며 최종물로 간주하지 않음
5. AXION/SETH 핵심 외형 디자인을 임시로 바꾸지 않음
6. ORD-GRUNT 제작 금지 (HOLD)
7. Input fallback 수정 금지 (검증 보류 상태 유지)

---

## 변경하지 않은 것

- Canon
- Novel
- Unreal C++ / Blueprint / Asset (본 문서 작성만)
- Animation / VFX / Audio 실파일
- Input
- ORD-GRUNT
- Core Gameplay 구조

---

## NEXT

다음 작업:
- Master의 제작 착수 지시 (권장: T1 Level Blockout부터)

선행 조건:
- 본 Task Breakdown 승인
- T1 착수 지시

검증 필요:
- 각 Task별 검증 기준
- 최종 T8 PIE 통합 검증

**본 문서는 작업 단위 분해만 수행한다. 구현 지시가 아니다.**
