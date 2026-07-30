# Atlas Concept Glossary

Source: Original Conversations analysis + current repo docs
Updated: 2026-07-30 (D19: project SERA deprecated)

---

## Core

| Term | Definition |
|------|------------|
| **Atlas** | AI와 사람이 재현·검증 가능한 방식으로 협업하기 위한 디지털 작업 기반(DevOS). 단일 제품이 아니라 프로젝트를 올리는 운영 체계. |
| **Evidence-First** | Claim ≠ Evidence. 완료 보고 전 반드시 검증 가능한 증거를 남긴다. |
| **Knowledge Layer** | 안정적인 지식(문서, ADR, 규칙). Git에 저장. |
| **Runtime Layer / RuntimeContext** | 세션 실행 컨텍스트. 폐기 가능. Knowledge와 분리. |
| **DevOS** | Development Operating System — Atlas의 자기 규정. |

## Execution

| Term | Definition |
|------|------------|
| **Priority Engine** | 태스크 우선순위 추천 엔진 (`core/execution/priority_engine.py`). |
| **Runner / atlas_runner** | 실행 루프 CLI (`tools/atlas_runner.py`). start/next/end/finish/simulate. |
| **Environment Registry** | 작업 환경(DEV_WORK, DEV_HOME 등) 등록·해석. |
| **Goal Registry** | 목표 등록·추적. |
| **Rule Engine** | 규칙 기반 검증 (`core/rules/`). |
| **Review Engine** | 결과 리뷰·스코어카드 (`core/review/`). |

## Agents & Surfaces

| Term | Definition |
|------|------------|
| **Cline** | 현재 Primary work surface (VS Code agent + tools). |
| **Roo** | Cline 실패 시 fallback agent. |
| **Continue** | 선택적 autocomplete/chat 전용. 메인 에이전트 아님. |
| **Ollama** | 로컬 LLM 호스트. 권장 `num_ctx` ≥ 32768. |
| **Cloud AI (mode)** | 클라우드 측 설계·분석 모드. **프로젝트가 아님.** 과거 문서의 SERA 프로젝트와 혼동 금지. |

## Layers (conceptual)

| Term | Definition |
|------|------------|
| **SERA (legacy term)** | 과거: 독립 프로젝트 또는 지능 계층으로 혼용. **D19: 프로젝트 지위 폐기.** 신규 작업에 프로젝트명으로 쓰지 않음. |
| **Kraken** | 실행·자동화 계층 (프로젝트 아님). |
| **Forge** | Core(뇌) + Blender Add-on(손발) 하이브리드 파이프라인. |

## Projects (active registry)

| Term | Definition |
|------|------------|
| **Exelion / Excelion** | 메카닉/게임 관련 도메인 프로젝트. |
| **Excelion Forge** | Blender 리그 검증·파이프라인 도구. |
| **PrintGuard** | 비즈니스/3D프린팅 관련 하위 프로젝트. |
| **Coin-S** | 암호화폐 관련 실험 (Atlas 연동 수준 낮음). |
| ~~**SERA (project)**~~ | **폐기 (D19).** |

## Process

| Term | Definition |
|------|------------|
| **VERIFY** | 검증 스프린트/체크 흐름. |
| **SPRINT-*** | 번호 붙은 설계·개선 단위 (예: SPRINT-009 Self-Improvement). |
| **PROJECT_DOC_STANDARD** | 파일명 영어, 본문 한국어, VISION/ROADMAP/CHANGELOG 필수. |
| **ROI Gate** | 자동화 추가 조건: 2회 이상 반복 또는 30분 이상 단축 검증. |
| **Named Conversations** | Original Conversations를 주제명으로 정리한 사본. |
| **Original Conversations** | 0.md~86.md 원본 대화 아카이브. |

## Domain Isolation

| Term | Definition |
|------|------------|
| **System Domain** | `AGENTS.md`, `state/`, `tools/` |
| **Project Domain** | `projects/<active>/` |
| **Forbidden (BLACK)** | `archive/`, `obsidian/`, `node_modules/`, `.git/` — 자동 컨텍스트 금지 |
