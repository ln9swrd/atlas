# Policy Hold Survey — 2026-08-11

기준 SHA: `0100a4cd1de938f9e5ccc3aa8eee77ff0a0d5474`  
선행: `STRUCTURE_CLEANUP_EXECUTED_2026-08-11.md`  
역할: **조사 + 문서화만** (삭제·이동 0)

---

## 1. atlas-runtime/

### 실체
- 파일: kernel/observation/inference/verification/evidence/decision 스텁 (~100 LOC py) + constitution/rules md
- README: **experimental**, daily-ops SoR 아님 (`tools/`가 SoR)
- 패키지명: 디렉터리 `atlas-runtime` (하이픈) → 정상 import 불가

### 참조
| 영역 | 결과 |
|------|------|
| CI (`.github/workflows/ci.yml`) | **미사용** (unittest `tests/`만) |
| `tests/` | atlas-runtime import **0** |
| `tools/atlas_runner.py` | **미연동** |
| `tools/check_atlas_runtime.py` | 수동 스모크만 (실행 시 PASS stub) |
| `tools/domain_policy.py` | allowlist에 `atlas-runtime/` 포함 |
| P3 inventory | G1: runner 미연동 · experimental |

### 중복
- `core/` + `tests/`가 플랫폼 계약·decision·execution SoR (테스트 17파일이 core import)
- atlas-runtime은 동일 observe→decide 파이프라인의 **얇은 스텁 복제**

### 권고
| 판정 | **LEGACY / ARCHIVE 후보** |
|------|---------------------------|
| 위험도 | **Low** (CI 비의존) |
| Master 승인 필요 | **예** (삭제 또는 archive 이동 시) |
| 동반 작업 | `check_atlas_runtime.py` 처리 · domain_policy allowlist에서 제거 검토 |
| 지금 실행 | **금지** |

SoR 유지: `tools/` + `core/` + `tests/` + `state/`.

---

## 2. R5 미등재 프로젝트

공통: Atlas `tools/`/`tests/`/`CI` 참조 **없음**. PROJECT_MAP에 HOLD unregistered로만 표기.

| 경로 | 성격 | 크기 | 독립성 | 권고 |
|------|------|------|--------|------|
| `projects/3GUpbit/` | toga 업비트 UI 실험 | ~600K · 9 files | Atlas DevOS 무관 | **ARCHIVE 또는 외부 분리** · 등록 불필요 |
| `projects/aws-mcp/` | vendored chatwithcloud-mcp | ~2.2M | 별도 Node MCP | **외부 레포 / ARCHIVE** |
| `projects/blender-mcp-main/` | vendored BlenderMCP (Claude) | ~612K | 벤더 복사 | **ARCHIVE 또는 하나만 유지** |
| `projects/blender-open-mcp/` | Ollama Blender MCP | ~216K | 벤더 변형 | **ARCHIVE 또는 하나만 유지** |

| 판정 | 네 개 모두 **Atlas SoR 비포함** |
|------|--------------------------------|
| 위험도 | Med (용량·혼입) · 삭제 시 데이터 손실만 (런타임 무) |
| Master 승인 필요 | **예** (archive/삭제/등록 중 선택) |
| 지금 실행 | **금지** |

권장 정책 옵션 (Master 선택):
1. 전부 `archive/projects-unregistered/` 이동  
2. 별도 GitHub 레포로 분리 후 monorepo에서 제거  
3. HOLD 유지 (현 상태)

---

## 3. Alpha/Beta 19개 역사 파일

### 상태
- `docs/process/` 경로: **제거됨** (R9)
- `archive/process-alpha-beta-snapshots/`: README + `ATLAS_ALPHA_AUDIT_SNAPSHOT.md` **1건만** 트리에 존재
- 나머지 본문: **git 이력**에만 존재

### 참조
- active CI/runtime: **없음**
- process 위생 문서에 과거 파일명 언급 (역사)
- 포인터: `docs/process/README_ARCHIVED_ALPHA_BETA.md`

### 권고
| 판정 | **ARCHIVE (선택 복원)** |
|------|-------------------------|
| 위험도 | Low |
| Master 승인 필요 | 복원 시에만 |
| 지금 실행 | **금지** |

미복원 시에도 `git show <pre-R9>:<path>`로 복구 가능.

---

## 4. print_settings 이중화

### 잔존 파일 (root config는 이미 삭제됨)

| 경로 | 내용 |
|------|------|
| `core/config/print_settings.yaml` | min_wall 2.5 / overhang 45 + 주석 1줄 |
| `core/review/print_settings.yaml` | 동일 수치 · trailing newline만 다름 |

### Loader
- `core/**/*.py`, `tools/**/*.py`에서 yaml **open/load 0**
- `review_engine.py`는 printability **점수 인자**만 사용 (파일 미로드)

### 참조
- `core/README.md`가 두 경로를 Print product로 표기
- 역사 process/hygiene 문서

### Canonical 권고
| 유지 후보 | `core/config/print_settings.yaml` (설정 SoR 위치) |
|-----------|-----------------------------------------------------|
| 중복 후보 | `core/review/print_settings.yaml` — **REMOVE 후보** (loader 없음·내용 동일) |
| 위험도 | Low |
| Master 승인 필요 | **예** |
| 지금 실행 | **금지** |

대안: 둘 다 남겨 두고 print 제품 재개 시 단일 로더 도입.

---

## 5. 보호 영역 확인

| 경로 | 이번 조사 변경 |
|------|----------------|
| `projects/excelion/` | **0** |
| `projects/_template/` | **0** |
| `core/vision/` | **0** · KEEP (CI DigitalVision) |

---

## 종합 권고 표

| ID | 대상 | 권고 | 위험 | 승인 후 액션 |
|----|------|------|------|--------------|
| P1 | atlas-runtime/ | **ARCHIVE** (또는 LEGACY keep) | Low | archive 이동 + smoke/allowlist 정리 |
| P2 | R5 4프로젝트 | **ARCHIVE / 외부분리** | Med | Master 옵션 1–3 선택 |
| P3 | Alpha/Beta 19 | **ARCHIVE 복원 선택** | Low | 이력→archive 경로 |
| P4 | core/review/print_settings.yaml | **REMOVE** (config 쪽 유지) | Low | 단일 파일 삭제 |
| — | core/vision | **KEEP** | — | 없음 |

### 권장 실행 순서 (승인 후)
1. P4 print_settings 중복 1파일 삭제  
2. P1 atlas-runtime archive + 도구 정리  
3. P2 R5 일괄 archive 또는 분리  
4. P3 Alpha/Beta blob 복원 (선택)

### Master 승인 필요 여부
**모든 삭제/이동: 예.** 본 문서는 근거만 제공.

---

## 검증

| 항목 | 결과 |
|------|------|
| 삭제/이동 실행 | **0** |
| 문서만 추가 | 본 커밋 |
| 보호 영역 | 미변경 |
