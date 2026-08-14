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

## Next

1. **언리얼 에디터 5.4 실행 & Remote Control API 연동**:
   - `Excelion.uproject` 에디터 로딩
   - Project Settings / Plugin에서 `Web Remote Control` (Remote Control API) 플러그인 활성화
2. **C++ 파생 블루프린트 에셋(BP) 및 UMG HUD 구성**:
   - `BP_ExcelionCharacter`, `BP_SethBoss`, `BP_ExcelionEnemy`, `BP_PowerEnemy`, `BP_SpeedEnemy` 생성 및 컴포넌트 파라미터 튜닝
   - `WBP_ExcelionHUD` (UMG) 생성 후 `UExcelionHUDWidget` C++ 클래스 바인딩
3. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (C++ 빌드 및 헤더 정합 완비)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: Excelion 메카 데이터 에셋 2종(`DA_AXION_Stats`, `DA_SethBoss_Stats`) 파이프라인 자동화 구축 및 검증 완료
  - **현재 상태**: VERIFIED (데이터 에셋 2종 생성 완료 및 main 저장소 동기화)
  - **완료**:
    - `Source/Excelion/Data/ExcelionMechaDataAsset.h`: 기본 `MechaId` 식별자를 `axion-001` 정식명으로 변경
    - `Scripts/create_data_assets_automation.py`: 파이썬 기반 데이터 에셋 자동 생성 스크립트 작성 및 호출
    - `/Game/Data/` 에셋 생성 검증:
      - `DA_AXION_Stats.uasset` (MaxHP=100.0, Armor=10.0, Scale=25m, Atk=25.0, Category=Player)
      - `DA_SethBoss_Stats.uasset` (MaxHP=480.0, Armor=20.0, Scale=30m, Atk=55.0, Category=Boss)
  - **변경 파일**: `Source/Excelion/Data/ExcelionMechaDataAsset.h`, `Content/Data/*.uasset`, `Scripts/create_data_assets_automation.py`
  - **다음 작업**: 언리얼 에디터 UMG HUD (`WBP_ExcelionHUD`) 뷰포트 레이아웃 배치 및 플레이테스트
  - **재개 조건**: Master 지시 시
