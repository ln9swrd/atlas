# Excelion 프로젝트 요약

> 2026-08-09 · playable-docs v1  
> 기준: `projects/excelion/` SoR · combat prototype · midboss rework

---

## 1. 프로젝트 정체성

| 항목 | 내용 |
|------|------|
| **장르** | Mission-Based 3D Action (메카) |
| **핵심 플레이** | 미션 공성/수성/섬멸 · 보스전 · 회피·딜·패턴 학습 |
| **서사** | 소년만화 · 열혈+광기 · 리아(16) 주인공 · S1 24화 목표 |
| **차별점** | 중간보스 = 재교육(학습→왜곡→붕괴) · 최종 **네메시스** · 이집트 신화 보스 로스터 |
| **위치** | Atlas 하위 제품 SoR · Unreal + Blender |

---

## 2. 현재 구현 상태

| 영역 | 상태 |
|------|------|
| **전투** | 문서·실행 명세 완료 (PR 계열) · **런타임 프로토타입 없음** |
| **스토리** | S1 골격·novel·보스맵 존재 · 텍스트 SoR |
| **시스템** | COMBAT_LOOP · Phase · 피드백 정의 · 코드 미구현 |
| **비주얼** | 스펙·3톤 규칙 · **모델링 자산 부재** → 플레이 불가 |
| **파이프라인** | **활성** Meshy → Blender → FBX → UE · ParaModel/시각화 = **HOLD** · excelion-forge = DEPRECATION CANDIDATE |

---

## 3. 존재하는 시스템 (문서)

| 시스템 | 위치 | 요약 |
|--------|------|------|
| **COMBAT_LOOP** | `design/combat/COMBAT_LOOP.md` | 탐색→학습→왜곡→붕괴→재도전 |
| **PATTERN** | `PATTERN_EXECUTION_SPEC.md` | 몬투/세스/아누비스 실행 단위 |
| **ANUBIS** | `ANUBIS_PHASE` · `ANUBIS_MECHANICS` | 인지 교란 · 이해 가능 난이도 |
| **FEEDBACK** | `FEEDBACK_SYSTEM.md` | 타격·회피·위험 3단·실패 원인 |
| **Midboss** | `MIDBOSS_DESIGN` · `MIDBOSS_PHASE_DETAIL` | 재교육 · 시간+트리거 Phase |
| **수치** | `design/combat/BOSS_STATS.md` | 1차 고정 · 실기 전 |

---

## 4. 빠진 요소 (핵심)

| 요소 | 상태 | 영향 |
|------|------|------|
| 플레이어 기체 (실물 메시) | 없음 | 조작 불가 |
| 적/보스 기체 메시 | 없음 | 전투 불가 |
| 애니메이션 | 없음 | 타이밍 검증 불가 |
| 인게임 UI | 최소 스펙만 | HUD 미구현 |
| 레벨/스테이지 메시 | 문서만 | 공간 압축 등 미검증 |
| 런타임 빌드 | 없음 | **플레이 불가** |

**핵심 병목:** 모델링·플레이스홀더 자산 부재.

---

## 5. 해결 방향 (고정)

```
더미 자산 → 플레이 가능 → 이후 고퀄 교체
```

고퀄 선행 금지 · 3톤·실루엣 우선 (`ASSET_GUIDELINE` · `PLAYABLE_SCOPE_V1`).

---

## 6. 관련 문서

- `docs/COMBAT_SYSTEM.md`
- `docs/PLAYABLE_SCOPE_V1.md`
- `docs/IMPLEMENTATION_QUEUE.md`
- `docs/ASSET_GUIDELINE.md`
- `docs/PROJECT_RELATION.md`
- `state/MESHY_BLENDER_PIPELINE_SPEC.md`
