# 002. Exelion 메타데이터 – estimate / environment / depends_on

> **전환**  
> Atlas 확장 → **Exelion 운영에 실제로 필요한 정보만 연결**

---

## 1. 이번 단계 성과

Runner가 실제 Exelion backlog에서 다음 메타데이터를 읽고 상태로 관리할 수 있게 됨.

- `estimate`
- `environment`
- `depends_on`

### 반영된 코드
- `atlas_runner.py`
  - start 출력에 estimate·환경 정보 표시
  - task state에 estimate / environment / depends_on 저장
- `test_atlas_runner.py`
  - 메타데이터가 상태로 보존되는지 검증 테스트 추가

**테스트 결과**: 4개 테스트 모두 통과

---

## 2. 현재 데이터 흐름

```
backlog.json
    │
    ▼
Runner
    ├── estimate
    ├── environment
    └── depends_on
    │
    ▼
TaskState
    │
    ▼
next() 후보 선택
```

아직 **저장만** 하고 의사결정에 본격 활용하지는 않는 단계.

---

## 3. 추천 엔진이 메타데이터를 사용하는 목표 순서

1. `depends_on` 미충족 → 후보 제외
2. `environment` 불일치 → 점수 크게 감소 또는 제외
3. `estimate` > 오늘 남은 시간 → 점수 감소
4. priority / urgency / due → 기본 점수 계산
5. 최근 수행 이력 → 반복 추천 방지
6. 최고 점수 작업 추천

→ “우선순위”가 아니라 **“지금 할 수 있는 일”**을 추천하게 됨.

---

## 4. 추천 다음 단계 – Runtime Context 도입

PriorityEngine을 크게 고치기 전에 **운영 컨텍스트**를 먼저 만든다.

```python
context = {
    "environment": "office",      # or "home"
    "available_minutes": 90,
    "energy": "high",
}

select_next(backlog, context, state)
```

이후 estimate / environment / dependency / energy / focus 등은 모두 `context`에만 추가하면 됨.

구조:
```
Task Metadata
      │
      ▼
Priority Engine
      ▲
      │
Runtime Context
```

---

## 5. Operation Sprint 003 우선순위 제안

1. ✅ 메타데이터 읽기 (`estimate`, `environment`, `depends_on`) — 완료
2. **Runtime Context 도입**
3. PriorityEngine이 Context를 사용하도록 변경
4. 실제 Exelion backlog 전체를 넣고 하루 운영 시뮬레이션
5. 추천 결과와 실제 수행 결과를 비교하여 점수 보정

---

## 6. Phase 재정의 (Worker 관점)

| Phase | 목표 | 완료 조건 (Exit Criteria) |
|-------|------|---------------------------|
| **Phase 4 – Worker Integration** | Worker 하나를 운영할 수 있다 | MockWorker와 Qwen3Worker가 동일 인터페이스로 Runtime Cycle을 1회 완료 |
| **Phase 5 – Continuous Execution** | 프로젝트가 멈추지 않는다 | 여러 ExecutionContract를 자동 이어 실행, READY → VERIFIED → NEXT READY 반복 |
| **Phase 6 – Autonomous Project** | AI 교체에도 프로젝트 지속 | Worker 실패 시 재시도·대체 Worker·복구가 자동 수행 |

**원칙**: 완료 조건이 코드와 테스트로 증명되어야만 다음 Phase로 넘어간다.

---

## 7. 당시 한 줄 요약

> Atlas는 이제 설계 단계를 거의 마쳤고, 다음부터는 아키텍처를 만드는 것이 아니라 **아키텍처가 실제로 동작함을 증명하는 단계**에 들어간다.

첫 목표: Qwen3Worker로 **운영 루프가 한 바퀴 도는 것** (파일 1개 수정 수준의 작은 Contract부터).
