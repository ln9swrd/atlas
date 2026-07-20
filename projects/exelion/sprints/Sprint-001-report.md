# Sprint-001: Prototype Foundation - Report

## Executive Summary

This report documents the completion of Sprint-001 for the Exelion project, focusing on establishing the foundation for the first playable prototype. The sprint involved reviewing the project charter and goal context, validating existing backlog items for prototype relevance, defining production pipeline checkpoints, and recording the first recommended next task.

## Sprint Overview

### Goal
Establish the initial prototype planning and production readiness for Exelion.

### Status
Completed

### Objective
- Review charter and goal context.
- Validate existing backlog items for prototype relevance.
- Define the first production pipeline checkpoints.
- Record the first recommended next task.

## Key Findings

1. **Environment Setup**: The project utilizes two distinct environments:
   - DEV_WORK (Company PC): Production environment with Blender, Python, VS Code, Atlas, and Git available
   - DEV_HOME (Home PC): Integration environment with Unreal Engine, GPU, and AI models available

2. **Backlog Analysis**: The current backlog contains four items related to Brave character development:
   - Basic frame creation (modeling)
   - UV mapping
   - External glove creation
   - Unreal Engine import and setup

3. **Production Pipeline**: Based on the environment constraints and project goals, the production pipeline should be structured to leverage the company PC for production work and home PC for integration and validation.

## Recommendations

1. **Task Assignment Strategy**:
   - Assign modeling tasks (EX-BRAVE-001, EX-BRAVE-002, EX-BRAVE-003) to DEV_WORK environment
   - Assign Unreal Engine import and setup (EX-BRAVE-004) to DEV_HOME environment

2. **Next Steps**:
   - Implement the production pipeline checkpoints defined in this sprint
   - Begin execution of the first recommended task: Basic frame creation for Brave character

## Sprint Status

- Current focus: `EX-BRAVE-001` — Brave 기본 프레임 제작
- Current status: `Ready to start`
- Expected next update: `task progress / blockers / decisions`

## Progress Log

| Date | Item | Status | Notes |
| --- | --- | --- | --- |
| 2026-07-20 | Sprint-001 planning | Completed | 기본 스프린트 구조와 환경 분리가 정리됨 |
| 2026-07-20 | EX-BRAVE-001 task 우선화 | Completed | DEV_WORK 우선 수행 예정 |

## Current Backlog Snapshot

- `EX-BRAVE-001` — Brave 기본 프레임 제작 (In Progress)
- `EX-BRAVE-002` — Brave 기본 프레임 UV 매핑 및 Export (Pending)
- `EX-BRAVE-003` — Brave 외장 장갑 1개 제작 (Pending)
- `EX-BRAVE-004` — Unreal 임포트 및 셋업 (Pending)

### Current Backlog Snapshot

| ID | Description | Target Stage | Estimated Time | Environment | Status |
| --- | --- | --- | --- | --- | --- |
| EX-BRAVE-001 | Brave 기본 프레임 제작 (Dummy Frame, 관절 구조, 공용 조인트) | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-002 | Brave 기본 프레임 UV 매핑 및 Export | Blender - UV 매핑 | 120 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-003 | Brave 외장 장갑 1개 제작 (Material Instance 적용, Naming Rule 검증) | Blender - Export 준비 | 150 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-004 | Brave Unreal Engine 임포트 및 셋업 (Import, Animation, Collision, Blueprint) | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |

## Risks and Blockers

- Unreal Engine은 DEV_HOME에서만 실행 가능하므로 `EX-BRAVE-004`는 회사 PC에서 진행할 수 없음
- 모델링부터 수출까지의 규칙 및 파이프라인 검증이 필요함
- `excelion-forge/`, `projects/coin-s/`, `projects/exelion-forge/`가 언트랙 상태인 것을 후속으로 정리해야 함

## Environment Considerations

The environment split between Company PC (DEV_WORK) and Home PC (DEV_HOME) has been carefully considered in planning. Tasks requiring Unreal Engine or GPU-intensive AI work will be executed on DEV_HOME, while production modeling and documentation tasks will be handled on DEV_WORK.

This approach ensures optimal resource utilization and follows the established project guidelines for task distribution.