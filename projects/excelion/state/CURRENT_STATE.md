# CURRENT_STATE — excelion

> Updated: 2026-08-13 · role + ORD-GRUNT HOLD 명시 · SOT_MAP 연결  
> **역할 (제품):** Excelion **실제 작업 상태** (Done / Next / HOLD).  
> 플랫폼 라우팅은 Atlas `state/CURRENT_STATE.md`만 담당. 중복 상세 금지.  
> **경계 지도:** [`SOT_MAP.md`](SOT_MAP.md)

## ACTIVE_TARGET

**ORD-GRUNT DECISION: C (HOLD)** · 텍스트 실루엣 3안 산출 완료 · shortlist SWARM COLUMN · 후속 제품 착수 없음

### HOLD 의미 (ORD-GRUNT)

- AI가 LOCK / 흑실루엣 / 삼면도 / Meshy / UE 구현을 **자율 시작하지 않는다**
- 재개: 재개 조건 충족 **또는** Master 명시 지시 시에만
- 관련: `DESIGN_GATE` · `NEXT_STAGE_DECISION` · DECISION C

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

- **Ops (2026-08-13)** — SOT_MAP · AGENTS 수정권한/Handoff 규칙 추가 (정본 본문 변경 없음)
- **Unreal C++ & Script Prep (2026-08-14)** — Master 승인으로 `USCoreComponent`, `MadnessComponent`, `ExcelionCharacter`, `ExcelionMechaDataAsset`, `ExcelionHUDWidget`, `ExcelionFeedbackSubsystem` C++ 생성, `build_cli.ps1`, `import_assets_automation.py` 생성 완료
- **Unreal 5.4 C++ 빌드 성공 및 실기 검증 완료 (2026-08-14)** — `build_cli.ps1` UHT 및 MSVC C++ 17개 액션 컴파일 성공 (VERIFIED)
- **U1 Player Proof Enhanced Input 에셋 생성 & CDO 연결 완료 (2026-08-14)** — `create_input_assets_automation.py`로 `/Game/Input/` 에셋 5종 생성 및 `BP_ExcelionCharacter` CDO 속성 바인딩 완료 (VERIFIED)
- **U1-A~C & U1-C1~C6 실기 언리얼 로그 검증 완전 통과 (2026-08-14)** — `run_pie_automation_proof.py` 언리얼 5.4 실기 실행 결과 9개 전 항목 PASS 확인 (`U1 PLAYER PROOF — VERIFIED`)
- **Phase 3-B Minimal BP_DummyTarget 구축 완료 (2026-08-14)** — 순수 C++ `AExcelionDummyTarget` 상속 및 `BP_DummyTarget.uasset` 생성/저장 확인 (`MaxHealth = 100.f`, `CapsuleCollision=Pawn`, `FallbackCube`) (VERIFIED)
- **Phase 3-C & 3-D U2 Core Combat Proof 언리얼 5.4 실기 실행 완전 통과 (2026-08-14)** — `run_u2_combat_core_proof.py` 언리얼 5.4 에디터 실기 실행 결과 `Excelion.log`에 `[U2-A PASS]`, `[U2-B PASS]`, `[U2-C PASS]`, `[U2-D PASS]` 전 항목 100% 성공 검증 확인 (`U2 CORE COMBAT PROOF — VERIFIED`)
- **Phase U2-E — Attack → Feedback Bridge Invocation VERIFIED (2026-08-14)** — `CombatComponent::PerformHitDetection()` 내 타깃 HitConfirm 시점에 `BroadcastHitImpact()` 호출까지 검증 완료 (실제 HitStop/CameraShake의 최종 체감 효과는 미검증으로 분리)
- **Phase U2-H Physical GUI Input Proof complete (2026-08-15)** — UE 5.4.4 GUI PIE 실기에서 W, S, A, D, Mouse, LMB, SpaceBar 7개 물리 입력 전 항목 100% 정상 작동 확인 (`U2-H PHYSICAL GUI INPUT — VERIFIED`)
- **Phase U3-0 Enemy Asset Audit complete (2026-08-15)** — `BP_ExcelionEnemy`, `BP_PowerEnemy`, `BP_SpeedEnemy`, `BP_SethBoss` .uasset 디스크 실제 존재 및 C++ 부모 클래스 바인딩 100% 확인 (`U3-1 에셋 생성 생략 확정`)
- **Phase U3-2a-DIAG Read-Only Audit complete (2026-08-15)** — Headless Commandlet 환경적 제약 규명, C++ `AExcelionEnemy::FindPlayer()` 런타임 코드 결함 없음 확인 (`C++ CODE FREEZE 유지`)
- **Phase U3-2a Enemy Spawn & Chase Physical Proof complete (2026-08-15)** — UE 5.4.4 GUI PIE 실기에서 Enemy Spawn, Player Recognition (`DetectionRange=1500.f`), `Idle` $\rightarrow$ `Chase` 상태 전환 및 플레이어 방향 실제 물리 이동(`MoveSpeed=400.f`) 4/4 전 항목 100% 검증 확인 (`U3-2a ENEMY CHASE PROOF — VERIFIED`)
- **Phase U3-2b Enemy Attack & Player Damage/Death Integration Proof complete (2026-08-15)** — `run_u3b_enemy_combat_proof.py` 언리얼 5.4 실기 검증 결과, 적 근접 배치 후 `UHealthComponent` 데미지 적용(100.f $\rightarrow$ 85.f), 치명타 차감으로 인한 플레이어 `OnDeath` 입력/이동 차단 및 적 AI `Idle` 복귀 6개 전 항목 PASS 확인 (`U3-2b COMBAT INTEGRATION — VERIFIED`)

## Next

1. **Phase 4-A — U3 Enemy / Boss Combat Integration 완료 검토**:
   - U3 Mass-Production Enemy (`BP_ExcelionEnemy`) Chase & Combat Integration 전 항목 VERIFIED 승격 완료
   - 보스(`ASethBoss` / `BP_SethBoss`) Multi-Phase 시스템 검증 또는 ORD-GRUNT 후속 기획 Master 지시 대기
2. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (U1 Player Proof & U2 Combat Core & P0 Runtime Binding & U2-E Bridge & U2-H Physical Input & U3-2a Enemy Chase & U3-2b Enemy Combat 통과 완료)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-15)**:
  - **작업명**: Phase U3 Mass-Production Enemy Combat Integration
  - **현재 상태**: U3-2a VERIFIED / U3-2b VERIFIED / Phase U3 Enemy Combat 100% VERIFIED
  - **완료**:
    - U2-H Physical GUI Input (VERIFIED - 7/7 Pass)
    - U3-0 Enemy Asset Existence Audit (VERIFIED - 4/4 .uasset Exists)
    - U3-2a-DIAG Read-Only Audit (VERIFIED - Game Code Clean)
    - U3-2a Enemy Spawn & Chase Physical Proof (VERIFIED - 4/4 Pass)
    - U3-2b Enemy Attack & Player Damage/Death Integration Proof (VERIFIED - 6/6 Pass)
  - **미완료**: 없음 (U3 Mass-Production Enemy Combat Integration 완료)
  - **변경 파일**: `projects/excelion/state/CURRENT_STATE.md` (상태 갱신)
  - **다음 작업**: 보스(`ASethBoss` / `BP_SethBoss`) 검증 또는 후속 단계 개발 지시 대기 (Master 지시 수신 시)
  - **재개 조건**: Master의 후속 단계 개발 지시 전달 시






