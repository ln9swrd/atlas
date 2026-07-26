# ATLAS Repository Hygiene Phase 2 Review

## 1. Reference Analysis

### PROJECT_STATUS.md
- **현재 위치**: 루트 폴더 (`/mnt/d/Atlas/PROJECT_STATUS.md`)
- **참조 위치**: 
  - `README.md`에 프로젝트 상태 링크 포함
  - `PROJECT_EXECUTION_PLAN.md`에서 참조
- **Runtime 의존 여부**: **아니요** (문서 파일)
- **Root 유지 필요성**: **예** (프로젝트 상태 핵심 문서)

### GOAL_REGISTRY.json
- **현재 위치**: 루트 폴더 (`/mnt/d/Atlas/GOAL_REGISTRY.json`)
- **참조 위치**: 
  - `core/registry/goal_registry.py`에서 로드
  - `PROJECT_STATUS.md`에 목표 정의 참조
- **Runtime 데이터 여부**: **예** (시스템 목표 정의)

### config/print_settings.yaml
- **현재 위치**: `config/` 폴더 (`/mnt/d/Atlas/config/print_settings.yaml`)
- **참조 위치**: 
  - `core/review/print_settings.yaml`에서 설정 불러옴
  - `tools/atlas_runner.py`에서 사용
- **적절성 판단**: **예** (환경 설정 파일로 적절)

---

## 2. Move Approval List

- **이동 권장**:  
  - `PROJECT_STATUS.md` → `docs/process/PROJECT_STATUS.md`  
    (참조 파일 유지, 문서화 강화)  
  - `GOAL_REGISTRY.json` → `docs/config/GOAL_REGISTRY.json`  
    (Runtime 데이터 이동 시 문서화 필요)  
  - `config/print_settings.yaml` → `docs/config/print_settings.yaml`  
    (환경 설정 문서화)

- **이동 제한**:  
  - `GOAL_REGISTRY.json`은 Runtime에서 참조 → **이동 전 문서화 필요**

---

## 3. Keep List

- **루트 유지**:  
  - `README.md`, `LICENSE`, `PROJECT_STATUS.md` (이동 전 유지)
  - `GOAL_REGISTRY.json` (이동 전 유지)

- **config 유지**:  
  - `print_settings.yaml` (이동 전 유지)

---

## 4. Delete Approval List

- **삭제 권장**:  
  - `__pycache__/*`, `*.pyc`, `*.bak` (원본 존재 시)  
  - `atlas_current_changes.diff` (이력 파일로 보존 필요)

- **삭제 금지**:  
  - `recovered_docs/*` (Alpha Freeze 보호)  
  - `*.diff` (변경 이력 보존)

---

## 5. Migration Risk

- **이동 위험 요소**:  
  - `PROJECT_STATUS.md` 이동 시 `README.md` 링크 오류 가능성  
  - `GOAL_REGISTRY.json` 이동 시 `core/registry/goal_registry.py` 참조 오류 가능성  
  - `print_settings.yaml` 이동 시 `tools/atlas_runner.py` 설정 오류 가능성

- **추천 조치**:  
  - 이동 전 참조 파일 수정 검토  
  - 이동 후 문서화 및 테스트 검증