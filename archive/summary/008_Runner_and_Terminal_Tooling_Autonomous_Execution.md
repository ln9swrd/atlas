# 008. Runner / Terminal Tooling / Autonomous Execution & Model Roles

> **핵심**  
> Atlas에서는 "코딩 능력"보다 **"설계 추종 능력"**이 훨씬 중요하다.

---

## 1. 모델 역할 분담

| 모델 | 강점 | Atlas에서의 역할 |
|------|------|------------------|
| **Claude Code** | 설계 이해 ★★★★★, 장기 문맥, 코드 품질, 문서·코드 동시 수정 | 설계를 유지하며 구현 |
| **GPT** | 설계 토론, 추상화, 장기 방향성 | Atlas 설계자 |
| **Qwen3-Coder** | 구현·리팩토링·속도·대규모 코드 수정 ★★★★★ | 세부 구현 / 테스트 / 반복 작업 |

```
GPT → Atlas 설계
  ↓
Claude Code → 설계를 유지하며 구현
  ↓
Qwen3-Coder → 세부 구현 · 리팩토링 · 테스트
```

단순 CRUD는 거의 모든 최신 코딩 모델이 잘한다.  
Atlas는 200+ 문서 관계, Goal↔Sprint 연결, 상태 머신, 운영 루프를 유지해야 하므로 **프로젝트의 정신을 계속 유지하는 능력**이 성능을 가른다.

---

## 2. "cannot observe = cannot verify"

### 원칙
관찰할 수 없으면 검증할 수 없다.  
확인하지 못한 것을 확인한 것처럼 말하면 안 된다.

### 올바른 흐름
```
Observation Acquisition
    ↓
Observation
    ↓
Inference
    ↓
Decision
```

### 잘못된 흐름 (금지)
```
Inference (가정)
    ↓
Observation (가정으로 채움)
```

파일 존재를 단정하려면 실제 `os.path.exists()` 등으로 확인한 Observation이 있어야 한다.

---

## 3. LLM 행동 교정 효과

Atlas 철학이 모델의 작업 순서를 바꾸고 있다.

- 예전: "파일이 있을 것이다" (기억 기반)
- 지금: `os.path.exists()` 먼저 호출 (관찰 먼저)

> **No audit decision shall be produced before artifact acquisition has completed.**

이 규칙 하나로 "존재하지 않는 파일을 존재한다고 말하는" 문제를 구조적으로 막을 수 있다.

---

## 4. Auditor 확장 – Conversation Summary도 Audit 대상

```
Conversation → Summary → Atlas Auditor → Summary Quality Report
```

평가 항목 예:
- Observation Preservation
- Hallucination Rate
- Missing Decisions / Missing Files
- Unsupported Claims
- Traceability Score

### Auditor v2 범위
- Runtime Audit
- Constitution Audit
- **Conversation Summary Audit**
- **LLM Response Audit**

→ 코드·문서·LLM 답변·Summary까지 감사하는 범용 검증 커널.

---

## 5. 작업 도구 역할 정리

| 도구 | 역할 |
|------|------|
| Continue | 긴 작업을 수행하는 실행기 |
| ChatGPT | 설계 검토와 의사결정 |
| Conversation Summary | 둘을 연결하는 상태 전송 프로토콜 |

루프: `긴 작업 → Summary → 새로운 컨텍스트 → 계속 진행`

---

## 6. 단계 구분 (설계 종료 이후)

- **Architecture** – 거의 종료
- **Implementation** – 현재 시작
- **Validation**
- **Optimization**

앞으로는 문서를 늘리는 것이 아니라 **코드를 늘리는 단계**이다.  
Atlas는 "아이디어"가 아니라 **실제 소프트웨어 프로젝트**가 되었다.
