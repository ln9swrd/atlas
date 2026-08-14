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
- **Unreal 5.4 실기 검증 완료 (2026-08-14)** — 개발 PC에서 `build_cli.ps1` C++ 빌드 및 언리얼 에디터 5.4 정상 로딩 실기 검증 완료 (VERIFIED)

## Next

1. **에셋/블루프린트 파이프라인 수립**: C++ 클래스 기반 파생 블루프린트 에셋(`BP_ExcelionCharacter`, `BP_SethBoss` 등) 및 UMG HUD 위젯 템플릿 연동
2. **ORD-GRUNT** · **DECISION C = HOLD** 유지 (후속 자율 착수 금지)
3. (ops) SoR 잔여 정합 확인 — SOT_MAP 기준

## Pipeline

- **Active (문서):** Meshy → Blender → FBX → UE (`MESHY_BLENDER_PIPELINE_SPEC` · TBD 유지)
- excelion-forge: **DEPRECATION** (활성 경로 폐기 · 외부 자산 보존)

## Hold

| 항목 | 상태 |
|------|------|
| **M5 Visualization / PNG** | **HOLD / Queued** |
| UE 실기 (M6) | **VERIFIED (기반 C++ 로딩 정상)** |
| ParaModel | HOLD |
| Meshy/Blender/UE 구현 | HOLD |
| **ORD-GRUNT 후속 (LOCK / 시각 / 구현)** | **HOLD (DECISION C)** |

## Notes

- **idle**(플랫폼) = 제품 Next와 분리 · ops 대기 의미만
- 이미지·코드·캐논 본문 변경은 별도 Master 게이트 · SOT_MAP LOCK 준수
- **Handoff (2026-08-14)**:
  - **작업명**: Excelion 언리얼 5.4 C++ 핵심 코어 구축 및 언리얼 전용 MCP 서버(unreal-mcp-server) 연동 완료
  - **현재 상태**: VERIFIED (C++ 로딩 검증 완료 & MCP 서버 연동 세팅 완비)
  - **완료**: `SCoreComponent`, `MadnessComponent`, `ExcelionCharacter`, `SethBoss`, `ExcelionGameMode`, `ExcelionMechaDataAsset`, `ExcelionFeedbackSubsystem`, `ExcelionHUDWidget`, `unreal_mcp_server.py`, `.agents/mcp_config.json`
  - **관련 커밋**: `4068e04` (`feat(excelion): implement C++ mecha core, S-Core, Madness, SethBoss Phase 2, UMG HUD, and Unreal MCP server`)
  - **다음 작업**: 언리얼 에디터 `Remote Control API` 플러그인 활성화 및 MCP 통한 실시간 에디터 제어 테스트
  - **재개 조건**: Master의 후속 지시 시
