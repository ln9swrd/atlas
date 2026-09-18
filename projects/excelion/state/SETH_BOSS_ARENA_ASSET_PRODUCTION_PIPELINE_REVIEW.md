# SETH_BOSS_ARENA_ASSET_PRODUCTION_PIPELINE_REVIEW — Excelion

> 2026-08-16 · READ-ONLY 조사 + 문서화 전용
> Canon / Novel / Unreal C++ / Blueprint / Asset / Animation / VFX / Audio / Input / ORD-GRUNT **변경 없음**
> 목적: T1 실기 검증 및 T2~T9 구현 보류 상태에서, Seth Boss Arena에 필요한 신규 Animation / VFX / Audio의 **현실적인 제작 파이프라인**과 **최소 생산 단위**를 정의
> **Asset 생성·Unreal 수정·구현 수행하지 않음**

**상태: Asset Production Pipeline Review 완료 · 실제 제작 착수 대기 (T1 VERIFIED 후)**

---

## STATUS

### 완료
- Animation pipeline 조사
- VFX pipeline 조사
- Audio pipeline 조사
- 제작 도구 조사 (1인 개발 현실성)
- Placeholder 기준 정리
- P0~P3 분류
- 최소 생산 단위 정의
- 문서 저장: 본 파일

### 현재 기준 (고정)
| 항목 | 상태 |
|------|------|
| VS Candidate A: Seth Boss Arena | APPROVED |
| Minimum Production Spec | APPROVED |
| T1 Level Blockout | IMPLEMENTED / UNVERIFIED |
| T2~T9 | BLOCKED (T1 VERIFIED 전) |
| Animation / VFX / Audio | NEW (실에셋 없음) |
| ORD-GRUNT | HOLD |
| Input fallback | IMPLEMENTED / UNVERIFIED |

### 미확인
- 실제 제작 도구 설치 상태 (Blender 버전, Niagara 숙련도 등)
- 실제 Asset 확보/생성 가능 여부 (로컬 환경)
- UE Editor에서의 적용·검증 결과
- Skeleton / Retarget 대상 존재 여부 (현재 메카 3D 메쉬도 NOT STARTED)

### BLOCKED
- T1 VERIFIED 전 실제 VS 구현 (T2~T9)
- 본 파이프라인에 따른 실제 Asset 제작 착수 (Master 승인 필요)

### Master 결정 필요
- 제작 도구 선택 (Blender 중심 vs UE 내장 우선)
- 실제 Asset 제작 착수 범위 (P0만 / P0+P1)
- Placeholder 품질 세부 허용 수준

---

## 근거 문서 (읽기 전용)

- state/SETH_BOSS_ARENA_MINIMUM_PRODUCTION_SPEC.md
- state/SETH_BOSS_ARENA_PRODUCTION_TASK_BREAKDOWN.md
- state/SETH_BOSS_ARENA_PRODUCTION_READINESS_REVIEW.md
- state/T1_SETH_ARENA_BLOCKOUT_STATUS.md
- state/MESHY_BLENDER_PIPELINE_SPEC.md
- state/DEVELOPMENT_STATE_BASELINE_2026-08-15.md
- state/CURRENT_STATE.md / VERTICAL_SLICE_CANDIDATE_REVIEW.md

---

## 1. Animation

### 1.1 현재 Git 상태

| 항목 | 상태 |
|------|------|
| Content 내 AnimSequence / AnimBP | 없음 |
| assets/animations/ | .gitkeep 수준 (실에셋 없음) |
| 메카 3D 메쉬 / Skeleton | NOT STARTED (Meshy→Blender 파이프라인 문서만) |
| 분류 | **NEW** |

### 1.2 AXION 최소 Animation 목록

| 클립 | 목적 | 분류 | 필수 여부 | 비고 |
|------|------|------|----------|------|
| Idle | 대기 자세 | NEW | P0 | 루프 |
| Locomotion (Walk/Run) | 이동 | NEW | P0 | 루프 · 방향 블렌드 최소 |
| Attack (1~2타) | 근접 공격 | NEW | P0 | 논루프 |
| Dash | 대시 | NEW | P0 | 짧은 클립 또는 포즈 |
| Hit | 피격 | NEW | P0 | 짧은 반응 |
| Death | 사망 | NEW | P1 | 종료 연출 |
| Special / 필살 | S-Core 등 | NEW | P2 | VS 최소에서 후순위 가능 |

### 1.3 SETH 최소 Animation 목록

| 클립 | 목적 | 분류 | 필수 여부 | 비고 |
|------|------|------|----------|------|
| Idle / Phase1 자세 | 대기 · Phase1 | NEW | P0 | |
| Phase2 자세 | Phase 전환 후 | NEW | P0 | |
| Attack Pattern 01 (Area Blast) 텔레그래프 | 경고 + 공격 | NEW | P0 | |
| Attack Pattern 02 (Beam) 텔레그래프 | Phase2 빔 | NEW | P0 | |
| Hit | 피격 | NEW | P0 | |
| Death | 사망/종료 | NEW | P0 | |

### 1.4 제작·적용 파이프라인 (현실성)

**전제:** 현재 최종 메카 메쉬/리그가 없으므로, Animation 단독 제작은 Skeleton이 있어야 의미가 있다.

| 단계 | 현실적 방법 | 비고 |
|------|-------------|------|
| Skeleton 확보 | Meshy → Blender 리그 (MESHY_BLENDER_PIPELINE_SPEC) 또는 UE Mannequin 임시 리타겟 | 임시 Mannequin 사용 시 최종 메카 교체 시 재작업 발생 |
| 모션 제작 | Blender Action / NLA · 조립식 포즈 재사용 권장 | **모든 모션 수작업 완전 제작은 1인 개발에서 비현실적** |
| 대안 | UE Control Rig · Pose Asset · 기존 UE 템플릿 리타겟 | 빠른 Placeholder용 |
| Export | FBX (Deform 본만 · Bake) | MESHY_BLENDER_PIPELINE_SPEC §7 |
| UE Import | Skeletal Mesh + AnimSequence | Skeleton 공유 목표 |
| 검증 | PIE에서 상태 전환 시 시각 피드백 | T4 검증 기준 |

**권장 현실 경로 (1인):**
1. VS용 **임시 Skeleton** (Mannequin 또는 단순 메카 리그) 확정
2. Idle / Locomotion / Attack / Hit / Death **최소 세트만** Blender 또는 UE에서 제작
3. 최종 AXION/SETH 메쉬 완성 후 Retarget
4. 수작업 풀퀄 애니 대량 제작 금지

### 1.5 EXISTING / REUSE / NEW / UNKNOWN

| 구분 | 내용 |
|------|------|
| EXISTING | 없음 |
| REUSE | 없음 (시스템 로직만 재사용) |
| NEW | 위 AXION/SETH 전 클립 |
| UNKNOWN | 실제 Skeleton 존재 시점 · Retarget 비용 · Placeholder 포즈 허용 품질 |

---

## 2. VFX

### 2.1 현재 Git 상태

| 항목 | 상태 |
|------|------|
| Content 내 Niagara / Particle | 없음 |
| assets/vfx/ | .gitkeep 수준 |
| 분류 | **NEW** |

### 2.2 Seth Arena 최소 VFX 목록

| 효과 | 목적 | 필수 | Placeholder | 분류 |
|------|------|------|-------------|------|
| 타격 (AXION Attack) | 공격 피드백 | P0 | 허용 | NEW |
| 피격 (AXION / SETH Hit) | 피격 식별 | P0 | 허용 | NEW |
| 대시 잔상/트레일 | Dash 식별 | P1 | 허용 | NEW |
| Pattern Warning (영역/빔 예고) | 보스 공격 예고 | P0 | 허용 | NEW |
| Area Blast / Beam | 보스 공격 본체 | P0 | 허용 | NEW |
| 사망/종료 | 전투 종료 연출 | P1 | 허용 | NEW |
| 환경 파괴 / 대규모 | — | NOT REQUIRED | — | — |

### 2.3 제작 파이프라인 (현실성)

| 방법 | 적합성 | 비고 |
|------|--------|------|
| UE Niagara (내장) | **가장 현실적** | 외부 도구 불필요 · Placeholder 빠른 제작 |
| 기존 UE 이펙트 재사용/변형 | 권장 | Starter Content 등 |
| 외부 제작 후 Import | 비권장 (VS 단계) | 비용 대비 이득 낮음 |

**권장:** Niagara로 P0 이펙트만 최소 구성. 고퀄 폴리시 금지.

---

## 3. Audio

### 3.1 현재 Git 상태

| 항목 | 상태 |
|------|------|
| Content 내 Sound Wave / Cue | 없음 |
| assets/audio | README 수준 |
| 분류 | **NEW** |

### 3.2 최소 Audio 목록

| 사운드 | 목적 | 필수 | Placeholder | 분류 |
|--------|------|------|-------------|------|
| 타격 SFX | 공격 피드백 | P0 | 허용 (무음 명시 가능) | NEW |
| 피격 SFX | 피격 피드백 | P0 | 허용 | NEW |
| 대시 SFX | Dash | P1 | 허용 | NEW |
| Pattern Warning | 보스 예고 | P0 | 허용 | NEW |
| Blast / Beam | 보스 공격 | P0 | 허용 | NEW |
| Death | 종료 | P1 | 허용 | NEW |
| UI feedback | HUD/결과 | P2 | 허용 | NEW |
| BGM | 전투 분위기 | P3 | 선택 | NEW |
| Arena ambience | 환경 | P3 | 선택 | NEW |
| 보이스 (카이/세스) | 연출 | OPTIONAL | 허용 | NEW |

### 3.3 제작 파이프라인 (현실성)

| 방법 | 적합성 | 비고 |
|------|--------|------|
| 무료/기존 SFX 라이브러리 + UE Sound | **가장 현실적** | 생성 도구보다 재사용·편집 |
| 간단 합성 / 편집 (Audacity 등) | 가능 | |
| 풀 BGM·보이스 제작 | VS 단계 비권장 | P3 / OPTIONAL |

**권장:** P0 SFX만 확보. 의도적 무음 Placeholder도 Master 승인 하에 허용 (검증 시 명시).

---

## 4. 제작 도구 종합 판단 (1인 개발)

| 영역 | 가장 현실적인 방법 | 이유 |
|------|---------------------|------|
| Animation | Blender (포즈/짧은 클립) + UE Control Rig / 임시 Mannequin | 풀수작업 회피 · MESHY_BLENDER_PIPELINE_SPEC과 정합 |
| VFX | UE Niagara | 외부 의존 최소 · Placeholder 빠름 |
| Audio | 기존 SFX 라이브러리 + UE | 제작 비용 최저 |
| 메쉬/리그 (선행) | Meshy → Blender (기존 Spec) | 문서화됨 · 최종 교체 전제 |

**피해야 할 것**
- Blender에서 모든 모션을 처음부터 수작업으로 만드는 방향
- VS 단계에서 고퀄 VFX/Audio/BGM 필수화
- 핵심 메카 외형을 Placeholder로 대체하여 Canon 충돌

---

## 5. 최소 생산 단위 (형식)

### ASSET: AXION Idle
- 목적: 대기 시각 피드백
- 최소 요구사항: 루프 가능 포즈 또는 짧은 사이클
- 제작 방법: Blender Pose / UE Control Rig
- 외부 도구: Blender (선택)
- Unreal 적용: AnimSequence → AnimBP 또는 직접 재생
- 검증 방법: PIE Idle 상태 확인
- Placeholder 가능: 예
- 위험: Skeleton 미정 시 재작업

### ASSET: AXION Attack (1타)
- 목적: 근접 공격 식별
- 최소 요구사항: 스윙 또는 타격 포즈 + 타이밍
- 제작 방법: Blender 짧은 클립 또는 UE
- 외부 도구: Blender (선택)
- Unreal 적용: AnimSequence + Notify(히트 타이밍)
- 검증 방법: 공격 입력 시 재생 + 데미지 연동
- Placeholder 가능: 예
- 위험: 타이밍과 CombatComponent 불일치

### ASSET: SETH Pattern Warning + Attack
- 목적: 보스 공격 예고·본체 시각화
- 최소 요구사항: 텔레그래프 포즈/이펙트 + 공격 모션
- 제작 방법: Anim + Niagara 병행
- 외부 도구: 선택
- Unreal 적용: Boss 로직 이벤트에 바인딩
- 검증 방법: Pattern 발동 시 식별 가능
- Placeholder 가능: 예
- 위험: 공간 크기와 패턴 범위 불일치 (T3 이슈)

### ASSET: Hit / Death (공통)
- 목적: 피격·종료 피드백
- 최소 요구사항: 짧은 반응 + 사망 포즈
- 제작 방법: 동일
- Placeholder 가능: 예
- 위험: 과다 제작

### ASSET: P0 VFX (타격/피격/Warning/Blast)
- 목적: 전투 식별
- 최소 요구사항: 단순 파티클/디캘
- 제작 방법: Niagara
- 외부 도구: 없음
- Unreal 적용: 이벤트 스폰
- 검증 방법: 발동 확인
- Placeholder 가능: 예
- 위험: 폴리시 과다

### ASSET: P0 SFX (타격/피격/Warning)
- 목적: 청각 피드백
- 최소 요구사항: 짧은 원샷
- 제작 방법: 라이브러리 또는 무음 Placeholder
- Unreal 적용: Sound Cue / Play Sound
- 검증 방법: 재생 또는 의도적 무음 명시
- Placeholder 가능: 예
- 위험: 보이스/BGM 범위 확대

---

## 6. Placeholder 정책 (재확인)

| 영역 | Placeholder | 조건 |
|------|-------------|------|
| Level 구조 / 환경 Mesh | 허용 | T1 기준 |
| VFX | 허용 | Gameplay 식별만 |
| Audio | 허용 | 무음 명시 가능 |
| Animation | **조건부 허용** | 포즈/단순 사이클 · 최종 퀄리티 요구 금지 |
| AXION/SETH 핵심 외형 | **금지** | Canon/최종 디자인 대체 금지 |
| UI | 허용 | |

원칙:
- Gameplay 검증용 Placeholder 허용
- Placeholder를 최종 Asset으로 간주하지 않음
- 핵심 메카 외형·Canon 변경 금지

---

## 7. 생산 우선순위 (P0~P3)

| 우선순위 | 내용 | 비고 |
|----------|------|------|
| **P0** | Gameplay 검증 필수 · Idle/Locomotion/Attack/Hit · SETH Phase/Attack/Hit · 타격·피격·Warning VFX · 타격·피격·Warning SFX | T4/T5/T6 최소 |
| **P1** | VS 완성에 필요 · Death Anim/VFX/SFX · Dash 시각/청각 | T8 전 권장 |
| **P2** | Presentation 개선 · Special Anim · UI SFX · Camera polish | T7 이후 |
| **P3** | Polish · BGM · Ambience · 고퀄 VFX | VS 범위 밖 가능 |

**현재 T1/T2가 막혀 있으므로 실제 제작 순서는 확정하지 않는다.**
T1 VERIFIED → T2/T3 안정화 후 P0 Animation/VFX/Audio 착수를 권장.

---

## 종합 요약

```text
시스템 (P5-4)     → REUSE 가능
AXION/SETH 로직  → REUSE 가능
Level Blockout   → T1 UNVERIFIED
Animation        → NEW (전부)
VFX              → NEW (전부)
Audio            → NEW (전부)
메쉬/리그        → NOT STARTED (선행 병목 가능)
```

콘텐츠 생산이 현재 병목이다.
Animation은 Skeleton/메쉬 선행이 필요하므로, 임시 Skeleton 전략을 Master가 결정해야 한다.
VFX/Audio는 UE 내장으로 P0만 빠르게 채울 수 있다.

---

## 변경하지 않은 것

- Canon
- Novel
- Unreal C++ / Blueprint
- Asset (실파일)
- Animation / VFX / Audio
- Input
- ORD-GRUNT
- Level 바이너리

---

## NEXT

다음 작업:
- T1 실기 검증 가능 시 T1 VERIFIED
- 이후 T2 착수 승인
- Asset pipeline은 **승인된 범위(P0 중심)** 에서만 제작

선행 조건:
- T1 VERIFIED
- Master의 제작 도구/범위 결정
- (Animation의 경우) 임시 Skeleton 또는 메쉬 확보 전략

검증 필요:
- 선정된 VS의 실제 PIE 검증
- 제작된 Placeholder/실에셋의 상태 전환 피드백

**본 문서는 파이프라인 조사·최소 단위 정의만 수행한다. 구현·Asset 생성 지시가 아니다.**
