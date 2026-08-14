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

## Next

1. **Phase 3 — U2 Combat Proof Audit**:
   - `UCombatComponent` (TryAttack, Hitbox, AttackDamage = 25.0) C++ 및 블루프린트 연결성 검증
   - `BP_SethBoss`, `BP_ExcelionEnemy` 파생 BP와 대미지 전파 연동 테스트
2. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (U1 Player Proof 실기 검증 완료)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: U1 Player Proof (Phase 1 에셋 연결 & Phase 2 월드 스폰/기능 검증) 100% 완료
  - **현재 상태**: VERIFIED (언리얼 5.4 에디터 실기 로그 증거 9개 항 PASS 확보)
  - **완료**:
    - `run_pie_automation_proof.py` 언리얼 5.4 실기 로그 검증 9개 전 항목 PASS:
      - `[U1-A PASS]` `BP_ExcelionCharacter_C` 상속 및 CDO 확인
      - `[U1-B PASS]` Enhanced Input 에셋 5종 CDO 속성 바인딩 확인
      - `[U1-C PASS]` `BP_ExcelionGameMode.DefaultPawnClass = BP_ExcelionCharacter_C` 바인딩 확인
      - `[PIE-C1 PASS]` 월드 폰 액터 정상 스폰 확인
      - `[PIE-C2 PASS]` Fallback Visual Mesh (`Cube`) 렌더링 확인
      - `[PIE-C3 PASS]` CharacterMovementComponent 활성화 (`MaxWalkSpeed = 600.0 uu/s`) 확인
      - `[PIE-C4 PASS]` CameraBoom 및 FollowCamera 확인
      - `[PIE-C5 PASS]` Dash & Invulnerability C++ 인터페이스 연동 확인
      - `[PIE-C6 PASS]` 액터 파괴 및 재스폰 재시작 검증 확인
  - **변경 파일**: `Scripts/run_pie_automation_proof.py`, `state/CURRENT_STATE.md`
  - **다음 작업**: U2 Combat Proof Audit (`UCombatComponent` 공격/피격 연동 조사)
  - **재개 조건**: Master 지시 시
