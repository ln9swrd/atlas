# ATLAS Beta-001 Agent Registry Standardization Plan

## 1. Current State

- **Manifest Schema**: 필수 필드 정의 완료 (Agent ID, Type, Purpose 등)
- **Capability**: `AUDIT`, `DECISION` 사용 중
- **Permission**: 3단계 구조 (`READ`, `WRITE`, `ADMIN`)
- **Audit Metadata**: `created_by`, `timestamp` 기록 중
- **Index 설계**: 향후 구현 예정

## 2. Improvement Items

### Schema 확장
- **복잡 타입 지원**: nested object/array 포함
- **Version 관리**: `schema_version` 필드 추가 제안

### Lifecycle ENUM
- **단계 확장**: `INITIAL`, `FINAL`, `INTERMEDIATE` 추가 필요

### Capability Naming
- **표준화**: `VALIDATION`, `EXECUTION` 등 추가 역할명 정의
- **Namespace 구분**: `BUSINESS/AUDIT` 형식으로 중복 방지

### Permission Model
- **역할 기반 접근**: `AUDIT_ONLY`, `DECISION_ONLY` 등 추가 권한 제안
- **Scope 기반 권한**: `PROJECT`, `SYSTEM` 등 범위 추가

### Audit Metadata
- **필드 확장**: `last_modified_by`, `version`, `source`, `change_history` 추가

## 3. Future Schema Proposal

```json
{
  "schema_version": "1.0",
  "agent_id": "AGT-001-BUSINESS",
  "agent_type": "BUSINESS",
  "capability": ["BUSINESS/AUDIT", "SYSTEM/DECISION"],
  "lifecycle": "INITIAL",
  "input_schema": {
    "type": "object",
    "properties": { "report": { "type": "string" } },
    "required": ["report"]
  },
  "output_schema": {
    "type": "object",
    "properties": { "decision": { "type": "string" } },
    "required": ["decision"]
  },
  "permission": {
    "level": "READ",
    "scope": "PROJECT"
  },
  "audit": {
    "created_by": "SYSTEM",
    "timestamp": "2026-07-26T10:00:00Z",
    "last_modified_by": "SYSTEM",
    "version": 1,
    "source": "BUSINESS_AGENT_PROFILE.md"
  }
}
```

## 4. Risk

- **역할 중복**: Capability Namespace 정의 미흡 시 중복 가능성
- **Permission 혼란**: Scope 기반 권한 추가 시 설정 복잡성 증가
- **Audit 불완전**: 필드 누락 시 추적 가능성 감소