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
- **U2-E~G Read-Only Execution Proof 실기 실행 완료 (2026-08-14)** — `run_u2_extended_proof.py` 구동으로 C++ 단독 API/컴포넌트 검증 수행:
  - `U2-E Feedback API`: Subsystem C++ 등록 PASS (`U2-E-A`), 파이썬 리플렉션 취득 FAIL (`U2-E-B`, UCLASS BlueprintType 미지정), Attack Bridge GAP (`U2-E-C`)
  - `U2-F Heat Component`: 축적(`U2-F-A`), Clamp(`U2-F-B`), 오버히트(`U2-F-C`), 15.0 Heat units/s 방열(`U2-F-D`) 4개 전 항목 PASS (`VERIFIED`), Attack Bridge GAP
  - `U2-G S-Core Core`: 패시브 충전률 5.0/s (`U2-G-A`), Clamp(`U2-G-B`), 소비 성공 100->60 (`U2-G-C`), 잔량 부족 실패 및 보존 (`U2-G-D`) 4개 전 항목 PASS (`VERIFIED`), Skill Bridge GAP

## Next

1. **U2-E/F/G Gameplay Bridge C++ 연동 준비 (Master 승인 대기)**:
   - Attack $\rightarrow$ Feedback, Attack $\rightarrow$ Heat, Skill $\rightarrow$ S-Core 연동 설계 및 승인 대기
2. **Phase 4-A — U3 Enemy / Boss Combat Integration (HOLD)**
3. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (U1 Player Proof & U2 Combat Core & U2-F/G Component Proof 통과 완료)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: U2-E~G Read-Only Execution Proof (Feedback API, Heat Component, S-Core Core)
  - **현재 상태**: Core/API Proof VERIFIED (Gameplay Bridges remain GAP)
  - **완료**:
    - `run_u2_extended_proof.py` 파이프라인 무수정 하네스 구축 및 언리얼 5.4.4 실기 커맨드렛 구동 완료:
      - **U2-E Feedback**: Subsystem Class C++ 등록 PASS (`U2-E-A`), 파이썬 리플렉션 FAIL (`U2-E-B`, BlueprintType 미지정), Attack Bridge GAP (`U2-E-C`)
      - **U2-F Heat Component**: F-A~F-D 4개 전 항목 PASS (Accumulation 50.0, Clamp 100.0, Overheat=True, Rate 15.0 Heat units/s), Attack Bridge GAP
      - **U2-G S-Core Core**: G-A~G-D 4개 전 항목 PASS (ChargeRate 5.0/s, Clamp 100.0, Consume 100->60, Insufficient Fail 60 Retention), Skill Bridge GAP
  - **변경 파일**: `game/Excelion/Scripts/run_u2_extended_proof.py`, `game/Excelion/Saved/Logs/Excelion.log`, `state/CURRENT_STATE.md`
  - **다음 작업**: Master 승인 대기
  - **재개 조건**: Master 지시 시
