# ASSET_REGISTER — Excelion

> 2026-08-10 · 확정된 에셋만 기록 · 임의 추가 금지  
> 원천: MECHA_MASTER_LIST · BRAVE_FINAL_SPEC · weapon/* · VERTICAL_SLICE

**상태: 초안 · VS 우선**

범례: 제작 상태 = Concept / Spec / Mesh / Rig / Anim / InUE  
Unreal 적용 = None / Placeholder / Partial / Done

---

## PLAYER MECHA

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| BRAVE | Player | 주인공기 | S | Spec FINAL | None | 삼면도 PNG HOLD · 리그 | 25m · 여성 비례 슈퍼로봇 |
| EXCELION | Player 진화 | EP13+ | S | Spec | None | BRAVE 골격 공유 | 동일 골격 1단계 |

---

## ENEMY MECHA

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| ORD-GRUNT | 양산 | 잡몹 | A | DESC | None | 실루엣 3안 진행 중 | VS 1순위 후보 |
| ORD-GUN | 양산 | 원거리 | B | DESC | None | | |
| ORD-HEAVY | 양산 | 중형 | B | DESC | None | | |

---

## BOSS

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| 세스 (COLOSSUS) | Boss | EP6 | A | Spec 이관 | None | | VS 후보 |
| 몬투 (HEKATON) | Boss | EP5 | B | DESC | None | | |
| 네메시스 | Boss | EP9/23–24 | S | FINAL_SPEC | None | | 다페이즈 |
| 크레일 (세크) | Boss | EP15 | A | FINAL_SPEC | None | | 1회만 |
| 아이기스 (와제) | Boss | EP21 | A | FINAL_SPEC | None | | |

(기타 로스터: MECHA_MASTER_LIST 참조 · VS에 불필요하면 여기 미기입)

---

## WEAPON

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| brave-blade | Melee | 근접 | S | DESC | None | | |
| brave-cannon | Ranged | 중거리 | S | DESC | None | | |
| brave-drone | Aux | 보조 | A | DESC | None | | |

---

## ANIMATION

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| player_brave 기본 세트 | Anim | Idle/Move/Dash/Attack/Hit/Down/Special | S | 기획 | None | 리그 · fps TBD | 1차 10클립 목표 참고 |

---

## ENVIRONMENT

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| VS 전투 지역 1 | Level | 데모 맵 | S | 무드 문서 | None | | 단일 레벨 목표 |

---

## VFX

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| Hit / Special / Warn / Core | Niagara | 피드백 | S | 가이드 | None | | VFX_GUIDELINE |

---

## AUDIO

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| Hit / Dash / Special / Warn | SFX | 피드백 | S | 미착수 | None | | 최소 세트 |

---

## UI

| 이름 | 종류 | 용도 | 우선순위 | 제작 상태 | Unreal | 선행 작업 | 비고 |
|------|------|------|----------|-----------|--------|-----------|------|
| HUD | UMG | HP·S-Core·Heat·락온 | S | UI_MIN 참고 | None | | |
| Result | UMG | 클리어/실패 | A | EP8 Result Spec | None | | |

---

## 갱신 규칙

- 확정된 이름·역할만 추가
- 상태 변경 시 본 표와 Git 동시 갱신
