# CURRENT_STATE — excelion

> Updated: 2026-08-12 · ORD-GRUNT DECISION C (HOLD) · G1/G2 SoR wording

## ACTIVE_TARGET

**ORD-GRUNT DECISION: C (HOLD)** · 텍스트 실루엣 3안 산출 완료 · shortlist SWARM COLUMN · 후속 제품 착수 없음

## Done

- EP1–24 본문 · M0–M4
- Phase A: NOVEL_CANON · EPISODE_MATRIX
- PHASE12_TUNING · Forge 활성 경로 제거 · Pipeline Spec (문서)
- **1차 플레이테스트** (EP1·6·8) + **P1–P3 CLOSED**
  - P1 Kai seed H1「콜.」 · PR #53
  - P3 Ashur→Nemesis · PR #54
  - P2 EP8 Result UI Spec · PR #55 (`8d9dbc2f…`)

- **Git Unreal prep (2026-08-12)**
  - PR #101 MERGED — `game/Excelion/.gitignore` (생성물 보호)
  - PR #102 MERGED — EngineAssociation `"5.3"` → `"5.4"` (실기 검증 대상 UE 5.4.4)
  - UE Generate/Build/Editor 실기 = 여전히 HOLD (개발 PC)

## Next

1. **ORD-GRUNT** 텍스트 실루엣 3안 **Done** · shortlist **SWARM COLUMN** · **DECISION C = HOLD** (LOCK·흑실루엣·삼면도·Meshy/UE 미착수) — `DESIGN_GATE` · `NEXT_STAGE_DECISION`
2. (ops) SoR 잔여 정합 확인
3. (선택) 레거시 콘티/애니 잔존 점검 — 캐논 변경 없음

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | HOLD |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle** = 제품 Next와 분리 · ops 대기 의미만 (현재 ACTIVE_TARGET이 제품 Next를 가리킴)
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트
