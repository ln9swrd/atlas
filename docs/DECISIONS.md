# Atlas Decision Log

Source: `obsidian/Archive/Original Conversations/ANALYSIS_REPORT.md` (Phase 3)
Status: Extracted candidates promoted to living log (2026-07-30)

Format: ID | Decision | Notes

---

## Core Principles

| ID | Decision | Notes |
|----|----------|-------|
| D01 | **Claim ≠ Evidence** (Evidence-First) | DONE 보고 전 CLI/파일/테스트 증거 필수 |
| D02 | **Build the system that builds the game** | Atlas는 제품이 아니라 제품을 만드는 운영 체계 |
| D03 | Knowledge Layer ↔ Runtime Layer 분리 | 안정 지식은 Git docs/ADR, 세션 런타임은 폐기 가능 |
| D04 | Environment 분리·등록 (Registry) | DEV_WORK / DEV_HOME 등 환경별 제약 반영 |
| D05 | 기능 추가보다 실제 운영 시나리오 검증 우선 | ROI Gate: 2회 이상 반복 또는 30분 이상 단축 검증 |
| D06 | 가상 Task보다 실제 Exelion Task로 운영 | 실 프로젝트 태스크로 루프 검증 |

## Agent / Local LLM

| ID | Decision | Notes |
|----|----------|-------|
| D07 | Cline 문제 추적 중 Subagents / Native / Parallel Tool Call OFF | 로컬 모델 안정화 우선 |
| D08 | 로컬 AI는 WSL 내부 배치 권장 | Windows 호스트 직접보다 WSL 권장 |
| D15 | Primary work surface = Cline (or Roo) + local Ollama | Continue는 보조만; 커스텀 확장 전체 에이전트화 금지 |

## Forge / Pipeline

| ID | Decision | Notes |
|----|----------|-------|
| D09 | Forge = Core(뇌) + Blender Add-on(손발) 하이브리드 | 단일 모놀리식 금지 |
| D13 | .blend는 Git, 대용량은 LFS, .blend1 등은 gitignore | 에셋 버전 관리 규칙 |
| D14 | 급할수록 돌아간다 — 제작 도구·파이프라인 우선 | 단기 편의 기능보다 파이프라인 안정 |

## Documentation / Knowledge

| ID | Decision | Notes |
|----|----------|-------|
| D10 | 프로젝트 docs: 파일명 영어, 본문 한국어, 필수 VISION/ROADMAP/CHANGELOG | PROJECT_DOC_STANDARD |
| D11 | SERA = 프로젝트 목록이 아니라 Atlas 지능 계층 | 계층 경계 명확화 |
| D12 | Kraken = 실행·자동화 계층 | SERA와 역할 분리 |
| D16 | 대화 기록 → 문서 → 프로젝트 자산 | Original Conversations → Named → Core 승격 경로 |

## Domain Isolation

| ID | Decision | Notes |
|----|----------|-------|
| D17 | Forbidden domain: `archive/`, `obsidian/`, `node_modules/`, `.git/` | 자동 컨텍스트 주입 금지 |
| D18 | Context slim: 활성 타겟만 로드 | `state/CURRENT_STATE.md` 기준 |

---

## Open (아직 확정 전)

- VERIFY 실제 코드 구현 범위
- SPRINT-009~029 설계의 구현·폐기·보관 상태
- SERA / Kraken 코드·디렉터리 경계 최종화
- Forge Phase 1→2 전환 기준

이 항목들은 `ANALYSIS_REPORT.md` Open Questions를 이슈로 등록 후 확정한다.
