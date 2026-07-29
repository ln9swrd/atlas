# 005. Atlas DevOS – 전체 아키텍처 및 구현 로드맵

> **Core Architectural Decision**  
> **Knowledge Layer**와 **Runtime Layer**를 완전히 분리한다.

---

## 1. 두 계층의 분리

### Knowledge Layer (지식 계층) = Atlas의 두뇌

**"무엇을 해야 하는가"**를 정의한다.

| 포함 | 특징 |
|------|------|
| Goal, Sprint, Rule, Workflow | 거의 변경되지 않는 장기 지식 |
| Template, Pattern, Best Practice | Git으로 관리 |
| Architecture Decision, Documentation | 사람이 읽기 쉽고, LLM이 참고하는 기준 |

### Runtime Layer (실행 계층) = Atlas의 신경계

**"지금 실제로 무엇이 일어나고 있는가"**를 관리한다.

| 포함 | 특징 |
|------|------|
| Current Task, Conversation State | 계속 변함 |
| 진행률, Audit Result, Cache | 세션마다 달라짐 |
| Working Memory, Todo, Active Context | 실행 중 생성, 종료 후 일부만 남음 |

### 분리 효과

1. **재현성** – 같은 Goal이면 항상 같은 Rule을 읽음
2. **안정성** – 실행 중 버그가 생겨도 Knowledge는 손상되지 않음
3. **감사 가능성** – Knowledge Version → Runtime Log → Output 추적
4. **다중 Runtime** – GPT / Claude / Qwen이 동일한 Rule을 공유하면서 각자의 State만 유지
5. **확장성** – 여러 에이전트가 하나의 지식 저장소를 공유 가능

Runtime은 Knowledge를 **읽기만** 한다. Knowledge는 Runtime 때문에 바뀌지 않는다.

---

## 2. Evidence-Grounded Operation 원칙

> **Agent Claim은 Repository Evidence가 아니다.**

### 금지 표현 (증거 없이 사용 금지)
- "파일을 생성했다"
- "구현이 완료됐다"
- "테스트가 통과했다"
- "검증됐다" / "CLOSED다"

### 허용 상태 분류
```
EXISTS / CREATED / MODIFIED / READ_VERIFIED
EXECUTED / TESTED / VERIFIED
UNVERIFIED / MISSING / FAILED / BLOCKED / CLAIMED
```

### 작업 강제 순서
```
INSPECT → CREATE/MODIFY → EXISTS CHECK → READ-BACK
→ EXECUTE → TEST → RECORD EVIDENCE → CLASSIFY STATUS
```

---

## 3. 두 계층 검증 모델

### Layer A – Development Verification
- 파일이 실제로 존재하는가?
- 생성·수정·실행·테스트가 실제로 수행되었는가?
- 실행 결과는 무엇인가?

### Layer B – System Verification
- 문법·어휘·온톨로지·타입·논리가 일관적인가?
- Self-Description이 가능한가?
- Circular Dependency가 없는가?

**두 계층의 결과를 절대 혼합하지 않는다.**  
파일이 존재한다는 사실만으로 시스템이 검증됐다고 판단하지 않는다.

---

## 4. 핵심 검증 사이클 (ATLAS-VERIFY 계열)

| Phase | 내용 |
|-------|------|
| Phase 0 | Repository Reality Audit – 실제 존재하는 파일·문서 조사 |
| Phase 1 | Interface Capability Audit – READ/WRITE/MODIFY/EXECUTE/TEST 실제 테스트 |
| Phase 2 | Interface Repair – 부족한 인터페이스 수정 또는 BLOCKED 명시 |
| Phase 3 | Artifact Creation – 누락 Framework 문서 생성 + READ-BACK |
| Phase 4 | Verification Engine – 기존 구현 재사용 우선, 필요 시 확장 |
| Phase 5~7 | Self-Description / Vocabulary Closure 실제 검증 |
| Phase 8 | 실제 실행 및 Evidence 기록 |
| Phase 9 | Final Evidence Report |

### False Verification 금지
```python
# 금지
return {"status": "VERIFIED", "vocabulary_closure": True, "self_description": True}
```
실제 검증 로직 없이 하드코딩된 성공 값을 반환하지 않는다.

---

## 5. CLOSED 판정 조건 (모두 충족 시에만)

- Canonical vocabulary / grammar / semantic / logical framework가 Repository에 존재
- 모든 Artifact가 vocabulary로 해석 가능
- Undefined concept / predicate 없음
- Circular dependency / type inconsistency / grammar violation 없음
- Self-description 검증 성공
- Verification Engine 실행 Evidence + 실제 테스트 결과 존재

하나라도 부족하면 → `UNPROVEN` 또는 `PARTIALLY_VERIFIED`

---

## 6. 한 줄 요약

> Atlas는 설계 단계를 거의 마쳤고, 다음부터는 **아키텍처가 실제로 동작함을 증거로 증명하는 단계**에 들어간다.  
> 성공 기준은 "CLOSED"를 출력하는 것이 아니라, **실제 Repository가 말하는 결과를 그대로 받아들이는 것**이다.
