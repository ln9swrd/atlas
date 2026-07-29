# 007. Context Memory / Auditor MVP & Specification-bound Audit

> **전환**  
> Runtime 개발 완료 → **Runtime을 검증하는 Auditor 개발** 단계

---

## 1. Sprint-003 : Atlas Auditor MVP

### Scope
- **대상**: Atlas Runtime의 실행 결과를 검증
- **대상이 아닌 것**: Runtime 기능 추가, Planner 개선, Constitution 변경

> Runtime은 Black Box. Auditor는 Runtime의 출력만 보고 검증한다.

### Auditor Pipeline
```
Artifacts
    ↓
Artifact Discovery      ← 판단·추론·평가 금지, 수집만
    ↓
Observation Extraction  ← 사실(Facts)만 추출, 추론 금지
    ↓
Rule Verification       ← Observation + Rule → Pass / Warning / Fail
    ↓
Audit Report Generation ← Summary / Violations / Evidence / Recommendations
```

### 핵심 원칙
> **Observe First. Reason Second. Verify Third. Decide Last.**

각 단계의 입력·출력이 명확히 분리되고, 단방향으로만 흐른다.  
Discovery는 Verification을 모르고, Verification은 파일 시스템을 직접 읽지 않는다.

### Python 모듈 구조 (Reference)
```
atlas_auditor/
├── discovery/     (artifact_discovery, artifact_types)
├── observation/   (extractor, observation, parsers)
├── verification/  (verifier, rules, violations, evidence)
├── reporting/     (report_generator, report_models)
└── auditor.py     ← 오케스트레이터만
```

---

## 2. Auditor 성숙 경로

| Sprint | 핵심 |
|--------|------|
| 015 | Claim / Evidence 분리 |
| 016 | PASS 남발 방지 → UNVERIFIABLE 허용 |
| 017 | 반증 중심 사고 |
| 018 | **Specification-bound Audit** – Missing Evidence는 명세에 있는 것만 |
| 019 | **Jurisdiction Validation** – 명세 없으면 AUDIT ABORTED |
| 020 | **Specification Lookup as First-Class Evidence** – Lookup 과정 자체가 Evidence |

---

## 3. Specification-bound Audit (Sprint-018)

> 감사자는 명세에 존재하는 요구사항만 Missing Evidence로 선언할 수 있다.  
> 새 규칙을 만들지 않는다.

```
Missing Evidence
  → 반드시 Specification ID 참조
  → 예: SPEC-001 Expected Output Hash
  → 명세에 없으면 생성 금지
```

---

## 4. Jurisdiction Validation (Sprint-019)

```
Stage 0: Jurisdiction Check

Specification 존재?
  ├── YES → 다음 단계 (Claim Evaluation)
  └── NO  → AUDIT ABORTED
              Reason: No governing specification.

명세가 없으면 PASS / FAIL / UNVERIFIABLE 모두 금지.
감사관은 "권한이 없다"고 선언한다.
```

실제 ISO 감사도 첫 단계는 "Applicable Standard?"이다.

---

## 5. Specification Lookup as Evidence (Sprint-020)

```
Specification Lookup
  - requested specification
  - lookup result
  - lookup evidence id

Lookup 실패 시:
  Create Observation → Create Evidence → Abort Audit

금지: Lookup 없이 바로 AUDIT ABORTED
감사관은 Lookup을 시도했다는 것을 증명해야 한다.
```

Lookup Failure Taxonomy:
| 상태 | 의미 |
|------|------|
| FOUND | 명세 발견 |
| NOT_FOUND | 실제 파일 없음 |
| COMMAND_FAILED | 명령 실행 실패 |
| IO_ERROR / PARSE_ERROR | 접근·읽기 실패 |

---

## 6. 현재 진행률 (당시)

```
Execution Separation   ██████████
Evidence Ledger        ██████████
Claim Trace            ██████████
Negative Audit         ██████████
Specification Bound    █████████░
Jurisdiction           █████████░
Specification Lookup   ████░░░░░░
```

약 **95~97%**.  
"증거를 보고 판단하는 모델"은 거의 완성. 남은 것은 **헌법(명세)에 묶여서만 판단하는 감사관**으로 마무리하는 단계.
