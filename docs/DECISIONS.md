# Atlas Decision Log

Status: Living log (2026-07-31)  
Discipline: `docs/06_OPERATIONS/DECISION_PROCESS.md` (P2-5)  
Flow: **Draft → Master confirm → this file** (chat is not SoR)

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
| D23 | **VERIFY 샌드박스** (G6 #4) | 활성 도메인 또는 Atlas system paths만. BLACK·WS 밖 금지. **Implemented** P2-1 A–D (2026-07-31). Evidence: `check_domain_policy.py` 25/25. Meta 코어 write = Master only. |

## Kraken / Knowledge / Forge

| ID | Decision | Notes |
|----|----------|-------|
| D12 | Kraken = 실행·자동화 **계층** | 제품 프로젝트 아님 |
| D24 | **Kraken 경로** (G6 #5) | Canonical 후보 `tools/kraken/`. `projects/kraken/` 금지. **F3 2026-07-31: N/A** — 이동할 코드 없음. |
| D25 | **과거 스프린트 Knowledge** (G6 #6) | SPRINT-009~029 → archive only. **F3: OK** — TASK_MAP Open 없음. |
| D09 | Forge = Core + Blender add-on 하이브리드 | |
| D13 | **Binary policy** | 기본 ignore (`.gitignore`). 필요 시만 LFS. 초대형 = external. SoR: `docs/06_OPERATIONS/BINARY_ASSET_POLICY.md` (R6 2026-07-31). |
| D14 | 급할수록 파이프라인 우선 | |
| D20 | Canonical Forge = `projects/excelion-forge/` | |
| D26 | **Forge Phase 경로** (G6 #7) | 제품 = excelion-forge only. **F3: policy Done** — `projects/forge/` legacy 유지; 물리 archive는 Master local optional. |

## Target / Ops

| ID | Decision | Notes |
|----|----------|-------|
| D27 | **ACTIVE_TARGET = platform** (R5) | Master 2026-07-31. 제품 hold. |
| D28 | **Long-term repo split defaults** | Master confirm 2026-07-31. (1) two product repos `excelion` + `excelion-forge` (2) history extract preferred where valuable; else pointer (3) product-coupled `core/` stays HOLD in atlas until forge consumes (4) execute **before** long product sprint. Plan: `docs/07_ROADMAP/LONG_TERM_REPO_SPLIT.md`. S1 tag local. |

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
| #4 VERIFY | D23 | **Confirmed + Implemented** (P2-1) |
| #5 Kraken path | D24 | **Confirmed + F3 N/A** (no path to move) |
| #6 SPRINT archive | D25 | **Confirmed + F3 OK** (no Open sprints) |
| #7 Forge phase path | D26 | **Confirmed + F3 policy Done** (physical archive optional) |

Draft archive: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md`  
Process: `docs/06_OPERATIONS/DECISION_PROCESS.md`
