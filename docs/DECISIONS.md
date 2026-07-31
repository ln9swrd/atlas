# Atlas Decision Log

Source: `obsidian/Archive/Original Conversations/ANALYSIS_REPORT.md` (Phase 3)
Status: Living log (2026-07-31)

---

## Core Principles

| ID | Decision | Notes |
|----|----------|-------|
| D01 | **Claim ≠ Evidence** (Evidence-First) | DONE 보고 전 CLI/파일/테스트 증거 필수 |
| D02 | **Build the system that builds the game** | Atlas는 제품이 아니라 제품을 만드는 운영 체계 |
| D03 | Knowledge Layer ↔ Runtime Layer 분리 | 안정 지식은 Git docs/ADR, 세션 런타임은 폐기 가능 |
| D04 | Environment 분리·등록 (Registry) | DEV_WORK / DEV_HOME 등 환경별 제약 반영 |
| D05 | 기능 추가보다 실제 운영 시나리오 검증 우선 | ROI Gate |
| D06 | 가상 Task보다 실제 Exelion Task로 운영 | 실 프로젝트 태스크로 루프 검증 |

## Agent / Local LLM

| ID | Decision | Notes |
|----|----------|-------|
| D07 | Cline: Subagents / Native / Parallel Tool Call OFF 권장 | 로컬 모델 안정화 |
| D08 | 로컬 AI는 WSL 내부 배치 권장 | |
| D15 | Primary work surface = Cline (or Roo) + local Ollama | Continue 보조만 |
| D21 | **마스터(Master)** = Human 최종 권한자; 단순 커맨드·쉘 실행 가능 | `docs/05_AGENTS/ROLE_SPLIT.md` |

## Forge / Pipeline

| ID | Decision | Notes |
|----|----------|-------|
| D09 | Forge = Core(뇌) + Blender Add-on(손발) 하이브리드 | 단일 모놀리식 금지 |
| D13 | .blend는 Git, 대용량은 LFS, .blend1 등은 gitignore | |
| D14 | 급할수록 돌아간다 — 제작 도구·파이프라인 우선 | |
| D20 | **Canonical Forge path = `projects/excelion-forge/`** | `projects/forge/` = Atlas App-host 실험 스냅샷. 제품 작업은 excelion-forge만. 중첩 스텁 무시. 삭제/이동은 별도 이슈+로컬 |

## Documentation / Knowledge

| ID | Decision | Notes |
|----|----------|-------|
| D10 | 프로젝트 docs: 파일명 영어, 본문 한국어 | PROJECT_DOC_STANDARD |
| D11 | SERA ≠ 프로젝트 목록 | D19로 프로젝트 폐기 |
| D12 | Kraken = 실행·자동화 계층 | 프로젝트 아님 |
| D16 | 대화 기록 → 문서 → 프로젝트 자산 | |
| D19 | **프로젝트 SERA 폐기** | `projects/sera` 금지 |

## Domain Isolation

| ID | Decision | Notes |
|----|----------|-------|
| D17 | Forbidden: `archive/`, `obsidian/`, `node_modules/`, `.git/` | |
| D18 | Context slim: 활성 타겟만 로드 | |

---

## Proposed (G6) — 마스터 승인 대기

Full text: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md`

| Issue | 요약 | Status |
|-------|------|--------|
| [#4](https://github.com/ln9swrd/atlas/issues/4) VERIFY | 프로젝트 샌드박스 격리 | **Draft** |
| [#5](https://github.com/ln9swrd/atlas/issues/5) Kraken | `tools/kraken/` 계층 경로 | **Draft** |
| [#6](https://github.com/ln9swrd/atlas/issues/6) SPRINT-009~029 | archive Knowledge, 활성 TASK 제외 | **Draft** |
| [#7](https://github.com/ln9swrd/atlas/issues/7) Forge Phase 1→2 | excelion-forge only; legacy archive/삭제 | **Draft** |

승인 후 확정 ID(D22…) 부여하고 본 표를 Closed로 옮긴다.

---

## Open → Issues

| 항목 | Issue |
|------|-------|
| VERIFY 코드 범위 | [#4](https://github.com/ln9swrd/atlas/issues/4) |
| Kraken 이름·경로 | [#5](https://github.com/ln9swrd/atlas/issues/5) |
| SPRINT-009~029 상태 | [#6](https://github.com/ln9swrd/atlas/issues/6) |
| Forge Phase 1→2 | [#7](https://github.com/ln9swrd/atlas/issues/7) — **excelion-forge** (D20) |
