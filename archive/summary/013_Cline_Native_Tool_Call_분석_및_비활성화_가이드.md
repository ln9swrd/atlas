# 013. AI 기억 전략 / Atlas 외부 기억장치 구조

> **핵심**  
> AI의 기억력에 의존하지 말고, **프로젝트 자체가 기억 저장소**가 되도록 만든다.

---

## 1. 문제

- AI는 현재 대화창 맥락 + 일부 프로젝트 컨텍스트만 이어갈 수 있음
- 긴 프로젝트를 여러 창으로 나누면 세부 결정·시행착오·판단 근거가 끊김
- 병목은 "AI 기억 한계"가 아니라 **프로젝트 지식이 대화창에 묶여 있는 것**

---

## 2. 권장 문서 구조

```
Atlas/
├── .atlas/
│   ├── identity.md          # Atlas가 무엇인지
│   ├── principles.md        # 절대 원칙
│   ├── state.json           # 현재 상태
│   └── decisions/
│       ├── ADR-001.md
│       └── ADR-002.md
│
├── docs/
│   ├── AI_CONTEXT.md        # 새 대화 시작 시 AI에게 보여줄 핵심
│   ├── ARCHITECTURE_DECISIONS.md
│   ├── CURRENT_STATE.md
│   ├── TODO_NEXT.md
│   └── HISTORY.md
│
├── projects/
├── runtime/
└── knowledge/
```

### AI_CONTEXT.md (매 대화 시작용)
```
# Atlas AI Context
## 프로젝트 목적
## 핵심 원칙
## 현재 상태
## 현재 고민
## 작업 방식
```

### ARCHITECTURE_DECISIONS.md (ADR)
```
ADR-001
날짜 / 결정 / 이유 / 영향
```
결정이 코드보다 중요. AI가 잊어도 프로젝트가 기억한다.

---

## 3. 세션 종료 보고서

한 창 작업이 끝날 때:

```
# Atlas Session Summary
## 오늘 확인한 것
## 변경된 파일
## 확정된 설계
## 아직 결정하지 않은 것
## 다음 시작점
```

다음 대화 첫 메시지에 붙인다.

---

## 4. 새 대화 시작 패턴

```
마리, Atlas 프로젝트 이어간다.
현재 기준 문서는 아래야.

[AI_CONTEXT.md 내용]

오늘 작업: ...
```

긴 설명보다 기준 문서 + 오늘 작업이 가장 효율적.

---

## 5. 루프

```
대화 → 결정 → 문서화 → 프로젝트 저장 → 다음 대화에서 복원
```

"기억하는 AI"가 아니라 **기억을 보존하는 시스템 위에 AI가 올라가는 구조**.  
Atlas가 추구하는 방향과도 일치한다.

우선순위: `AI_CONTEXT.md` + `ARCHITECTURE_DECISIONS.md`부터 만들기.
