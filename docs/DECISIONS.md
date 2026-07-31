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
| D23 | **VERIFY 샌드박스** (G6 #4) | Implemented P2-1. Evidence 25/25. |

## Kraken / Knowledge / Forge

| ID | Decision | Notes |
|----|----------|-------|
| D12 | Kraken = 실행·자동화 **계층** | 제품 프로젝트 아님 |
| D24 | **Kraken 경로** | F3 N/A |
| D25 | **과거 스프린트 Knowledge** | F3 OK |
| D09 | Forge = Core + Blender add-on 하이브리드 | |
| D13 | **Binary policy** | BINARY_ASSET_POLICY.md |
| D14 | 급할수록 파이프라인 우선 | |
| D20 | Canonical Forge path (legacy wording) | **Superseded for SoR by D28**: GitHub `ln9swrd/excelion-forge`; atlas path removed (S5-del) |
| D26 | **Forge Phase 경로** | F3 policy Done |

## Target / Ops

| ID | Decision | Notes |
|----|----------|-------|
| D27 | **ACTIVE_TARGET = platform** (R5) | Master 2026-07-31 → superseded by closeout |
| D28 | **Long-term repo split** | S0–S5 Done. Product SoR = separate repos. Mono mirrors deleted (S5-del b719513). |
| D29 | **Atlas closeout; product hold** | Master 2026-07-31. Atlas = platform only. 제품 진행 안 함. Closeout Done → ACTIVE_TARGET = **idle**. |

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
| #4 VERIFY | D23 | Implemented |
| #5 Kraken path | D24 | N/A |
| #6 SPRINT archive | D25 | OK |
| #7 Forge phase path | D26 | policy Done |

Process: `docs/06_OPERATIONS/DECISION_PROCESS.md`
