# EX-GOAL-001: Prototype Start

## Goal Metadata
- Goal ID: EX-GOAL-001
- Title: Prototype Start
- Status: Active
- Priority: Critical
- Owner: Marie
- Project: Exelion

## Dependencies
- PROJECT_CHARTER

## Outputs
- Sprint-001
- Asset Plan
- Prototype Roadmap
- Environment Plan

## Completion Criteria
- Sprint 생성 완료
- Asset Pipeline 검증 완료
- 첫 Production Task 정의
- Sprint-001 실행 준비 완료

## Project
Exelion

## Current Phase
Prototype → Core Asset Production

## Mission
Start the first playable prototype for Exelion by establishing the initial planning, backlog, and production pipeline structure.

## Objectives
1. Review the Exelion Project Charter.
2. Review the current backlog and identify the highest-value initial work.
3. Reorganize the work into a prototype-phase sprint structure.
4. Confirm whether an asset pipeline is already in place or needs to be established.
5. Validate the Blender → Unreal production path.
6. Identify missing assets and systems needed for the first prototype.
7. Create the first sprint backlog.

## Deliverables
- Sprint 01 backlog
- Asset production plan
- Prototype roadmap
- Risk analysis
- Recommended next task
- Environment execution plan

## Rules
- Follow the Atlas Constitution.
- Follow the Exelion Project Charter.
- Follow the Rule Engine and Review System.
- Apply the ROI Gate.
- Respect the environment split between Company PC and Home PC.
- Use the environment registry in [../../../ENVIRONMENTS.md](../../../ENVIRONMENTS.md) as the source of truth for capabilities and constraints.
- Use the runtime context resolver in [../../../core/execution/environment_resolver.py](../../../core/execution/environment_resolver.py) and the higher-level context resolver in [../../../core/execution/context_resolver.py](../../../core/execution/context_resolver.py) when selecting environment-specific work.

## Operating Principle
Atlas does not change Exelion. Only repeatable bottlenecks discovered in Exelion may be proposed as Atlas improvements.

## Output
A markdown report capturing the plan, risks, and next recommended task.

## Master Task — Atlas Phase 3 Architecture Freeze

### Objective
Atlas Phase 3의 아키텍처를 최종 확정한다.

이번 작업에서는 새로운 기능을 추가하지 않는다.
목표는 현재 설계를 Project-centric Operating System으로 정리하고, 이후 Phase 4(Qwen3 Integration)의 기준선(Baseline)을 만드는 것이다.

### Principles
다음 원칙은 변경하지 않는다.

- Project는 최상위 Domain Object이다.
- AI는 Worker이며 Project의 일부가 아니다.
- Event는 Single Source of Truth이다.
- Project State는 Event Projection이다.
- ExecutionPlan은 불변(Immutable)이다.
- ExecutionContract는 실행 가능한 최소 계약이다.
- Runtime은 실행 상태만 가진다.
- Queue는 Contract를 소유하지 않고 contract_id만 관리한다.
- WorkspaceSnapshot은 현재 코드 상태를 표현한다.
- AgentSession은 AI 실행 기록만 담당한다.
- PromptBuilder는 Contract와 Snapshot을 Agent Prompt로 변환하는 역할만 가진다.

### Scope
이번 작업에서는 다음만 수행한다.

- Core Domain 객체의 경계 검토
- 책임이 섞인 클래스 정리
- 중복 모델 제거
- 명칭 통일
- 문서 정리
- 테스트 유지
- Architecture 문서 최신화

### Explicitly Out of Scope
이번 작업에서는 절대 구현하지 않는다.

- Qwen3 Runner
- Claude Runner
- GPT Runner
- Gemini Runner
- 실제 Git 연동
- WorkspaceSnapshot 자동 생성
- Event 영속화
- Contract 자동 생성
- Contract 자동 완료
- Scheduler
- Parallel Execution
- UI

이들은 모두 Phase 4 이후의 작업이다.

### Deliverables
최종 결과는 다음을 만족해야 한다.

1. Core Architecture
   Project 중심 구조가 문서와 코드에 동일하게 반영된다.

2. Domain Boundary
   각 객체의 책임이 명확하다.
   - Project
   - Intent
   - Knowledge
   - Event Store
   - Project State
   - Runtime
   - ExecutionPlan
   - ProjectGraph
   - ExecutionContract
   - ExecutionQueue
   - WorkspaceSnapshot
   - AgentSession

3. Documentation
   다음 문서를 최신 상태로 유지한다.
   - Architecture
   - Core Domain
   - Execution Flow
   - Event Model
   - Planning Model

4. Tests
   기존 테스트는 모두 통과해야 한다.
   새로운 기능 테스트는 추가하지 않는다.

### Completion Criteria
작업 완료 조건은 다음과 같다.

- Architecture 변경 사항 없음
- Core Domain Freeze
- 테스트 100% 통과
- 문서와 코드가 동일한 모델을 설명
- Phase 4(Qwen3 Integration)를 바로 시작할 수 있는 상태

### Master Note
이번 Sprint의 목적은 AI를 추가하는 것이 아니다.

Atlas의 운영체제를 완성하고 동결하는 것이다.

Phase 4부터는 설계가 아니라 Worker Integration을 시작한다.

## Phase 3 Exit Criteria
Phase 3는 다음 조건을 모두 만족할 때 완료된 것으로 간주한다.

- Project가 유일한 최상위 Domain Object이다.
- Core Domain 객체의 책임과 경계가 문서와 코드에서 일치한다.
- ExecutionPlan과 ExecutionContract의 역할이 명확히 분리되어 있다.
- Event는 프로젝트 상태의 유일한 근거이며, Project State는 Event Projection이다.
- Runtime은 실행 상태만 관리하며 Project의 구조를 변경하지 않는다.
- Agent는 Worker이며 Project Domain에 종속되지 않는다.
- 모든 기존 테스트가 통과한다.
- 새로운 기능 추가 없이 아키텍처를 기준선(Baseline)으로 동결한다.

Phase 4부터는 아키텍처 변경이 아니라 Worker Integration을 진행한다.

## Core Definition
Atlas는 더 이상 AI 프레임워크가 아니라, 프로젝트를 실행하는 운영체제(Project Operating System)이며, AI는 그 위에서 실행되는 Worker이다.

## Master Task — Phase 4: First Worker Integration

### Objective
Atlas의 Core Architecture를 변경하지 않는다.

Phase 4의 목표는 Project Operating System 위에 첫 번째 Worker를 연결하는 것이다.

이번 Worker는 Qwen3를 사용하지만, 구현은 특정 모델에 종속되지 않는 Worker Adapter 구조로 작성한다.

### Architecture Constraints
다음 Core Domain은 절대 변경하지 않는다.

- Project
- Intent
- Knowledge
- Event Store
- Project State
- Runtime
- ExecutionPlan
- ProjectGraph
- ExecutionQueue
- ExecutionContract
- WorkspaceSnapshot
- AgentSession

이 객체들은 이미 Phase 3에서 Freeze되었다.

이번 Sprint에서는 Core Domain을 수정하지 않는다.

### Worker Layer
새로운 Worker Layer를 추가한다.

```text
WorkerAdapter
        ▲
        │
 ┌──────┴─────────┐
 │                │
Qwen3Worker   Future Workers
               (Claude/GPT/Gemini)
```

Worker는 ExecutionContract를 실행하는 역할만 가진다.
Project Domain을 직접 수정하지 않는다.

### Required Components

#### 1. WorkerAdapter Interface
공통 인터페이스를 정의한다.

예시 역할:
- build_request()
- execute()
- collect_result()
- report_completion()

모든 Worker는 동일 인터페이스를 구현한다.

#### 2. Qwen3Worker
첫 번째 Worker 구현.

입력:
- ExecutionContract
- WorkspaceSnapshot
- AgentProfile

출력:
- WorkerResult

Qwen3 고유 Prompt는 PromptBuilder를 통해 생성한다.

#### 3. WorkerResult
실행 결과를 표현하는 표준 객체를 정의한다.

최소 포함 항목:
- status
- changed_files
- verification_summary
- produced_artifacts
- completion_notes

#### 4. Verification
WorkerResult가 ExecutionContract의 Acceptance Criteria를 만족하는지 검증한다.

검증 성공 시:
- ContractCompleted
- ContractVerified

Domain Event를 기록한다.

#### 5. AgentSession
실행 기록을 저장한다.

최소 정보:
- worker
- contract_id
- started_at
- finished_at
- duration
- result

### Explicitly Out of Scope
이번 Sprint에서는 구현하지 않는다.

- 자동 Git Commit
- 자동 Merge
- 자동 PR 생성
- 병렬 실행
- Scheduler
- Recovery Engine
- Event Persistence
- UI
- Web Dashboard

### Success Criteria
다음 시나리오가 동작해야 한다.

```text
Project

↓

Planner

↓

ExecutionContract

↓

WorkspaceSnapshot

↓

PromptBuilder

↓

Qwen3Worker

↓

WorkerResult

↓

Verification

↓

DomainEvent

↓

ProjectState Projection
```

### Tests
최소 다음 테스트를 추가한다.

- WorkerAdapter Contract 준수
- Qwen3Worker 실행
- WorkerResult 생성
- Verification 성공
- Domain Event 기록
- AgentSession 기록

기존 테스트는 모두 유지한다.

### Completion Criteria
다음을 만족하면 완료한다.

- Core Domain 변경 없음
- Worker Layer 추가
- 첫 번째 Worker(Qwen3) 실행 가능
- ProjectState가 정상 갱신됨
- 기존 테스트 모두 통과
- 새로운 Worker 테스트 모두 통과

### Phase 4 Acceptance Criteria
Atlas는 다음 실행 사이클을 스스로 관리할 수 있어야 한다.

```text
Project
    ↓
Planner
    ↓
ExecutionContract
    ↓
WorkspaceSnapshot
    ↓
PromptBuilder
    ↓
WorkerAdapter
    ↓
Qwen3Worker
    ↓
WorkerResult
    ↓
Verification
    ↓
DomainEvent
    ↓
ProjectState Projection
    ↓
ExecutionQueue Update
```

그리고 다음 조건을 만족해야 한다.

- 하나의 READY Contract를 선택할 수 있다.
- Worker에게 표준 ExecutionContract를 전달할 수 있다.
- Worker 결과를 표준 WorkerResult로 수신할 수 있다.
- Verification을 수행할 수 있다.
- Domain Event를 기록할 수 있다.
- ProjectState를 갱신할 수 있다.
- 다음 READY Contract를 선택할 수 있다.

### Master Principle
Atlas는 프로젝트를 실행하는 운영체제이다.

Worker는 프로젝트를 실행하는 실행기일 뿐이다.

이번 Sprint에서는 운영체제는 수정하지 말고, 첫 번째 Worker(Qwen3)를 연결하는 것만 수행한다.
