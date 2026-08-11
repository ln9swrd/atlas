# Structural Residue Audit — 2026-08-11

## 목적

Atlas `main`의 구조적 잔여물 전수 감사.  
**삭제하지 않음.** 후보 목록과 근거만 기록.

## 작업 시작

| 항목 | 값 |
|------|-----|
| HEAD | `261485be2d845ee48bd55395158fbedcc78eb015` |
| Branch | `main` |
| Working tree | clean |
| 직전 정리 | engram gitlink 제거 · archive legacy 3트리 제거 |

## 1. 고아 gitlink / submodule

| 항목 | 결과 |
|------|------|
| `.gitmodules` | 없음 |
| mode `160000` gitlink | **없음** (engram 제거 후) |
| `git submodule status` | 매핑 없음 |

**후보: 없음**

## 2. Placeholder / 빈 디렉터리

| 경로 | 상태 | 비고 |
|------|------|------|
| `projects/printguard/` | 파일 2개(docs만) · 루트 파일 0 | HOLD 비즈니스 기획 잔여 |
| `projects/excelion/game/` | 파일 0 | 게임 구현 자리만 존재 |
| `projects/excelion/assets/placeholder/` | 파일 0 | placeholder |
| `projects/excelion/assets/sprites/` | 파일 0 | placeholder |
| `projects/paramodel/data/` | 파일 0 | HOLD |
| `projects/blender-mcp-main/src/` | 파일 0 | 벤더 MCP 복사본 |
| `projects/blender-open-mcp/src/` | 파일 0 | 벤더 MCP 복사본 |
| `projects/3GUpbit/resources/` | 파일 0 | 레지스트리 미등재 |
| `src/` | `AUDIT_KERNEL_CONTRACTS.md` 1개만 | Python 패키지 아님 |
| `scratch/` | README만 | 의도된 샌드박스 (BLACK) |

**후보 (문서화/정리 검토):** printguard 최소 골격, excelion 빈 assets/game, `src/` 단일 문서 디렉터리

## 3. 미참조· supersede 설정 파일

| 경로 | 근거 | 후보 등급 |
|------|------|-----------|
| `pyproject.toml.draft` | 자체 주석: SUPERSEDED by `pyproject.toml` (Issue #32). `docs/atlas/PYPROJECT_MIGRATION_CHECKLIST.md`만 언급 | **REMOVE CANDIDATE** (Low) |
| `config/print_settings.yaml` | root config 1파일. PrintGuard/제품 결합 잔여. P3 inventory도 print product로 분류 | **INVESTIGATE** |
| `logs/*.jsonl`, `logs/atlas_status.txt` | `.gitignore`에 `logs/` 있음에도 **tracked**. 런타임 산출물 | **HYGIENE CANDIDATE** (untrack) |
| `scripts/master_l8_l10.sh` | D22 DEPRECATION · `exit 1` only | **REMOVE CANDIDATE** (Low) |
| `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md` | atlas-extension 폐기 트랙 체크리스트 | **ARCHIVE/KEEP historical** |
| `docs/06_OPERATIONS/MASTER_BATCH.md` | L-8…L-10 abandoned 명시 | **ARCHIVE/KEEP historical** |

## 4. 폐기·HOLD 프로젝트 / 도구 잔여

### 4.1 `projects/` — 레지스트리와 불일치

| 경로 | PROJECT_MAP / README | 실체 | 후보 |
|------|----------------------|------|------|
| `excelion/` | SoR active tree | 480 files · 35M | **KEEP** |
| `paramodel/` | HOLD | addon + blend 등 | **KEEP (HOLD)** |
| `printguard/` | HOLD | docs 2 only | **HOLD residual** |
| `makerfac-needs-research/` | HOLD | research notes | **KEEP (HOLD)** |
| `blender/` | HOLD legacy | `shin getter robo12.blend` ~15M | **KEEP (HOLD)** · 바이너리 큼 |
| `_template/` | template | 정상 | **KEEP** |
| `coin-s/` | MAP에 HOLD로 언급 | **디렉터리 없음** | **문서 정합 후보** (맵 갱신) |
| `3GUpbit/` | 맵/README **미등재** | Python 실험 코드 | **INVESTIGATE / HOLD orphan project** |
| `aws-mcp/` | 미등재 | 외부 MCP 서버 복사 (2.2M) | **INVESTIGATE** |
| `blender-mcp-main/` | 미등재 | 외부 BlenderMCP | **INVESTIGATE** |
| `blender-open-mcp/` | 미등재 | 외부 Ollama MCP | **INVESTIGATE** |

### 4.2 이미 정리·폐기된 항목 (추가 삭제 불필요)

| 항목 | 상태 |
|------|------|
| `engram` gitlink | **REMOVED** 2026-08-11 |
| `archive/projects-templates-legacy` 등 3트리 | **REMOVED** |
| `archive/projects-forge-legacy` | **KEEP** (FORGE_REMOVAL_SCOPE) |
| atlas-extension in `projects/` | 이미 archive 삭제됨 · D22 |
| `projects/sera` | D19 금지 · 존재 안 함 |

### 4.3 tools / tests 잔여

| 경로 | 비고 | 후보 |
|------|------|------|
| `tools/atlas_qwen_orchestrator.py` | Ollama 루프 · optional | KEEP (optional tool) |
| `tests/test_forge_scenario.py` | `@skip` Forge HOLD | KEEP until policy |
| `core/forge/` | 플랫폼 forge 런타임 (제품 forge와 별개) | KEEP · HOLD 연동 |
| `core/vision/` | #33 이후 축소 잔여 digital_vision | INVESTIGATE vs TECH_DEBT |
| `atlas-runtime/` | experimental stubs · runner 미연동 (P3 inventory G1) | KEEP experimental |

## 5. 중복·과다 운영 문서

| 영역 | 관찰 | 후보 |
|------|------|------|
| `docs/process/ATLAS_ALPHA_*` | Alpha freeze/handover/validation 등 **다수 스냅샷** | **ARCHIVE 후보 묶음** (process → archive/summary 정책과 정합 검토) |
| `docs/process/ATLAS_BETA_*` | Beta design/review 다수 | 동일 |
| `state/PR*_MERGE_RESULT.md`, `PHASE*_CLOSEOUT.md` | Phase4 closeout 기록 | **KEEP** (최근 SoR 증거) |
| `docs/ROADMAP.md` | maintenance banner 있음 · 역사 로드맵 | KEEP historical |
| `docs/06_OPERATIONS/L8_L10_*`, `MASTER_BATCH.md` | 폐기 트랙 | historical KEEP or move under archive note |
| `projects/README.md` vs `state/PROJECT_MAP.md` vs `docs/process/PROJECT_REGISTRY.md` | coin-s / atlas-extension / 3GUpbit·MCP 목록 **불일치** | **DOC SYNC 후보** |

## 6. main 미사용·legacy 코드 성격

| 영역 | 평가 |
|------|------|
| `core/` | 플랫폼 커널 스냅샷. README: product-coupled 로드 금지. ACTIVE_TARGET=idle 에서 유지 |
| `atlas-runtime/` | 실험 스텁 · 일일 SoR 아님 |
| `src/` | 구현 코드 없음 · 감사 문서만 → **구조 이상 후보** |
| `logs/` tracked | gitignore와 모순 → **untrack 후보** |
| 외부 MCP/업비트 트리 | Atlas DevOS와 제품 결합 약함 · monorepo 혼입 |

## 종합 후보 표 (삭제 금지 · 분류만)

| ID | 대상 | 분류 | Risk | 권장 다음 액션 |
|----|------|------|------|----------------|
| R1 | `pyproject.toml.draft` | REMOVE CANDIDATE | Low | Master 승인 후 삭제 |
| R2 | `scripts/master_l8_l10.sh` | REMOVE CANDIDATE | Low | Master 승인 후 삭제 |
| R3 | `logs/*` tracked | HYGIENE | Low | `git rm --cached` + ignore 유지 |
| R4 | `projects/coin-s` 문서 잔여 | DOC SYNC | Low | PROJECT_MAP/README/REGISTRY 정합 |
| R5 | `3GUpbit`, `aws-mcp`, `blender-mcp-*` | INVESTIGATE | Med | 등재·HOLD·분리·archive 중 정책 결정 |
| R6 | `projects/printguard` 최소 docs | HOLD residual | Low | HOLD 유지 또는 archive |
| R7 | `src/` 단일 md | INVESTIGATE | Low | docs로 이동 또는 유지 이유 기록 |
| R8 | `config/print_settings.yaml` | INVESTIGATE | Low | printguard 연동 여부 확인 |
| R9 | `docs/process/ATLAS_ALPHA_*` 묶음 | ARCHIVE CANDIDATE | Low | process 정리 PR (내용 삭제 아닌 이동) |
| R10 | `projects/blender/*.blend` ~15M | HOLD binary | Med | BINARY policy 재확인 · LFS/외부 |
| — | `archive/projects-forge-legacy` | KEEP | — | 기존 정책 |
| — | `excelion/` | KEEP | — | SoR |

## 명시적 비범위 (이번 감사에서 삭제·변경 안 함)

- Excelion 스토리/디자인/Unreal
- `archive/summary`, `recovered`, `legacy_files`, `projects-forge-legacy`
- 외부 `ln9swrd/engram`, `excelion-forge`
- force push / reset / clean

## 다음 작업 제안 순서

1. **Low risk 빠른 정리 (승인 후):** R1, R2, R3, R4  
2. **정책 결정 필요:** R5 (미등재 프로젝트 4개)  
3. **문서 위생:** R9 (Alpha/Beta process 스냅샷 archive 정책)  
4. **보류:** R6–R8, R10, core/atlas-runtime 구조

## 검증 요약

- 고아 gitlink: **0**
- 신규 삭제 실행: **0**
- 본 문서만 추가
