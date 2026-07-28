마스터, 이 결과를 보면 **Git 동기화 자체는 성공한 것으로 보입니다.** 그리고 이제 한 가지 중요한 사실이 확인됐습니다. ### 지금 Atlas에는 비슷해 보이는 구조가 여러 개 있습니다.

```
text
atlas/
atlas-runtime/
forge/
core/
agents/
projects/exelion/
```

그리고 이전에 확인했던:

```
text
excelion-forge/
```

까지 있었죠. 이제부터는 **이름이 비슷하다고 같은 시스템이라고 보면 안 됩니다.** 특히:

```
text
atlas-runtime/
    kernel.py
    observation.py
    inference.py
    verification.py
    evidence.py
    decision.py
```

와

```
text
atlas_runtime.py
```

이 둘이 **동일한 구현의 중복인지, 서로 다른 세대의 구현인지** 확인해야 합니다. 그리고:

```
text
forge/
core/
excelion-forge/
```

이 세 가지도 마찬가지입니다. --- ### 지금 가장 중요한 질문 > **"현재 Atlas에서 실제로 살아 있는 공식 구현은 무엇인가?"** 입니다. 지금 Cline이 수집한 결과만으로는:

```
text
문서 아키텍처
    +
실제 Runtime
    +
과거 구현
    +
Forge
    +
Agent 관련 잔재
```

가 한 저장소 안에 공존하는 것으로 보입니다. 그래서 지금 당장 삭제하면 안 됩니다. --- 저라면 이제 Cline에게 **마지막으로 아주 좁은 작업**을 시키겠습니다.

```
text id="q2d8a4"
Cline,

현재 Atlas 저장소의 구조가 여러 세대의 구현과 문서를 포함하고 있을 가능성이 있다.

이번 작업의 목적은 "삭제"가 아니다.

현재 실제로 사용되는 공식 구현 경로를 식별하라.

다음 항목을 서로 비교하라.

1. atlas/
2. atlas-runtime/
3. atlas_runtime.py
4. forge/
5. excelion-forge/
6. core/
7. agents/

각 항목에 대해:

- 실제 역할
- 실제 코드 존재 여부
- 다른 코드에서 import/reference 되는지
- 테스트에서 사용되는지
- 최근 Git commit에서 변경되었는지
- 현재 공식 구현으로 판단할 근거
- 과거/중복/실험 구현 가능성

을 확인하라.

특히 다음 질문에 답하라.

A. atlas-runtime/ 과 atlas_runtime.py 는 중복인가?
B. forge/ 와 excelion-forge/ 는 중복인가?
C. core/ 는 Atlas Runtime인가 Forge인가?
D. agents/ 는 현재 시스템에서 실제 사용되는가?
E. 현재 Atlas Runtime의 공식 진입점은 무엇인가?
F. 현재 Forge의 공식 진입점은 무엇인가?

중요:

- 파일을 삭제하지 마라.
- 파일을 이동하지 마라.
- 코드를 수정하지 마라.
- Git 상태를 변경하지 마라.
- 추측으로 "공식"이라고 판단하지 마라.
- 반드시 실제 import/reference와 Git history를 근거로 판단하라.

최종 결과:

# OFFICIAL IMPLEMENTATION MAP

## Atlas
Official Entry Point:
Official Runtime:
Official Knowledge:
Official Verification:

## Forge
Official Entry Point:
Official Runtime:
Official Executor:

## Legacy / Duplicate
목록

## Unused / Orphaned
목록

## Uncertain
확인할 수 없는 항목

## Final Conclusion
현재 실제 운영에 사용되는 Atlas와 Forge의 최소 경로를
하나의 코드 흐름으로 작성하라.

분석 후 종료하라.
```

이걸 하고 나면 마스터, **그때 비로소 "뭘 지울지" 결정할 수 있습니다.** 지금까지의 결과를 보면 저는 오히려 긍정적으로 봅니다. 처음에는 Cline이 `src/main.py`를 찾다가 경로를 잘못 잡았고, 그다음 실제 `excelion-forge/src/main.py`를 찾아냈습니다. 이제는 Atlas 전체를 읽으면서 **여러 세대의 구조가 공존한다는 사실**까지 드러났습니다. 이제 남은 건 **정리와 통합의 문제**입니다. 그리고 이 작업이 끝나면 Atlas는 아마 다음처럼 훨씬 선명해질 겁니다.

```
text
Atlas
 ├── Knowledge
 ├── Runtime
 ├── Verification
 └── Evidence
        │
        ▼
      Forge
        │
        ▼
     Execution
```

그때부터는 정말 **"Atlas가 무엇인지"를 마스터와 제가 같은 그림을 보면서 이야기할 수 있게 됩니다.** 지금은 삭제보다 **공식 구현 경로를 확정하는 것**이 먼저입니다. 마스터 : 이거 수행을 못 해 클라인이.. 작게 분할해줘

마스터, 맞습니다. 지금 요청은 Cline 입장에서는 한 번에 처리하기에는 범위가 너무 큽니다.

특히 문제는 단순 파일 목록 조회가 아니라:

- 전체 저장소 탐색
- import 분석
- reference 분석
- Git history 분석
- 테스트 연결 확인
- 아키텍처 판단

까지 한 번에 요구하고 있습니다.

Cline 같은 에이전트는 중간에 컨텍스트가 소진되거나, 일부만 보고 추론해버릴 가능성이 높습니다.

**작업을 "증거 수집 → 비교 → 판단" 순서로 쪼개는 게 맞습니다.**

---

## Step 1. 구조 지도만 생성

먼저 아무 판단도 하지 말고 파일 구조와 크기만 봅니다.

Cline 요청:

```
Cline,

현재 Atlas 저장소 구조를 조사하라.

목적:
구조 파악만 한다.
삭제, 수정, 이동 금지.

확인 대상:

- atlas/
- atlas-runtime/
- atlas_runtime.py
- forge/
- excelion-forge/
- core/
- agents/

각 항목에 대해:

1. 존재 여부
2. 주요 파일 목록
3. Python 파일 개수
4. README / 문서 존재 여부
5. package 구조 여부
6. entry point 후보 파일

을 정리하라.

판단하지 마라.
공식/비공식 결론을 내리지 마라.

출력:

# ATLAS STRUCTURE MAP

## atlas

## atlas-runtime

## atlas_runtime.py

## forge

## excelion-forge

## core

## agents
```

---

## Step 2. Import 관계 분석

구조를 알았으면 이제 실제 연결을 봅니다.

```
Cline,

Atlas 저장소 내부의 Python import 관계를 분석하라.

목적:
어떤 코드가 실제로 다른 코드에서 사용되는지 확인한다.

분석 대상:

- atlas/
- atlas-runtime/
- atlas_runtime.py
- forge/
- excelion-forge/
- core/
- agents/

확인:

1. import 되는 파일
2. import 하는 파일
3. 참조 횟수
4. 외부에서 호출되는 entry point 후보

출력:

# IMPORT GRAPH SUMMARY

## High Usage

## Medium Usage

## No Reference Found

## Possible Entry Points

수정하지 마라.
```

---

## Step 3. Git 역사 확인

이 단계에서 "살아있는 코드"를 봅니다.

```
Cline,

다음 경로들의 Git history를 분석하라.

대상:

atlas/
atlas-runtime/
atlas_runtime.py
forge/
excelion-forge/
core/
agents/

확인:

- 마지막 commit 날짜
- 최근 변경 빈도
- 최초 생성 commit
- 현재 branch에서 유지되는지 여부

출력:

# GIT ACTIVITY MAP

Path | Last Commit | Frequency | Status

판단하지 말고 사실만 기록하라.
```

---

## Step 4. 테스트 연결 확인

```
Cline,

Atlas 저장소의 테스트 코드와 실행 스크립트를 조사하라.

목적:
실제로 검증되는 구현 경로 확인.

찾을 것:

- pytest 대상
- 실행 스크립트
- CI 설정
- docker 실행 명령
- main 실행 파일

출력:

# TEST AND EXECUTION MAP

Test Entry:
Runtime Entry:
CLI Entry:
Docker Entry:

관련 파일 경로 포함.
```

---

## Step 5. 최종 판단 요청

마지막에만 판단시킵니다.

```
Cline,

이전 조사 결과를 기반으로 공식 구현 경로를 판단하라.

판단 근거는 반드시:

- import 관계
- Git history
- test 사용
- 실행 entry point

중 하나 이상이어야 한다.

출력:

# OFFICIAL IMPLEMENTATION MAP

## Atlas

Entry Point:
Runtime:
Knowledge:
Verification:

## Forge

Entry Point:
Runtime:
Executor:

## Legacy Candidate

## Orphan Candidate

## Uncertain

## Conclusion

현재 실제 실행 흐름을 한 줄로 표현하라.
```

---

마스터, 이 순서가 중요한 이유가 있습니다.

지금 Atlas 상태는 "망가진 상태"가 아니라 **역사가 쌓인 프로젝트 상태**에 가깝습니다.

오히려:

```
초기 실험
   ↓
Runtime 분리
   ↓
Verification 추가
   ↓
Forge 확장
   ↓
Exelion 연결
```

같은 발전 과정의 흔적일 가능성이 높습니다.

지금 바로 정리하면 역사를 버릴 수 있습니다.

먼저 **"살아있는 혈관 찾기"**를 해야 합니다.

제가 보기에는 Cline에게는 Step 1부터 시키는 게 맞습니다. 한 번에 전체 지도를 그리게 하지 말고, 탐색자가 지도 → 연결망 → 생명 징후 → 판단 순서로 가야 합니다.

마스터, 이제 거의 확정적으로 보입니다. 그리고 한 가지 중요한 점이 드러났습니다.

**실제로 Python Core는 2개만 현재 저장소에서 발견됩니다.**  
다만 마스터가 기억하는 "3개"는 아마 **Atlas / SERA / Forge라는 설계상의 3개 계층**이고, 현재 Git 트리에는 그중 일부가 통합되거나 이름이 바뀐 상태로 남아 있는 것으로 보입니다.

현재 확인 결과:

---

# Core 1 — SERA 계열

경로:

```
core/
```

파일:

```
adapter.py
agent_profile.py
agent_session.py
config.py
contracts.py
event_store.py
events.py
execution_chain.py
execution_contract.py
execution_plan.py
execution_queue.py
...
main.py
```

특징:

- Agent
- Session
- Event
- Execution
- Contract
- Planner

키워드:

```
agent
execution
contract
queue
plan
session
```

이건 거의 확실히 **SERA 계열**입니다.

구조:

```
SERA
 |
 ├── Agent
 ├── Session
 ├── Event Store
 ├── Execution Chain
 └── Planning
```

---

# Core 2 — Atlas Core

경로:

```
core/
```

(출력상 경로가 생략되어 있지만 다른 위치)

파일:

```
runtime_context.py
priority_engine.py
context_resolver.py
environment_registry.py
environment_resolver.py
goal_registry.py
review_engine.py
rule_engine.py
atlas_state.py
blender_*.py
```

특징:

- Runtime Context
- Rule
- Review
- State
- Environment
- Validation
- Blender Tool

README:

```
Checklists Layer
```

이건 Atlas 쪽입니다.

구조:

```
Atlas Core
 |
 ├── Runtime Context
 ├── Rules
 ├── Review
 ├── Validation
 └── Tools
```

---

그리고 여기서 중요한 부분:

## Forge Core는 아직 직접 발견되지 않음

하지만 마스터 기억:

> Atlas, SERA, Forge 세 개

와 현재 결과를 맞추면:

```
설계 시점

Atlas Core
    |
SERA Core
    |
Forge Core


현재 상태

Atlas Core
    |
    +-- SERA 일부 자산
    |
    +-- Forge 기능 일부 흡수 가능성
```

처럼 봐야 합니다.

---

제가 지금 가장 의심하는 부분은 **Core 1(SERA)이 사실 Forge의 전신이거나 중간 단계였을 가능성**입니다.

왜냐하면 파일명이:

```
execution_chain.py
execution_contract.py
execution_plan.py
execution_queue.py
project_graph.py
planner.py
```

입니다.

이건 단순 Agent가 아니라 "작업을 계획하고 실행하는 시스템"입니다.

Forge라는 이름과 너무 가깝습니다.

---

다음 단계는 이름 찾기가 아니라 **Core 1의 README와 main.py 확인**입니다.

아주 작은 작업:

```
현재 agent subsystem core의 README.md와 main.py만 분석해줘.

확인:
1. 프로젝트 이름
2. 목적
3. 실행 흐름
4. Forge 관련 용어 존재 여부
5. 현재 사용 여부

코드 수정 금지.
```

이 결과가 나오면:

- SERA가 완전히 버려진 실험인지
- Forge의 초기 구현인지
- 별개의 Agent 시스템인지

구분됩니다.

마스터, 지금까지의 탐색에서 가장 중요한 발견은 이겁니다.

**"excelion-forge 폴더는 없지만, Forge라고 불렀던 실행 개념의 코드 조각은 남아 있을 가능성이 높다."**

이제 이름이 아니라 역할 기준으로 찾아가야 합니다.

일단 현재 상태를 문서로 저장하자

마스터, 지금까지 확인된 내용을 기준으로 **현재 Atlas 구조 조사 결과 문서** 형태로 남기겠습니다. 이후 Core 정리나 Forge 복원 판단의 기준 문서로 쓰면 됩니다.

# Atlas 구조 조사 현황 문서

## 1. 조사 목적

현재 Atlas 저장소 내부에 존재하는 Runtime, Core, SERA, Forge 관련 구현 구조를 확인하고, 과거 설계와 현재 코드 상태의 관계를 파악한다.

본 조사의 목적은 삭제나 정리가 아니라:

- 현재 살아있는 구현 확인
- 과거 설계 자산 확인
- 역할별 계층 분리
- 향후 통합 방향 결정

이다.

---

# 2. 현재 확인된 주요 구조

현재 저장소에는 이름이 비슷한 여러 계층이 존재하며, 단일 구조가 아니라 여러 세대의 구현이 공존하는 형태로 확인되었다.

주요 영역:

```
Atlas
 ├── Runtime
 ├── Core
 ├── Agent/SERA 계열
 ├── Project(Exelion)
 └── Blender Tooling
```

---

# 3. Atlas Runtime

## 공식 Runtime 후보

현재 실행 흐름의 중심은:

```
atlas_runtime.py
```

이다.

확인된 역할:

- Observation
- Inference
- Verification
- Evidence
- Decision

흐름:

```
Observation
    ↓
Inference
    ↓
Verification
    ↓
Evidence
    ↓
Decision
```

현재 Atlas의 실제 실행 진입점 후보이다.

---

# 4. Atlas Core

## 역할 후보

Atlas Runtime을 지원하는 핵심 모듈.

주요 파일:

```
runtime_context.py
priority_engine.py
context_resolver.py
environment_registry.py
environment_resolver.py
goal_registry.py
review_engine.py
rule_engine.py
atlas_state.py
blender_collision.py
blender_export.py
blender_uv_check.py
```

담당 영역:

- Runtime Context
- Goal 관리
- Environment 관리
- Rule 처리
- Review
- State 관리
- Blender 연동

현재 판단:

```
Atlas Runtime
      |
      ↓
Atlas Core
```

구조.

---

# 5. SERA 계열 Core

## 확인된 파일

주요 파일:

```
adapter.py
agent_profile.py
agent_session.py
contracts.py
event_store.py
events.py
execution_chain.py
execution_contract.py
execution_plan.py
execution_queue.py
planner.py
project_graph.py
main.py
```

특징:

- Agent
- Session
- Event
- Execution
- Planning
- Contract

관련 기능 존재.

현재 판단:

SERA라는 이름의 독립 시스템 또는 Agent 실험 계층으로 추정된다.

다만:

```
execution_plan
execution_queue
execution_contract
planner
project_graph
```

등의 구조는 과거 Forge 설계와 유사한 부분이 존재한다.

---

# 6. Excelion Forge 상태

확인 결과:

```
excelion-forge/
exelion-forge/
```

형태의 독립 디렉터리는 현재 확인되지 않았다.

Git history에서도 독립 Forge 경로는 확인되지 않았다.

그러나 다음 영역에 Forge 관련 설계 자산이 남아 있을 가능성이 있다.

```
projects/exelion/

PROJECT_CHARTER.md
ENVIRONMENT_PLAN.md
EX-GOAL-001.md
backlog.json
Sprint 문서
memory.md
```

현재 판단:

Excelion Forge는 독립 폴더 형태가 아니라 다른 계층으로 흡수되었거나 분해되었을 가능성이 있다.

---

# 7. Blender Integration

현재 존재:

```
core/tools/

blender_collision.py
blender_export.py
blender_uv_check.py
```

확인:

- bpy 사용
- Blender 실행 코드 존재
- Validation 로직 존재

그러나:

- bl_info 없음
- register 없음
- unregister 없음
- Operator 없음
- Panel 없음

현재 상태:

```
Blender Addon
    X

Blender Script Library
    O
```

향후 별도 Addon Adapter 구축 필요.

---

# 8. 현재 구조 추정

현재 가장 가능성 높은 구조:

```
                 Atlas
                   |
          atlas_runtime.py
                   |
        ┌──────────┴──────────┐
        |                     |
   Atlas Core            SERA/Execution Core
        |                     |
 Verification            Planning
 Runtime Context         Execution
 Rules                   Agent
 Blender                 Contract


        +
        
 projects/exelion
        |
        Goal / Environment / Sprint
```

---

# 9. 현재 판단 사항

## 확정

- atlas_runtime.py가 현재 Runtime 중심
- Atlas Core 존재
- SERA 계열 Core 존재
- Exelion 프로젝트 문서 존재
- Blender 관련 Script 존재

## 미확정

- SERA가 Forge의 전신인지 여부
- Forge Core가 별도로 존재했는지 여부
- Excelion Forge 설계가 현재 어디에 흡수되었는지

---

# 10. 다음 조사 방향

다음 단계는 삭제나 정리가 아니다.

확인 순서:

1. SERA Core README / main.py 분석
2. Forge 역할과 SERA 역할 비교
3. projects/exelion 문서와 Core 연결 확인
4. 공식 Architecture Map 작성

최종 목표:

```
Atlas Runtime
        |
        |
Atlas Core
        |
        |
Forge / Execution Layer
        |
        |
Project Execution
```

구조를 확정하는 것.

이 문서를 기준선으로 잡으면 됩니다. 다음부터는 "기억"이 아니라 이 문서와 실제 파일을 기준으로 Atlas/SERA/Forge 관계를 맞춰가면 됩니다.

이 문서를 현재 확인된 사실에 맞게 정리하면서, 과도한 판단 없이 구조 요약 형태로 다듬겠습니다. # Atlas 구조 조사 현황 문서 ## 1. 조사 목적 현재 Atlas 저장소 내부에 존재하는 Runtime, Core, SERA, Forge 관련 구현 구조를 확인하고, 과거 설계 자산과 현재 코드 상태의 관계를 파악한다. 본 조사의 목적은 삭제나 정리가 아니라: - 현재 살아 있는 구현 확인 - 과거 설계 자산 확인 - 역할별 계층 분리 - 향후 통합 방향 검토 이다. --- ## 2. 현재 확인된 주요 구조 현재 저장소에는 여러 계층의 구현이 공존하는 형태로 확인되었다. 주요 영역은 다음과 같다. - Runtime 계층 - Core 계층 - SERA/Agent 계열 - Exelion 프로젝트 문서 및 데이터 - Blender 관련 도구 스크립트 --- ## 3. Atlas Runtime ### 확인된 후보 현재 실행 흐름의 중심으로 확인되는 파일은 atlas_runtime.py이다. ### 확인된 흐름 다음 흐름이 코드상으로 확인된다. - Observation - Inference - Verification - Evidence - Decision 즉, 기본적인 실행 사이클은 다음과 같이 정리할 수 있다. Observation → Inference → Verification → Evidence → Decision ### 현재 상태 atlas_runtime.py는 현재 Atlas Runtime의 핵심 후보로 보인다. 다만, 이 파일이 저장소 전체의 “공식 실행 진입점”인지에 대해서는 구현 체인과 테스트 사용 여부를 함께 봐야 한다. --- ## 4. Atlas Core ### 확인된 위치 Atlas Core 계층은 core 아래에 확인된다. ### 주요 영역 core에는 다음과 같은 하위 영역이 확인되었다. - context - decision - execution - registry - review - rules - state - tools ### 주요 파일 대표 파일로는 다음이 확인되었다. - runtime_context.py - priority_engine.py - context_resolver.py - environment_registry.py - environment_resolver.py - goal_registry.py - priority_engine.py - review_engine.py - rule_engine.py - atlas_state.py ### 현재 구조상 역할 현재 확인된 범위에서는 core가 Atlas Runtime을 보완하는 핵심 지원 계층으로 보인다. --- ## 5. SERA 계열 Core ### 확인된 위치 SERA 계열의 핵심 코드는 core 아래에 확인되었다. ### 주요 파일 대표 파일은 다음과 같다. - adapter.py - agent_profile.py - agent_session.py - contracts.py - event_store.py - events.py - execution_chain.py - execution_contract.py - execution_plan.py - execution_queue.py - planner.py - project_graph.py - main.py ### 현재 상태 이 계층은 Agent, Session, Event, Execution, Planning, Contract와 관련된 구조를 포함한다. 현재 확인된 사실만 보면, SERA는 독립적인 Agent/Execution 계층으로 보인다. --- ## 6. Excelion / Forge 상태 ### 확인 결과 다음과 같은 독립 디렉터리는 현재 확인되지 않았다. - forge - exelion-forge - exelion-forge ### 관련 자산 대신 exelion 아래에 프로젝트 문서와 데이터가 확인되었다. 대표 파일: - PROJECT_CHARTER.md - ENVIRONMENT_PLAN.md - EX-GOAL-001.md - backlog.json - memory.md ### 현재 상태 Excelion Forge는 현재 독립 폴더 형태로는 확인되지 않았다. 대신 Exelion 프로젝트 문서와 실행 데이터로 흡수된 형태로 남아 있는 것으로 보인다. --- ## 7. Blender Integration ### 확인된 위치 Blender 관련 스크립트는 tools 아래에 확인되었다. - blender_collision.py - blender_export.py - blender_uv_check.py ### 확인된 사실 - Blender API 사용이 확인됨 - Blender 실행용 함수가 존재함 - Validation 로직이 존재함 ### 현재 상태 다만, addon 등록 패턴은 현재 확인되지 않았다. 즉, 현재 상태는 다음과 같이 정리할 수 있다. - Blender Addon 구조: 미확인 - Blender Script Library: 확인됨 --- ## 8. 현재 구조 추정 현재 확인된 사실을 기준으로 보면, 저장소는 하나의 단일 구조가 아니라 다음과 같은 여러 계층이 공존하는 형태로 보인다. - Atlas Runtime - Atlas Core - SERA/Agent Core - Exelion Project Layer - Blender Tooling 정리하면 다음과 같은 형태가 가장 자연스럽다. Atlas Runtime → Atlas Core → SERA / Execution Core → Project Execution Layer --- ## 9. 현재 확인된 사항 ### 확정 - atlas_runtime.py가 현재 Runtime 후보로 확인됨 - core가 핵심 지원 계층으로 확인됨 - core가 별도 Agent/Execution 계층으로 확인됨 - exelion 문서와 데이터가 존재함 - Blender 관련 스크립트가 존재함 ### 미확정 - SERA가 Forge의 직접적인 전신인지 여부 - Excelion Forge가 과거에 별도 디렉터리로 존재했는지 여부 - Forge 관련 설계 자산이 현재 어떤 계층에 흡수되었는지 여부 --- ## 10. 다음 조사 방향 다음 단계는 구현 삭제나 정리가 아니라, 구조를 더 분명히 확인하는 방향으로 진행하는 것이 적절하다. 다음 항목이 이어서 확인될 수 있다. 1. SERA Core의 main/entry 구조 2. Forge 역할과 SERA 역할의 차이 3. Exelion 프로젝트 문서와 Core 모듈의 연결 4. 공식 Architecture Map 정리 최종 목표는 “하나의 단일 구현 흐름”이 아니라, 현재 저장소 안에 공존하는 여러 구현 계층을 명확히 구분하는 것이다.

마스터, 이 버전이 훨씬 좋습니다.  
이전 문서에서 제가 넣었던 몇몇 표현(예: "Forge 기능이 흡수되었다", "SERA가 Forge 전신일 가능성이 높다")은 **조사 사실보다 한 단계 앞선 해석**이었습니다.

지금 마스터가 정리한 형태가 조사 문서로는 더 적합합니다.

다만 몇 군데만 현재 확인된 사실과 더 정확히 맞추면 좋겠습니다.

수정 권장점:

1. **"SERA 계열의 핵심 코드는 core 아래에 확인되었다"**
    
    → 현재 출력상 두 개의 `core` 경로가 있었고, 하나는 SERA 계열로 보이지만 정확한 전체 경로 확인 전에는 "SERA 계열 Core로 분류되는 core 디렉터리" 정도가 안전합니다.
    
2. **"exelion 아래에 프로젝트 문서와 데이터가 확인되었다"**
    
    → 앞선 결과에서는 `projects/exelion`이 확인되었으므로 경로를 명시하는 것이 좋습니다.
    
3. **"Excelion Forge는 현재 독립 폴더 형태로는 확인되지 않았다. 대신 Exelion 프로젝트 문서와 실행 데이터로 흡수된 형태로 남아 있는 것으로 보인다."**
    
    → 뒤 문장은 아직 가설입니다.
    
    이렇게 바꾸는 게 정확합니다.
    
    > Excelion Forge는 현재 독립 폴더 형태로 확인되지 않았다. 관련 역할이나 설계 자산이 다른 계층에 존재하는지는 추가 확인이 필요하다.
    

---

그리고 마지막 구조 그림도 조금 조심하면 좋겠습니다.

현재:

```
Atlas Runtime
→ Atlas Core
→ SERA / Execution Core
→ Project Execution Layer
```

은 "가능한 관계"이지 확인된 실행 흐름은 아닙니다.

문서용으로는:

```
Atlas Repository
│
├── Runtime Layer
│
├── Core Layer
│   ├── Atlas Runtime Support
│   └── Agent/Execution Related Core
│
├── Project Layer
│   └── projects/exelion
│
└── Tooling Layer
    └── Blender Scripts
```

정도가 현재 증거 기반으로 더 안전합니다.

---

전체적으로는 이 문서를 이제 **"Atlas Repository Structure Investigation v0.1"** 같은 기준 문서로 두면 좋겠습니다.

중요한 점은 이 문서가 결론 문서가 아니라:

- 현재 발견된 구조
- 확인된 사실
- 아직 모르는 부분

을 분리했다는 것입니다.

앞으로 Forge를 다시 찾거나 통합 방향을 잡을 때도 이 기준이면 길을 잃지 않을 것 같습니다.