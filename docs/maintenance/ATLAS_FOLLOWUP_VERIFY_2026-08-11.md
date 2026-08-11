# Atlas Follow-up Verification — 2026-08-11

기준 HEAD: `40d3c949d7dd259da49e2d06a4756aec39f3bd75`  
역할: **검증만** (삭제·아카이브 이동·Excelion 변경 없음)

## 1. REMOVE 후보 4개 재검증

| 경로 | import/호출 | CI | 문서 외 참조 | 권고 |
|------|-------------|-----|--------------|------|
| `src/` (`AUDIT_KERNEL_CONTRACTS.md` only) | `from src` / `import src` **0** | 미사용 | maintenance 감사 문서만 | **삭제 권고 (Low)** — 또는 `docs/`로 이동 후 삭제 |
| `scripts/update_project_docs.py` | 호출처 **0** (scripts/docs/CI 무) | 미사용 | 자체만 | **삭제 권고 (Low)** |
| `config/print_settings.yaml` | Python loader **0** | 미사용 | core/README, process hygiene 문서 | **삭제 권고 (Low)** · 내용 동일본이 `core/config/print_settings.yaml`·`core/review/print_settings.yaml`에 존재 |
| `docs/process/root-temp/` | 런타임/CI **0** | 미사용 | 구 `atlas_runtime` 데모 | **archive 이동 권고 (Low)** · 즉시 삭제보다 archive 권장 |

### update_project_docs.py 상세

- 하드코드 경로: `projects/exelion/` (**존재하지 않음**; 실제는 `projects/excelion/`)
- 루트 `PROJECT_OVERVIEW.md`, `PROJECT_EXECUTION_PLAN.md` **부재**
- `docs/PROJECT_STATUS.md`는 존재하나 **SUPERSEDED** 배너
- `excelion` backlog/sprints는 존재하나 스크립트가 가리키는 철자 경로가 달라 **실행 시 즉시 실패**

### print_settings 상세

| 복사본 | 내용 |
|--------|------|
| `config/print_settings.yaml` | min_wall 2.5 / overhang 45 |
| `core/config/print_settings.yaml` | 동일 |
| `core/review/print_settings.yaml` | 동일 (주석 略) |

`core/**/*.py` / `tools/**/*.py`에서 파일 open/load 흔적 없음. root `config/`만 제거해도 core 쪽 잔여 가능.

## 2. DUPLICATE 후보

### atlas-runtime/ ↔ core/

| 항목 | atlas-runtime | core |
|------|---------------|------|
| 역할 | P3 실험 커널 스텁 | 계약·decision·execution·tests |
| CI | **미실행** | unittest 대상 (다수 `from core`) |
| 진입점 | `tools/check_atlas_runtime.py` 수동 스모크 | tests + runner 간접 |
| README | experimental · daily SoR 아님 | platform mixed |

**권고:** SoR는 `tools/` + `core/` + `tests/`. `atlas-runtime/`은 **LEGACY/DUPLICATE — archive 후보**. 삭제 전 Master 승인. `check_atlas_runtime.py`와 domain_policy allowlist 정리 동반 필요.

### blender-mcp-main ↔ blender-open-mcp

| | blender-mcp-main | blender-open-mcp |
|--|------------------|------------------|
| 성격 | 외부 BlenderMCP (Claude) 벤더 복사 | Ollama 로컬 MCP 변형 |
| 크기 | ~612K | ~216K |
| Atlas CI/tools 참조 | **없음** | **없음** |

**권고:** 둘 다 R5 HOLD. 유사 목적이라 **하나만 남기거나 둘 다 archive**는 Master 정책. 자동 삭제 금지.

### docs/process/ ↔ docs/

- 예: `DESIGN_PRINCIPLES.md`, `EXECUTION_MODEL.md` — **양쪽 존재, 내용 differ** (동일 복사 아님).
- process 쪽 일부는 스텁/축약 가능.
- **전수 동일 중복 아님** → 일괄 삭제 금지. **INVESTIGATE / 선택적 archive** 유지.

## 3. R5 미등재 프로젝트

| 경로 | 성격 | Atlas 참조 | 권고 |
|------|------|------------|------|
| `3GUpbit/` | toga 기반 업비트 UI 실험 | PROJECT_MAP HOLD만 | **정책 대기** — DevOS 비관련 |
| `aws-mcp/` | vendored `chatwithcloud-mcp` (2.2M) | 없음 | **정책 대기** — 분리 레포 후보 |
| `blender-mcp-main/` | vendored BlenderMCP | 없음 | **정책 대기** |
| `blender-open-mcp/` | vendored Ollama MCP | 없음 | **정책 대기** |

공통: ACTIVE 금지 유지. 삭제/이전은 Master 결정 후 별도 작업.

## 4. 추가 조사

### core/vision ↔ Issue #33

- #33: **VisualPerceptionEngine 제거** (실험 카메라/YOLO).
- **유지:** `DigitalVisionInspector` + `vision_config.json` (`digital_screen_only`).
- CI: `tests/test_digital_vision.py`가 `core.vision.digital_vision_inspector` import.
- **권고: KEEP** (HOLD/product-adjacent이나 테스트 연동). “vision 디렉터리 통삭제” 금지.

### docs/process/ 잔여

- Alpha/Beta 스냅샷은 process에서 제거됨.
- `root-temp/` + 다수 process md 잔존.
- **권고:** `root-temp` archive 우선; 나머지 process는 2차 선별 (일괄 X).

### Alpha/Beta archive 재배치

| 상태 | 값 |
|------|-----|
| `archive/process-alpha-beta-snapshots/` | README + `ATLAS_ALPHA_AUDIT_SNAPSHOT.md` 1건 |
| 나머지 19 본문 | git 이력에만 (R9 process 경로 삭제 커밋들) |

**권고 (선택):** 이력에서 19파일 복원 → archive 경로로 재배치. 운영 영향 없음. 미실시 시에도 이력으로 복구 가능.

## 5. 보호 확인

- `projects/excelion/` — 변경 없음
- `projects/_template/` — 변경 없음
- Unreal / dependency / force push — 없음

## 6. 종합 권고 (Master 승인 후 실행용)

| 우선 | 항목 | 액션 |
|------|------|------|
| 1 | `src/`, `scripts/update_project_docs.py` | 삭제 가능 |
| 2 | `config/print_settings.yaml` | 삭제 가능 (core 복사본 유지) |
| 3 | `docs/process/root-temp/` | archive 이동 |
| 4 | `atlas-runtime/` | archive 또는 유지 결정 + smoke 도구 정리 |
| 5 | R5 4프로젝트 | 정책 (keep/split/archive) |
| 6 | Alpha/Beta 19파일 | 선택적 archive 복원 |
| — | `core/vision` | **삭제 금지** |

## 불확실 항목

- `core/config` vs `core/review` print_settings 이중화 (둘 다 로더 없음 — 별도 정리 후보)
- process ↔ docs 축약본 관계 (수동 diff 필요)
- R5를 monorepo에 둘지 외부 레포로 둘지

## 다음 작업

1. Master가 REMOVE 1–3 승인 시 단일 chore 커밋으로 삭제  
2. root-temp archive 이동 커밋  
3. R5·atlas-runtime 정책 문서화 또는 실행  
4. (선택) Alpha/Beta blob archive 재배치  

## 검증 요약

| 항목 | 결과 |
|------|------|
| 삭제 실행 | **0** |
| Excelion 변경 | **0** |
| 기준 HEAD | `40d3c949…` |
