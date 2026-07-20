# Atlas Markdown Cleanup Analysis

## Summary

검토 결과 **17개의 `atlas*.md` 파일 중 6개는 중복이거나 삭제 가능**합니다. 이를 정리하면 불필요한 문서 로드를 줄일 수 있습니다.

---

## 🗑️ **삭제 권장 문서 (6개)**

### 1. **중복 결정 로그 (3개 중 2개 삭제)**
이 3개 파일은 거의 동일한 내용을 반복합니다:
- `ATLAS_SPRINT_021_DECISION_LOG.md`
- `ATLAS_SPRINT_021_DECISIONS.md`
- `ATLAS_DECISION_LOG_SPRINT_021.md`

**결정:** 
- **유지**: `ATLAS_SPRINT_021_DECISION_LOG.md` (가장 명확한 이름)
- **삭제**: `ATLAS_SPRINT_021_DECISIONS.md`, `ATLAS_DECISION_LOG_SPRINT_021.md`

**근거**: 3개 파일 모두 동일한 Architecture 결정 내용 (Evidence Graph Immutability, Runtime Context Separation, Validation System Design 등)을 반복합니다.

---

### 2. **중복 아키텍처 결정 (2개 중 1개 삭제)**
- `ATLAS_SPRINT_021_ARCHITECTURE_DECISIONS.md`
- `ATLAS_SPRINT_021_DECISION_LOG.md` (위에서 유지하기로 결정)

**결정:**
- **삭제**: `ATLAS_SPRINT_021_ARCHITECTURE_DECISIONS.md` (DECISION_LOG에 포함됨)

---

### 3. **중복 MVP 요약 (2개 중 1개 삭제)**
- `ATLAS_RUNTIME_MVP_SUMMARY.md`
- `ATLAS_RUNTIME_MVP_COMPLETE.md`

**결정:**
- **유지**: `ATLAS_RUNTIME_MVP_COMPLETE.md` (더 명확한 최종 상태 표시)
- **삭제**: `ATLAS_RUNTIME_MVP_SUMMARY.md`

**근거**: 둘 다 동일한 MVP 구현 내용 (Observation, Inference, Verification, Evidence, Decision 클래스)을 설명합니다.

---

## ✅ **유지 권장 문서 (11개)**

| 파일명 | 목적 | 설명 |
|--------|------|------|
| `ATLAS_CONSTITUTION.md` | 기본 원칙 | Atlas의 6가지 핵심 원칙과 운영 규칙 정의 (삭제 불가) |
| `ATLAS-ARCH-001_ARCHITECTURE_MODEL.md` | 아키텍처 모델 | Knowledge Domain과 Runtime Domain의 개념적 관계 정의 |
| `ATLAS-INT-001_INTERACTION_MODEL.md` | 상호작용 모델 | Domain 간 4가지 상호작용 타입 정의 (Provider-Consumer, Requester-Responder 등) |
| `ATLAS_SPRINT_021_DECISION_LOG.md` | 아키텍처 결정 | Sprint 021의 핵심 아키텍처 결정 기록 |
| `ATLAS_SPRINT_021_ARCHITECTURAL_FOUNDATION.md` | 아키텍처 기초 | Evidence Graph와 Runtime Context의 구현 세부사항 |
| `ATLAS_SPRINT_021_TECHNICAL_DOCS.md` | 기술 문서 | Python 코드 예시를 포함한 기술 구현 세부사항 |
| `ATLAS_SPRINT_021_COMPREHENSIVE_SUMMARY.md` | 종합 요약 | Knowledge/Runtime 레이어 분리와 아키텍처 불변성 요약 |
| `ATLAS_RUNTIME_MVP_COMPLETE.md` | MVP 완성 | 검증 시스템 구현 완료 상태 기록 |
| `atlas_system_comprehensive_summary.md` | 시스템 종합 요약 | Constitutional Framework와 규칙 구현 개요 |
| `atlas_verification_plan.md` | 검증 계획 | 성능 개선 검증 방법론과 기준 정의 |
| `atlas_complete_workflow.md` | 워크플로우 예시 | Observation → Decision까지의 완전한 검증 워크플로우 |

**유지 이유:**
- 각 문서가 서로 다른 관점에서 아키텍처와 규칙을 설명
- Atlas의 설계 철학과 구현 기초를 이해하는 데 필요
- 미래 기여자를 위한 참고 자료

---

## 🚨 **특수 문서**

### `atlas_decision_log.md`
- **내용**: Conversation Summary 성능 분석 (대화 요약 기능의 구체적 의사결정)
- **결정**: **유지** - Sprint 021 일반 아키텍처와는 다른 구체적 구현 결정 기록
- **위치**: 현재 `docs/atlas/` (O)

---

## 📋 **정리 실행 명령어**

```bash
# 삭제 권장 파일
git rm docs/atlas/ATLAS_SPRINT_021_DECISIONS.md
git rm docs/atlas/ATLAS_DECISION_LOG_SPRINT_021.md
git rm docs/atlas/ATLAS_SPRINT_021_ARCHITECTURE_DECISIONS.md
git rm docs/atlas/ATLAS_RUNTIME_MVP_SUMMARY.md

# 결과: 17개 → 13개 파일로 축소
```

---

## 📊 **최종 레이아웃**

```
docs/atlas/
├── ATLAS_CONSTITUTION.md                     (기본 원칙)
├── ATLAS-ARCH-001_ARCHITECTURE_MODEL.md      (아키텍처 모델)
├── ATLAS-INT-001_INTERACTION_MODEL.md        (상호작용 모델)
├── ATLAS_SPRINT_021_DECISION_LOG.md          (Sprint 결정)
├── ATLAS_SPRINT_021_ARCHITECTURAL_FOUNDATION.md (기초)
├── ATLAS_SPRINT_021_TECHNICAL_DOCS.md        (기술 문서)
├── ATLAS_SPRINT_021_COMPREHENSIVE_SUMMARY.md (종합 요약)
├── ATLAS_RUNTIME_MVP_COMPLETE.md             (MVP 완성)
├── atlas_system_comprehensive_summary.md     (시스템 요약)
├── atlas_verification_plan.md                (검증 계획)
├── atlas_decision_log.md                     (Conversation Summary 결정)
└── atlas_complete_workflow.md                (워크플로우 예시)

총 12개 파일 (4개 삭제로 25% 감소)
```

---

## ✨ **정리의 이점**

1. **문서 관리 복잡도 감소**: 중복 제거로 유지보수 부담 ↓
2. **검색 효율성 증가**: 필요한 문서를 더 쉽게 찾을 수 있음
3. **구조 명확성**: 각 문서의 역할이 명확함
4. **자동화 친화적**: 문서 인덱싱과 참고 체계 간결화
