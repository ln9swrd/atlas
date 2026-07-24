# Project Status

## 1. Current Status

* Last Sync: `2026-07-23`
* Repository: `Atlas DevOS`
* Branch: `main`

## Current Project

* Active Project: `Excelion`
* Current Sprint: `Sprint-004`
* Mode: `Development`
* Last Review: `PASS`

## Current Phase

Atlas DevOS:

* Architecture baseline stabilization
* Runtime / Documentation structure refinement
* AI Agent workflow preparation

Excelion:

* Prototype development preparation
* Asset Pipeline definition
* Blender / Unreal production workflow validation

---

# 2. Source of Truth

현재 상태 판단 기준:

1. `ATLAS_STATE.json`

   * Runtime 상태

2. `docs/PROJECT_STATUS.md`

   * 현재 작업 상태

3. `projects/excelion/backlog.json`

   * Excelion 작업 목록

4. Sprint 문서

   * 세부 작업 계획 및 결과

상태 충돌 발생 시 Runtime 상태와 최신 Status 문서를 우선한다.

---

# 3. Development Environment

## DEV_WORK (Company PC)

사용 목적:

* 문서 작업
* 코드 분석
* AI Agent 작업
* Blender 기반 Asset 준비 작업

## DEV_HOME (Home PC)

사용 목적:

* Unreal Engine 작업
* Forge 개발
* Blender / Unreal 통합 테스트
* 고사양 실행 환경 필요 작업

환경 제약:

* Unreal Engine 관련 작업은 DEV_HOME에서 수행
* 회사 환경에서는 실행 검증보다 설계 및 문서 작업 중심

---

# 4. Current Focus

## Atlas DevOS

현재 작업:

* Context 관리 구조 정리
* 문서 기반 상태 관리 개선
* AI Agent 작업 진입점 정리
* SERA / Forge / MCP 책임 영역 정의

## Excelion

현재 작업:

* Brave Prototype Pipeline 정의
* Asset 제작 흐름 검토
* Blender → Unreal 연동 구조 준비

---

# 5. Active Tasks

현재 진행 대상:

| ID           | Description                                   | Environment | Status  |
| ------------ | --------------------------------------------- | ----------- | ------- |
| EX-BRAVE-029 | Phantom Stealth Mech 3D Model & Rigging       | DEV_WORK    | Pending |
| EX-BRAVE-017 | Secondary Weapon Asset & Rigging              | DEV_WORK    | Pending |
| EX-BRAVE-018 | Weapon Swap & Ammo Management Gameplay System | DEV_HOME    | Pending |

세부 백로그:

```
projects/excelion/backlog.json
```

관리.

---

# 6. Next Actions

## Immediate

1. Atlas 문서 기준선 확정
2. Forge Architecture 정의
3. SERA Runtime 구조 정리
4. MCP Integration 방향 검토

## Excelion

1. Brave Asset Pipeline 정의
2. Blender 제작 환경 검증
3. Unreal Import Pipeline 준비

---

# 7. Automation Status

현재 자동화 영역:

* `tools/atlas_runner.py`

역할:

* 작업 시작
* 상태 확인
* 검증 실행
* 결과 기록

CI:

```
.github/workflows/atlas-ci.yml
```

관리.

---

# 8. Risks and Issues

## State Synchronization

확인 필요:

* `ATLAS_STATE.json`
* `projects/excelion/backlog.json`

간 상태 동기화.

## Environment Dependency

* DEV_WORK / DEV_HOME 환경 차이 관리 필요
* Unreal 관련 작업은 Home 환경 기준

## Documentation Drift

주의:

* 새로운 문서 생성 시 기존 Source of Truth와 책임 영역 확인
* 동일 목적 문서 중복 생성 방지

---

# 9. Recent Decisions

## Documentation Structure

확정 방향:

* README

  * 진입점

* PROJECT_OVERVIEW

  * 전체 방향

* PROJECT_STATUS

  * 현재 상태

* Project Documents

  * 상세 개발 내용

## Architecture Direction

향후 정의 대상:

* SERA
* Forge
* MCP
* Excelion Production Pipeline

---

# Summary

현재 Atlas DevOS는 실행 시스템 자체보다,
AI 기반 개발 환경을 위한 구조 정리와 기준선 확립 단계에 있다.

Excelion은 Atlas를 검증하는 실제 프로젝트이며,
Forge, SERA, MCP는 향후 제작 자동화 및 AI 협업 환경을 구성하는 핵심 시스템으로 확장한다.

현재 우선순위는 새로운 기능 추가보다,
명확한 책임 영역과 지속 가능한 개발 흐름을 확립하는 것이다.
