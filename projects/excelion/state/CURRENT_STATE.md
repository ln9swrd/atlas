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
- **Phase U2-E — Attack → Feedback C++ Bridge Invocation 연동 완료 (2026-08-14)** — `CombatComponent::PerformHitDetection()` 내 타깃 HitConfirm 시점에 `GetWorld()->GetSubsystem<UExcelionFeedbackSubsystem>()` 직접 접근 및 `BroadcastHitImpact()` 호출 C++ 브릿지 연동 검증 통과 (Broadcast 호출까지 증명, 실제 HitStop/CameraShake 최종 체감 효과는 미검증으로 분리) (`U2-E ATTACK -> FEEDBACK BRIDGE INVOCATION — VERIFIED`)

## Next

1. **U2-F Attack $\rightarrow$ Heat 연동 기획/규칙 Master 결정 대기**:
   - 근접 메인 공격 시 Heat 부과 여부 및 `HeatCost` 차감 타이밍(시도 vs 히트) 기획 결정 후 진행
2. **Phase 4-A — U3 Enemy / Boss Combat Integration (HOLD)**
3. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (U1 Player Proof & U2 Combat Core & P0 Runtime Binding & U2-E Bridge Invocation 통과 완료)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: Phase U2-E — Attack $\rightarrow$ Feedback C++ Bridge Invocation & Pre-Commit Audit
  - **현재 상태**: Bridge Invocation VERIFIED (Build, C++ Direct Access, Null Guard, Broadcast HitImpact Invocation Passed; Final HitStop/Shake unverified)
  - **완료**:
    - `CombatComponent::PerformHitDetection()` hit-confirm 지점에 C++ `UExcelionFeedbackSubsystem` 직접 호출 및 `BroadcastHitImpact` 연동 (테스트 전용 중복 `ECC_Pawn` 방어 코드 제거 정돈 완료)
    - `run_u2_extended_proof.py` 구동으로 언리얼 5.4.4 실기 환경에서 `[U2-E-C PASS]` (Invocation Verified) 및 U2-A~D, U2-F/G Regression 유지 확인
  - **변경 파일**: `CombatComponent.h`, `CombatComponent.cpp`, `run_u2_extended_proof.py`, `projects/excelion/state/CURRENT_STATE.md`
  - **다음 작업**: Master 커밋 승인 및 U2-F Heat 연동 규칙 결정 대기
  - **재개 조건**: Master 지시 시
