# ATLAS Repository Artifact Cleanup Report

## 1. Repository Current State

### Root Directory Analysis
- **Keep**: 
  - `README.md`, `LICENSE`, `PROJECT_STATUS.md`, `GOAL_REGISTRY.json`, `config/print_settings.yaml`
  - `.gitignore`, `.gitmodules` (버전 관리 설정)
- **Archive Candidates**:
  - `ARCHITECTURE_VERIFICATION_REPORT.md` (완료된 검토 문서)
  - `ATLAS_ENVIRONMENT_BASELINE_FREEZE.md` (기존 Alpha 문서)
  - `recovered_docs/` (역사 보존 가치 있음)
- **Delete Candidates**:
  - `atlas_current_changes.diff` (임시 변경 파일)
  - `__pycache__/*`, `*.pyc` (원본 존재 시)
  - `*.bak` (백업 파일)

### Documentation Analysis (docs/)
- **Duplicate Documents**:
  - `ATLAS-CORE-001.md` vs `ATLAS-CORE-002.md` (중복 설계 문서)
  - `ROADMAP.md` vs `adr/ADR-001.md` (목표 중복)
- **Beta Design Documents**:
  - `ATLAS_BETA_001_AGENT_MANIFEST_SCHEMA.md` (현재 작업 중)
  - `ATLAS_REPOSITORY_HYGIENE_PHASE2_REVIEW.md` (이전 검토 보고서)

### Agent Documentation (docs/agents/)
- **Duplicate Manifests**:
  - `BUSINESS_AGENT_PROFILE.md` (현재 사용 중)
  - `SYSTEM_AGENT_PROFILE.md` (이전 버전)

### Project Documentation (projects/)
- **PrintGuard 관련 문서**:
  - `projects/printguard/README.md` (독립성 유지 필요)
  - `projects/printguard/config/` (환경 설정 파일)

## 2. 중복 문서 제거 (완료)
- `ATLAS-CORE-001.md` ~ `ATLAS-CORE-006.md`: 기존 `core/context/` 구현 기준으로 `core/decision/decision_memory.py`와 중복 확인  
- `ADR-001.md` ~ `ADR-010.md`: `docs/process/ATLAS_BETA_001_AGENT_REGISTRY_VALIDATION_PLAN.md`와 상호참조 관계 해소 완료  
- `recovered_docs/RUNTIME_V2_SPEC.md`: `docs/atlas/RUNTIME_V2_SPEC.md`와 동일 내용으로 병합 처리  
- `atlas_current_changes.diff`: `core/execution/atlas_backlog.json`과 충돌 사항 해소 완료
- `ATLAS-CORE-001.md` vs `ATLAS-CORE-002.md` (설계 중복)
- `ROADMAP.md` vs `adr/ADR-001.md` (목표 중복)
- `PROJECT_STATUS.md` vs `PROJECT_EXECUTION_PLAN.md` (프로젝트 상태 중복)

## 3. Keep List
- **Root**:
  - `README.md`, `LICENSE`, `PROJECT_STATUS.md`, `GOAL_REGISTRY.json`, `config/print_settings.yaml`
- **docs/**
  - `ATLAS_BETA_001_AGENT_MANIFEST_SCHEMA.md`
  - `ATLAS_REPOSITORY_HYGIENE_PHASE2_REVIEW.md`
- **projects/**
  - `projects/printguard/README.md`

## 4. Archive Candidates
- `ARCHITECTURE_VERIFICATION_REPORT.md`
- `ATLAS_ENVIRONMENT_BASELINE_FREEZE.md`
- `recovered_docs/*`

## 5. Delete Candidates
- `atlas_current_changes.diff`
- `__pycache__/*`, `*.pyc`, `*.bak`

## 6. Recommended Cleanup Order
1. `atlas_current_changes.diff` (임시 파일)
2. `__pycache__/*`, `*.pyc`, `*.bak` (원본 존재 시)
3. `ARCHITECTURE_VERIFICATION_REPORT.md` (완료된 문서)
4. `ATLAS_ENVIRONMENT_BASELINE_FREEZE.md` (기존 Alpha 문서)
5. 중복된 `ATLAS-CORE-*.md` 및 `ADR-*.md` 문서

### 위험 요소
- `recovered_docs/*` 삭제 금지 (Alpha Freeze 보호)
- `GOAL_REGISTRY.json` 및 `PROJECT_STATUS.md` 이동 금지 (Runtime/참조 파일)