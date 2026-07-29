# 006. Next Task 추천 알고리즘 / Priority Engine & Constitution

> **전환**  
> 설계를 더 늘리는 단계 → **설계가 코드에서 유지됨을 증명하는 단계**

---

## 1. Atlas Constitution 핵심 Invariants

| # | Invariant |
|---|-----------|
| 1 | EvidenceGraph는 **immutable** – 생성 후 수정 금지 |
| 2 | Validation은 **deterministic evaluation**만 수행 – Knowledge Layer를 변경하지 않음 |
| 3 | Report는 **projection only** – 기존 Evidence에서 파생 |
| 4 | Runtime state는 **disposable** – 언제든 폐기 가능 |
| 5 | **Knowledge Layer never depends on Runtime Layer** |
| 6 | Rules는 영속 Knowledge이며 Runtime 중 변경되지 않음 |

### 표현 정리
- ❌ "Pure Function" (부정확 – RuntimeContext를 업데이트하므로)
- ✅ **Deterministic Evaluation** – Knowledge Layer를 mutate하지 않는 결정적 평가

---

## 2. 계층 구조

```
Knowledge Layer (immutable domain knowledge)
├── EvidenceGraph
├── RuleRegistry
├── Domain Model
└── Type Definitions

Runtime Layer
├── RuntimeContext          ← 서비스가 공유하는 상태 (Service가 아님)
└── Services
    ├── ValidationService   ← deterministic evaluation
    ├── SchedulerService
    ├── ExecutorService
    ├── CacheService
    └── ProjectionService   ← Report / JSON / Console 투영

Presentation Layer
├── Report
├── UI
└── API
```

**방향**: Knowledge ← Runtime 만 허용. 반대 방향 의존 금지.

---

## 3. Auditor / Specification Lookup 교훈

### 문제
`ls -la`를 PowerShell에서 실행 → `NamedParameterNotFound` → Lookup 실패 → "Specification NOT FOUND"로 오판

### 개선 – Lookup Failure Taxonomy

| 상태 | 의미 | Audit 행동 |
|------|------|-----------|
| FOUND | 명세 발견 | 계속 |
| NOT_FOUND | 실제 파일 없음 | Abort |
| COMMAND_FAILED | 명령 실행 실패 | Retry 또는 Abort |
| IO_ERROR | 접근 실패 | Abort |
| PARSE_ERROR | 읽기 실패 | Abort |

→ "명세가 없다"와 "명세를 읽지 못했다"를 혼동하지 않는다.

---

## 4. Sprint-022 방향 – Architecture Proof of Concept

**목표**: Sprint-021 Invariants를 실제 코드로 증명한다. (새 설계 추가 금지)

| 구현 항목 | 증명 내용 |
|-----------|-----------|
| Immutable EvidenceGraph | Freeze 후 수정 금지, 100회 Validation 후 Hash 동일 |
| RuntimeContext | 삭제 후에도 EvidenceGraph 완전 유지 |
| ValidationService | Graph/Node/Edge 변경 없음, ValidationView[]만 출력 |
| ProjectionService | Projection 삭제 후 동일 Report 재생성 가능 |
| RuleRegistry | Runtime 종료 후에도 동일, Validation이 Rule을 변경하지 못함 |

### Definition of Done
- EvidenceGraph 수정되지 않음
- RuleRegistry 수정되지 않음
- Validation은 계산만 수행
- Runtime은 언제든 폐기 가능
- Projection은 언제든 재생성 가능
- 모든 자동 테스트 통과

---

## 5. 설계 정제 원칙

> **80점 이후의 20점은 비용이 매우 크다.**

- 60→80: 가치 큼
- 80→90: 의미 있음
- 97→99: 며칠을 써도 실제 제품은 거의 달라지지 않음

**멈출 줄 알기**가 프로젝트 성숙의 신호.  
Sprint-021은 Constitution v1.0으로 고정하고, 이후는 구현으로 증명한다.
