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
