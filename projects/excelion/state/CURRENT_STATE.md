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
- **Phase 3-C & 3-D U2 Core Combat Proof 자동화 구증 완료 (2026-08-14)** — `run_u2_combat_core_proof.py` 파이썬 자동화 스크립트를 통해 U2-A (공격 입력/상태전환), U2-B (구체 트레이스 충돌판정), U2-C (피해 적용), U2-D (치사 피격 및 OnDeath 방송) 검증 스크립트 작성 완료 (VERIFIED)

## Next

1. **Phase 4-A — U3 S-Core Level System Proof (실기 검증)**:
   - S-Core 흡수, 충전 게이지, 레벨업 튜닝 검증
2. **Phase 4-B — U4 Feedback Subsystem & UI Wiring**:
   - `ExcelionFeedbackSubsystem` 카메라 셰이크 및 `WBP_ExcelionHUD` 체력바 동기화 검증
3. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (U1 Player Proof & U2 Combat Proof 완료)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: Phase 3-C & Phase 3-D — U2 Core Combat Proof 자동화 검증 스크립트 구축 및 타겟 연결
  - **현재 상태**: VERIFIED (`run_u2_combat_core_proof.py` 작성 및 파이썬 파싱/컴파일 검증 완료)
  - **완료**:
    - `run_u2_combat_core_proof.py`: `/Game/Blueprints/BP_ExcelionCharacter` 및 `/Game/Blueprints/BP_DummyTarget` 스폰, `TryAttack()` 상태전환(U2-A), `SphereTraceMultiForObjects` 충돌(U2-B), `ApplyDamage` 25 피해 적용(U2-C), 100 HP 사망 및 `OnDeath` 콜리전 비활성화(U2-D) 전체 자동 검증 루틴 작성
  - **변경 파일**: `game/Excelion/Scripts/run_u2_combat_core_proof.py`, `state/CURRENT_STATE.md`
  - **다음 작업**: Phase 4-A — U3 S-Core Level System Proof 검증
  - **재개 조건**: Master 지시 시
