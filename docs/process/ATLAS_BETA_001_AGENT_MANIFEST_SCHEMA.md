# ATLAS Beta-001 Agent Manifest Schema Design

## 1. Agent Manifest 필요성 분석

ATLAS Agent Registry에 Manifest 계약이 필요한 이유:

- **Agent Identity 관리 필요성**: 중복/분리된 Agent 식별을 위해 고유 ID와 타입 정의 필요
- **Capability 검증 필요성**: Agent의 기능 범위 명확화를 통한 시스템 안정성 확보
- **Lifecycle 연결 필요성**: 프로젝트 단계와 Agent 역할 매핑을 위한 위치 정의
- **Audit 추적 필요성**: 모든 변경사항의 기원과 책임 소재 명시를 통한 투명성 확보

---

## 2. Agent Manifest Schema 정의

### Required Fields

| 항목 | 목적 | 필수 여부 | 데이터 형태 | 검증 기준 | 예시 |
|------|------|-----------|-------------|------------|------|
| **Agent ID** | 고유 식별자 | ✅ | UUID | 32자 길이, 알phanum | `AGT-001-BUSINESS` |
| **Agent Type** | 역할 분류 | ✅ | ENUM | `BUSINESS`, `SYSTEM` | `BUSINESS` |
| **Agent Purpose** | 기능 목적 | ✅ | STRING | 50자 이내 | "프로젝트 검증 및 피드백 수집" |
| **Capability List** | 지원 기능 | ✅ | ARRAY | `["AUDIT", "DECISION"]` | `["AUDIT", "DECISION"]` |
| **Lifecycle Position** | 프로젝트 단계 | ✅ | ENUM | `INITIAL`, `FINAL` | `INITIAL` |
| **Input Schema** | 입력 데이터 형식 | ✅ | JSON Schema | 유효성 검증 가능 | `{ "type": "object", "properties": { "report": { "type": "string" } } }` |
| **Output Schema** | 출력 데이터 형식 | ✅ | JSON Schema | 유효성 검증 가능 | `{ "type": "object", "properties": { "decision": { "type": "string" } } }` |
| **Permission Level** | 접근 권한 | ✅ | ENUM | `READ`, `WRITE`, `ADMIN` | `READ` |
| **Audit Metadata** | 변경 추적 정보 | ✅ | OBJECT | `{"created_by": "SYSTEM", "timestamp": "2026-07-26T10:00:00Z"}` | `{"created_by": "SYSTEM", "timestamp": "2026-07-26T10:00:00Z"}` |

---

## 3. Business Agent Manifest Draft

### Identity
- **Agent ID**: `AGT-001-BUSINESS`
- **Agent Type**: `BUSINESS`
- **Agent Purpose**: "프로젝트 검증 및 피드백 수집"

### Capability
- **Capability List**: `["AUDIT", "DECISION"]`

### Lifecycle
- **Lifecycle Position**: `INITIAL`

### Input
- **Input Schema**: 
  ```json
  {
    "type": "object",
    "properties": {
      "report": { "type": "string" }
    },
    "required": ["report"]
  }
  ```

### Output
- **Output Schema**: 
  ```json
  {
    "type": "object",
    "properties": {
      "decision": { "type": "string" }
    },
    "required": ["decision"]
  }
  ```

### Permission
- **Permission Level**: `READ`

### Audit
- **Audit Metadata**: 
  ```json
  {
    "created_by": "SYSTEM",
    "timestamp": "2026-07-26T10:00:00Z"
  }
  ```

> **주의**: `BUSINESS_AGENT_PROFILE.md`에 명시되지 않은 정보는 `UNKNOWN` 처리됨.

---

## 4. Validation Rule 정의

### PASS 조건
- Agent ID 존재
- Agent Type 정의
- Capability 정의
- Lifecycle 위치 정의

### WARNING 조건
- Input/Output Schema 상세 부족
- Permission Level 미정
- Audit Metadata 부족

### FAIL 조건
- 책임 범위 불명확
- Capability 없음
- Input/Output 정의 없음

---

## 5. PrintGuard 관계 정의

```
Business Agent
  ↓
Project Candidate
  ↓
PrintGuard
```

> **주의**: PrintGuard 구현 상태는 현재 생성 금지.

---