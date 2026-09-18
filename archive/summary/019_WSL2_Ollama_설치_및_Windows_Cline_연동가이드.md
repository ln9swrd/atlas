# 019. ATLAS-CORE Context Management Foundation 시리즈

> Atlas = 특정 AI에 종속되지 않는 **관리 계층**.  
> Context = 프롬프트 저장소가 아니라 **상태 + 근거 + 결정 + 책임**의 구조화된 운영 지식.

---

## 1. 역할 분리 (기준선)

| 주체 | 역할 |
|------|------|
| **Atlas** | Context · Task · Decision · Audit · AI Provider 관리 |
| **Kraken** | Local 실행 AI, 코드 조사·구현 지원 |
| **SERA** | Cloud AI, 고급 분석·설계 검토 |
| **Cline** | Execution Tool Layer (파일/터미널/Tool) |

---

## 2. Context 종류

| Context | 내용 |
|---------|------|
| **Project** | 프로젝트 전체 상태·아키텍처·원칙 |
| **Task** | 현재 작업 (objective, input, output, status) |
| **Decision** | 왜 이렇게 결정했는가 (상황→검토→결정→근거→후속 영향) |
| **Audit** | 검증 결과·evidence·finding |
| **Provider** | AI Provider별 컨텍스트 |

공통 Metadata 초안:
```
id, type, version, created, updated, source, status (EXIST|IMPLEMENTED|PROPOSED)
```

---

## 3. 저장 구조

**ATLAS-CORE-001 단계 권장: 파일 기반 + Schema First**

```
atlas/data/context/
  ├── project/
  ├── task/
  ├── decision/
  └── audit/
```

- 장점: 인간 검토·Git 친화·초기 구현 적합
- 추후: File → Database → Distributed

Context는 AI에 종속되지 않음. AI는 Context의 **소비자**.

```
Context → Context Resolver → Kraken / SERA / Cline
```

---

## 4. Core 문서 시퀀스

| 문서 | 주제 |
|------|------|
| BASELINE_FREEZE_001 | 환경 기준선 고정 |
| AGENT_ARCHITECTURE_001 | Agent 역할 분리 |
| **CORE-001** | Context Management Foundation |
| **CORE-002** | Context Schema and Repository Foundation |
| **CORE-003** | Context Lifecycle Management |
| CORE-004 | Context Resolver Architecture |
| CORE-005 | Provider Context Integration |
| CORE-006 | Runtime Context Execution |

### CORE-001 범위
구조 정의·경계 확립 (대규모 구현·Agent 자동화·Vector DB 금지)

### CORE-002 범위
Schema · Repository Interface · Storage Prototype (JSON/YAML)  
제외: AI 연결, Embedding, Agent Memory

### CORE-003 범위
- Lifecycle: CREATED → ACTIVE → UPDATED → VALIDATED → ARCHIVED → RETIRED
- Versioning (덮어쓰지 않고 축적)
- Ownership
- Retention (프로젝트 종료 후에도 Decision History 등 유지)

---

## 5. 장기 방향성

> 개별 프로젝트는 소멸해도 Atlas는 계속 성장한다.

```
Atlas = 생태계
프로젝트 = 한 번의 생명 주기
```

프로젝트가 사라져도 남는 것: 문제 정의 · 선택 · 성공/실패 · 반복 패턴.  
코드가 아니라 **경험(Decision History, Architecture Pattern, Failure Record, Methodology)** 이 Atlas Core에 축적된다.

지금 단계는 "똑똑한 AI 만들기"가 아니라 **무엇을 기억하고 어떻게 성장할 것인가**의 기반을 만드는 단계.
