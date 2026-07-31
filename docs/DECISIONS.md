# Atlas Decision Log

Status: Living log (2026-07-31)

---

## Core Principles

| ID | Decision | Notes |
|----|----------|-------|
| D01 | **Claim ≠ Evidence** (Evidence-First) | DONE 전 CLI/파일 Evidence 필수 |
| D02 | **Build the system that builds the game** | Atlas = 제품을 만드는 운영 체계 |
| D03 | Knowledge ↔ Runtime 분리 | 지식=Git docs; 세션 런타임 폐기 가능 |
| D04 | Environment Registry | DEV_WORK / DEV_HOME 등 |
| D05 | 운영 시나리오 검증 우선 | ROI Gate |
| D06 | 실 프로젝트 태스크로 루프 검증 | |

## Agent / Local LLM

| ID | Decision | Notes |
|----|----------|-------|
| D07 | Cline: Subagents/Native/Parallel OFF 권장 | |
| D08 | 로컬 AI는 WSL 권장 | |
| D15 | Primary surface = Cline + Ollama | Continue 보조 |
| D21 | **마스터** = 최종 권한; 단순 쉘 가능 | ROLE_SPLIT.md |
| D22 | **atlas-extension 폐기** | issue #2 / PR #3 closed |

## Domain Isolation / VERIFY

| ID | Decision | Notes |
|----|----------|-------|
| D17 | Forbidden auto-load: archive/, obsidian/, node_modules/, .git/ | |
| D18 | Context slim: 활성 타겟만 | |
| D23 | **VERIFY 샌드박스** (G6 #4) | VERIFY·도구 실행의 파일/코드 접근은 **활성 도메인 프로젝트** (`projects/<name>/` 또는 Atlas `state/`·`tools/` 등 시스템 허용 경로)로 제한. 호스트 임의 경로·외부 네트워크 부작용 금지. 구현 Acceptance는 orchestrator/Cline 도구 쪽에 후속. 메타(DevOS 코어 수정) 우회는 마스터 명시 승인. |

## Kraken / Knowledge / Forge

| ID | Decision | Notes |
|----|----------|-------|
| D12 | Kraken = 실행·자동화 **계층** | 제품 프로젝트 아님 |
| D24 | **Kraken 경로** (G6 #5) | Canonical 후보 **`tools/kraken/`**. `projects/kraken/` 금지. 이름 keep. 이관은 존재 시 후속 작업. |
| D25 | **과거 스프린트 Knowledge** (G6 #6) | SPRINT-009~029 등 과거 스프린트는 활성 TASK 아님 → archive(또는 기존 archive)만. state Open에 올리지 않음. |
| D09 | Forge = Core + Blender add-on 하이브리드 | |
| D13 | .blend Git; 대용량 LFS | |
| D14 | 급할수록 파이프라인 우선 | |
| D20 | Canonical Forge = `projects/excelion-forge/` | |
| D26 | **Forge Phase 경로** (G6 #7) | 제품 작업 = excelion-forge only (D20 재확인). `projects/forge/`·중첩 스텁은 삭제/archive **예정**(실행은 별도 로컬 Evidence). 지금은 Atlas min scope로 제품 작업 보류. |

## Documentation

| ID | Decision | Notes |
|----|----------|-------|
| D10 | docs 파일명 영어, 본문 한국어 | |
| D11 | SERA ≠ 프로젝트 목록 | D19 |
| D16 | 대화 → 문서 → 자산 | |
| D19 | **프로젝트 SERA 폐기** | `projects/sera` 금지 |

---

## G6 closed

| Issue | Decision | Status |
|-------|----------|--------|
| #4 VERIFY | D23 | **Confirmed** — 구현 Acceptance 후속 |
| #5 Kraken path | D24 | **Confirmed** — 이관 실행 후속 |
| #6 SPRINT archive | D25 | **Confirmed** — 이동 실행 후속 |
| #7 Forge phase path | D26 | **Confirmed** — 삭제/archive 실행 후속; 제품 작업은 min scope 이후 |

Draft archive: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md` (historical)
