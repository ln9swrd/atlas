# ATLAS_AUDIT_BASELINE.md

## 1. Audit Mode 정의
- **Audit Mode는 검증 전용 workflow**
- Runtime 기능과 **완전히 분리**
- **파일 수정 금지**
- **증거 없는 판단 금지**

## 2. Evidence Classification

### EXISTS:
- filesystem 존재 확인 (예: `docs/README.md`)

### IMPLEMENTED:
- 파일 존재 + 코드 구현 확인 (예: `core/execution/environment_resolver.py`)

### VERIFIED:
- 실행 또는 테스트 결과 확인 (예: `tests/test_environment_resolver.py`)

### MISSING:
- 존재하지 않음 확인 (예: `core/audit.py`)

### UNKNOWN:
- 접근 불가 또는 검증 불충분 (예: `runtime mode switching`)

## 3. Report Format

| 항목 | 형식 |
|------|------|
| **Command** | 명령어 명시 (예: `git diff`) |
| **Output** | 명령 실행 결과 (예: `No such file`) |
| **Interpretation** | 결과 해석 (예: `파일 누락`) |
| **Confidence** | 신뢰도 수준 (예: `LOW` / `MEDIUM` / `HIGH`) |

## 4. 현재 확인 상태

### ✅ Verified:
- `cline instruction AUDIT MODE RULES` 추가 완료

### ❌ Missing:
- `core/audit.py`
- `audit runtime engine`

### ⚠️ Unknown:
- `runtime mode switching`
- `audit automation`

## 5. 원칙

- **문서 존재 ≠ 구현 완료**
- **파일 존재 ≠ 동작 검증 완료**
- **설계 문서 ≠ Runtime 기능**