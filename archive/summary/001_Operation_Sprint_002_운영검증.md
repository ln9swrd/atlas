# 001. Operation Sprint 002 – 운영검증

> **전환점**  
> 기능을 추가하는 단계에서 → **실제 사용 시나리오를 검증**하는 단계로 전환.

---

## 1. Operation Sprint 002 완료 상태

- ✅ `start`
- ✅ `next`
- ✅ `end`
- ✅ State 저장
- ✅ Event 기록

→ Atlas가 **최소한의 운영 루프**를 갖춤.

---

## 2. 다음 검증 목표: 실제 하루 운영

가상 Task가 아닌 **실제 운영 시나리오**를 반복 검증한다.

### 검증 시나리오
```
atlas start
  ↓
atlas next
  ↓
(작업 수행)
  ↓
atlas end
  ↓
atlas next
```

여러 번 반복했을 때 다음을 확인한다.

| 검증 항목 | 성공 기준 |
|-----------|-----------|
| 동일 Task 반복 추천 | 하지 않음 |
| DONE 누적 | 완료 작업이 쌓임 |
| Sprint 진행률 | 0% → 20% → … → 100% |
| Event Log | 실제 히스토리로 남음 (`task.started` → `task.completed` → `sprint.updated`) |

---

## 3. PriorityEngine 가중치 도입 방향

```
Priority Score =
  Goal Weight
+ Environment
+ Dependency
+ Urgency
+ State
```

→ 추천 이유가 점수화되어 AI가 설명하기 쉬워짐.

---

## 4. Phase 전환 인식

| Phase | 내용 |
|-------|------|
| Phase 1 – Foundation | Registry, RuntimeContext, Resolver, Priority Engine, Runner |
| Phase 2 – Governance | ADR, CI, DoD, Architecture, Manifest |
| Phase 3 – Operation | start / next / end, State, Event, History |
| **Phase 4 – Production** | **Exelion을 얼마나 잘 개발하게 해주는가**를 평가 |

---

## 5. Operation Sprint 003 제안 – Real Project Integration

**목표**  
Exelion의 실제 Task 100%를 Atlas가 관리한다.

### 핵심 원칙
1. 실제 Exelion Task만 등록
2. 모든 Task에 `estimate`와 `environment` 추가
3. 필요한 Task에 `depends_on` 정의
4. Exelion 개발은 반드시 `start → next → end` 루프로 진행
5. Atlas는 **실제 운영에서 불편한 점이 생길 때만** 기능을 추가

### 추가하고 싶은 핵심 필드
- **Estimated Time** (`estimate: 120 minutes`) → 남은 시간에 맞는 작업 추천
- **Dependency** (`depends_on: [EX-BRAVE-001]`) → 선행 작업 미완료 시 추천 제외

---

## 6. 핵심 경고

> 지금은 Atlas를 계속 확장하기 **가장 위험한 시기**이기도 하다.  
> 기반이 잘 잡힌 만큼, 목적이 "Atlas 개발"로 바뀌면 끝없이 기능을 추가하게 될 수 있다.

**원칙**: Exelion 개발에서 실제로 필요하다고 확인된 기능만 Atlas에 추가한다.

---

## 7. 부록 – 헤비 유저와 AI 서비스

- 헤비 유저는 피드백·버그 발견·새로운 활용법 측면에서 가치 있음
- 다만 서비스 지속을 위해 사용량 제한(Quota)은 필요
- Atlas처럼 **AI가 더 잘 일할 수 있는 환경 자체**를 만드는 사용 패턴은 흔치 않으며, AI-native Development Workflow의 사례로 참고 가치가 큼
