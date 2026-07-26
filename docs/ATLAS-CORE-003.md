# ATLAS-CORE-003: Context Lifecycle Management

## 1. 목적
Context의 생성, 변경, 유지, 폐기, 보존 등의 **전 생애 주기**를 정의하고, Atlas 시스템 내에서의 상태 변화 규칙을 명확히 합니다.  
(IMPLEMENTED: `core/context/` 디렉토리 기반)

---

## 2. Context Lifecycle 상태 정의
**PROPOSED**  
```text
CREATED
   |
ACTIVE
   |
UPDATED
   |
VALIDATED
   |
ARCHIVED
   |
RETIRED
```

### 상태별 의미
| 상태      | 설명                                                         |
|-----------|--------------------------------------------------------------|
| CREATED   | Context 생성 완료 (초기화 상태)                            |
| ACTIVE    | 현재 작업 중인 상태 (수정/검증 가능)                       |
| UPDATED   | 내용 수정 후 상태 (변경 기록 보존)                         |
| VALIDATED | 검증 완료 상태 (프로젝트 검토/결정 단계)                   |
| ARCHIVED  | 더 이상 사용되지 않지만 보존 필요 (예: 프로젝트 종료 후)   |
| RETIRED   | 완전히 폐기 (보존 필요 없음)                               |

---

## 3. Context Versioning
**PROPOSED**  
- **목표**: 기존 기록을 덮어쓰지 않고, 각 버전을 독립된 엔티티로 관리  
- **구조**:
  ```
  context-001
  ├── v1 (최초 생성)
  ├── v2 (Decision 변경 반영)
  ├── v3 (Audit 결과 반영)
  ```

- **원칙**:  
  > "경험은 삭제하지 않고 축적한다."  
  - 모든 변경 기록은 버전별로 보존  
  - 최종 결정/검증 시점의 버전이 '활성' 상태로 유지  

---

## 4. Context Ownership 정의
**PROPOSED**  
- **소유자 책임 구조**:
  ```text
  Project
   |
   +-- Context Manager
        |
        +-- Task Context (Task 생성자 소유)
        +-- Decision Context (Decision 생성자 소유)
        +-- Audit Context (Audit Engine 소유)
  ```

- **권한 범위**:
  - Task Context: 해당 Task 생성자 및 관리자만 수정 가능  
  - Decision Context: 해당 Decision 생성자 및 검토자만 수정 가능  
  - Audit Context: Audit Engine만 생성/수정 가능  

---

## 5. Context Retention 정책
**PROPOSED**  
- **프로젝트 종료 후 처리**:
  ```text
  Project 종료
      |
      +-- Source Archive (원본 저장소 보존)
      |
      +-- Context Archive (Context 데이터 보존)
      |
      +-- Decision History (결정 기록 보존)
  ```

- **보존 기준**:
  - 모든 Context는 최소 3년간 보존 (법적/기술적 요구사항에 따라 조정)  
  - RETIRED 상태의 Context는 1년간 보존 후 완전 삭제  

---

## 6. 제외 범위
**EXIST**  
- AI 자동 기억 생성 (ATLAS-CORE-006 이후)  
- Vector Memory, Self Learning Loop (ATLAS-CORE-004 이후)  
- Provider 연결 (ATLAS-CORE-005 이후)  
- 분산 저장 (ATLAS-CORE-004 이후)  

---

## 7. 이후 문서 흐름
```text
ATLAS-CORE-003
Context Lifecycle Management
        |
        v
ATLAS-CORE-004
Context Resolver Architecture
        |
        v
ATLAS-CORE-005
Provider Context Integration
        |
        v
ATLAS-CORE-006
Runtime Context Execution
```

> "프로젝트는 소멸해도 Atlas는 계속 성장한다"는 개념이 **ATLAS-CORE-003의 Retention & Archive 정책**에서 처음 구현됩니다.