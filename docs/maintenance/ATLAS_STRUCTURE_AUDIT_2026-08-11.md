# Atlas Structure Audit — 2026-08-11 (3차)

## 목적

Engram 제거 및 R1–R9 잔여 정리 이후 `main`의 **실제 SoR vs 불필요 구조**를 구분한다.  
**삭제하지 않음.** 후보만 기록.

## 작업 시작

| 항목 | 값 |
|------|-----|
| HEAD | `536cd59b454c97b38a345ce29b21d87813210015` |
| Branch | `main` |
| Working tree | clean |
| `.gitmodules` / gitlink `160000` | **없음** |

## 요약 카운트

| 항목 | 결과 |
|------|------|
| 실제 빈 디렉터리 (`find -empty`) | **0** (clone 시점; git은 빈 디렉터리 미추적) |
| placeholder-only (`.gitkeep` 등) | Excelion design/assets 쪽 다수 — **제품 보호** |
| 고아 gitlink | **0** |
| 고아 script (호출처 약함) | `scripts/update_project_docs.py` |
| 고아 config | `config/print_settings.yaml` |
| legacy candidate | `atlas-runtime/`, `docs/process/root-temp/`, vendored MCP 트리 |
| duplicate candidate | `atlas-runtime` ↔ `core` (역할 중복 설계), `docs/process/*` ↔ `docs/*` 일부 |
| investigate further | `src/`, unregistered projects, `core/vision` |

---

## 표: 경로 · 유형 · 사용 · 참조 · 중복 · 판단

| 경로 | 유형 | 현재 사용 | 참조 | 중복 | 판단 | 근거 |
|------|------|-----------|------|------|------|------|
| `state/` | ops SoR | YES | CONTEXT_INDEX, AGENTS | — | **KEEP** | CURRENT_STATE / TASK_MAP 운영 핵심 |
| `tools/` | ops runtime | YES | tests, scripts, CONTEXT_INDEX | — | **KEEP** | domain_policy, atlas_runner, status |
| `docs/06_OPERATIONS/` | ops docs | YES | CONTEXT_INDEX | — | **KEEP** | DAILY_LOOP 등 |
| `docs/DECISIONS.md` | decisions | YES | CONTEXT_INDEX | — | **KEEP** | D01–D30 |
| `AGENTS.md` / `README.md` | rules | YES | always | — | **KEEP** | 도메인 분리 |
| `tests/` | CI | YES | CI unittest | core | **KEEP** | `.github/workflows/ci.yml` |
| `pyproject.toml` / `requirements-dev.txt` | packaging | YES | CI pip | — | **KEEP** | Issue #32 적용본 |
| `.github/` | CI | YES | GitHub Actions | — | **KEEP** | |
| `projects/excelion/` | product SoR | HOLD text | PROJECT_MAP | — | **KEEP (protected)** | 제품 트리 · 변경 금지 |
| `projects/_template/` | template | YES | onboarding | — | **KEEP (protected)** | |
| `core/` | platform code | PARTIAL | tests import core; tools runner | atlas-runtime | **KEEP** | CI 테스트 대상 · P3 mixed · product-coupled 서브는 HOLD |
| `core/forge`, `core/vision`, connectors | product-coupled | HOLD | forge test skip | — | **KEEP (HOLD)** | CONTEXT_INDEX hold |
| `atlas-runtime/` | experimental stubs | SMOKE only | `tools/check_atlas_runtime.py` (수동); CI **미실행** | core kernel 개념 | **DUPLICATE / LEGACY candidate** | README: experimental · hyphen dir · runner 미연동 |
| `src/` | docs only | NO | 코드 import **0** | — | **REMOVE CANDIDATE** | `AUDIT_KERNEL_CONTRACTS.md` 1파일 · 패키지 아님 |
| `config/print_settings.yaml` | config | NO runtime read found | docs/inventory only | core/review print | **REMOVE CANDIDATE / INVESTIGATE** | print 제품 잔여 · 로더 없음 |
| `scripts/daily_start.sh` / `daily_end.sh` | scripts | YES (ops) | call `tools/atlas_runner.py` | — | **KEEP** | 일일 루프 |
| `scripts/update_project_docs.py` | script | NO | 경로 `projects/exelion` (철자 오류·구경로) | — | **REMOVE CANDIDATE** | 깨진 경로 · 호출처 없음 |
| `scratch/` | sandbox | intentional | AGENTS BLACK | — | **KEEP** | 사용자 샌드박스 |
| `archive/` | history | NO runtime | BLACK | — | **KEEP** | forge-legacy KEEP 정책 |
| `docs/process/root-temp/` | legacy py | NO | 구 atlas_runtime import | atlas-runtime | **REMOVE CANDIDATE** | process 하 임시 스크립트 |
| `docs/process/` (잔여 다수) | process docs | MIXED | 일부 중복 docs/ | docs root | **INVESTIGATE / ARCHIVE later** | Alpha/Beta는 이미 archive |
| `projects/printguard/` | HOLD residual | NO code | docs 2 | — | **KEEP (HOLD)** | |
| `projects/paramodel/` | HOLD | NO active | PROJECT_MAP | — | **KEEP (HOLD)** | |
| `projects/makerfac-needs-research/` | HOLD | research | — | — | **KEEP (HOLD)** | |
| `projects/blender/` | HOLD binary | NO | ~15M blend | — | **KEEP (HOLD)** | BINARY policy |
| `projects/3GUpbit/` | unregistered | NO | PROJECT_MAP HOLD | — | **INVESTIGATE** | R5 정책 대기 |
| `projects/aws-mcp/` | vendored | NO Atlas | own package.json | — | **INVESTIGATE** | R5 |
| `projects/blender-mcp-main/` | vendored | NO Atlas | — | blender-open-mcp | **INVESTIGATE** | R5 |
| `projects/blender-open-mcp/` | vendored | NO Atlas | — | blender-mcp-main | **INVESTIGATE** | R5 |
| `logs/` | runtime output | N/A | gitignore | — | **KEEP policy** | R3 untrack 완료 |
| `.agents/` / `.vscode/` | editor | optional | — | — | **KEEP** | |

---

## 분류 목록

### KEEP
- `state/`, `tools/`, `tests/`, `docs/` (운영·DECISIONS·06_OPERATIONS), `AGENTS.md`, `README.md`
- `core/` (플랫폼 + HOLD 결합 모듈)
- `projects/excelion/`, `projects/_template/`
- HOLD 등록 프로젝트 (paramodel, printguard, makerfac, blender)
- `scratch/`, `archive/` (forge-legacy 포함)
- `scripts/daily_*.sh`, packaging, `.github/`

### REMOVE CANDIDATE
- `src/` (단일 audit md)
- `scripts/update_project_docs.py` (깨진 경로)
- `config/print_settings.yaml` (고아 설정)
- `docs/process/root-temp/` (legacy 임시 스크립트)

### DUPLICATE CANDIDATE
- `atlas-runtime/` ↔ `core/` 커널/decision 개념 (SoR는 `tools/` + `core/` 테스트)
- `projects/blender-mcp-main` ↔ `blender-open-mcp`
- `docs/process/` 일부 ↔ `docs/` 루트 설계 문서

### INVESTIGATE FURTHER
- R5 미등재 4프로젝트 최종 처분
- `core/vision` vs #33 TECH_DEBT
- `docs/process/` 잔여 archive 2차
- Alpha/Beta 본문 archive 경로 재배치 여부

### 보호된 영역
- `projects/excelion/`
- `projects/_template/`

---

## 검증 체크리스트

| 항목 | 결과 |
|------|------|
| 빈 디렉터리 조사 | PASS |
| placeholder 조사 | PASS |
| gitlink 조사 | PASS (0) |
| 참조 검색 | PASS |
| runtime 참조 | PASS (atlas-runtime smoke only) |
| CI 참조 | PASS |
| 삭제 실행 | **0** |

## 다음 작업 (Master 승인 후)

1. REMOVE CANDIDATE 4항 삭제/이동
2. R5 정책 확정
3. atlas-runtime 유지 vs archive 결정
4. process root-temp → archive

## 비범위 준수

삭제 · Excelion 변경 · Unreal · force push · 리팩터 · dependency 제거 **없음**.
