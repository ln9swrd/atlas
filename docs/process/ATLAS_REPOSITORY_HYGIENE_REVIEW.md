# ATLAS Repository Hygiene Review

## 1. Current Root Analysis

### Root File Inventory
- ** 유지 후보 (A)**:
  - `README.md` (프로젝트 개요)
  - `LICENSE` (라이선스 정보)
  - `PROJECT_STATUS.md` (진행 상태)
  - `GOAL_REGISTRY.json` (목표 정의)

- ** 이동 후보 (B)**:
  - `docs/` 하위 모든 문서 (architecture, process, agents, projects, reports 등)
  - `tools/` 하위 CLI 스크립트 (`atlas_runner.py`, `atlas_status.sh`)

- ** 분석 후보 (C)**:
  - `__pycache__/` (Python 캐시)
  - `*.pyc` (Python 컴파일 파일)
  - `*.bak` (백업 파일)
  - `*.diff` (차이 파일)
  - `recovered_docs/` (복구된 문서)

## 2. File Classification

### A. Root 유지 후보
- **필수 파일**: `README.md`, `LICENSE`, `PROJECT_STATUS.md`
- **설정 파일**: `GOAL_REGISTRY.json`, `config/print_settings.yaml`

### B. docs 이동 후보
- **분류 기준**:
  - **architecture/**: 시스템 설계 문서 (`ATLAS_AGENT_ARCHITECTURE_001.md`)
  - **process/**: 작업 프로세스 (`ATLAS_BETA_001_AGENT_MANIFEST_SCHEMA.md`)
  - **agents/**: Agent 관련 문서 (`BUSINESS_AGENT_PROFILE.md`)
  - **projects/**: 프로젝트 관련 문서 (`printguard/`)
  - **reports/**: 검토/보고서 (`ATLAS_BETA_001_AGENT_REGISTRY_MANIFEST_REVIEW.md`)

### C. 제거 후보 분석
- **대상**:
  - `__pycache__/*` (Python 캐시 파일)
  - `*.pyc` (Python 컴파일 파일)
  - `*.bak` (백업 파일)
  - `*.diff` (변경 기록 파일)
  - `recovered_docs/*` (복구된 문서, Alpha Freeze 보호 필요)

- **삭제 여부 판단**:
  - `__pycache__/*`: **삭제 권장** (자동 생성 파일)
  - `*.pyc`: **삭제 권장** (컴파일 파일)
  - `*.bak`: **삭제 권장** (백업 파일, 원본 존재 시)
  - `*.diff`: **보존 필요** (변경 이력 기록)
  - `recovered_docs/*`: **보존 필요** (Alpha Baseline 보호)

## 3. Move Candidates

- **docs/ 이동 계획**:
  - `PROJECT_STATUS.md` → `docs/process/PROJECT_STATUS.md`
  - `GOAL_REGISTRY.json` → `docs/config/GOAL_REGISTRY.json`
  - `config/print_settings.yaml` → `docs/config/print_settings.yaml`

- **이동 시 주의 사항**:
  - 기존 `docs/` 하위 파일과의 중복 확인 필요
  - 이동 후 기존 루트 파일은 삭제 또는 비활성화 처리

## 4. Cleanup Candidates

- **제거 후보 목록**:
  - `__pycache__/*`
  - `*.pyc`
  - `*.bak` (원본 존재 시)
  - `recovered_docs/*` (Alpha Freeze 보호로 보존)

- **삭제 시 주의 사항**:
  - `recovered_docs/*`: **Alpha Baseline 보호**로 삭제 금지
  - `*.diff`: 변경 이력 보존 필요 (삭제 금지)

## 5. Migration Risk

- **주요 위험 요소**:
  - **루트 파일 이동 후 기존 참조 오류**: `PROJECT_STATUS.md` 이동 시 빌드/CLI 스크립트 참조 오류 가능성
  - **이동 파일의 중복**: `docs/` 하위에 동일한 이름의 파일 존재 시 덮어쓰기 위험
  - **Alpha Baseline 파일 손상**: `recovered_docs/*` 삭제 시 데이터 손실 가능성

## 6. Recommended Execution Order

1. **이동 작업**:
   - `PROJECT_STATUS.md` → `docs/process/PROJECT_STATUS.md`
   - `GOAL_REGISTRY.json` → `docs/config/GOAL_REGISTRY.json`
   - `config/print_settings.yaml` → `docs/config/print_settings.yaml`

2. **정리 작업**:
   - `__pycache__/*` 삭제
   - `*.pyc` 삭제
   - `*.bak` 삭제 (원본 존재 시)

3. **검토 작업**:
   - `docs/` 하위 파일 중복 확인
   - `recovered_docs/*` 보존 상태 확인