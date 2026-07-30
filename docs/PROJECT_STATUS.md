# Project Status

> **SUPERSEDED (2026-07-30)**  
> Live operational status is **`state/CURRENT_STATE.md`** and **`state/TASK_MAP.md`**.  
> This file describes an older Exelion-centric snapshot and is retained only for history.  
> Do not use it as the source of truth for Atlas DevOS work.

---

## 1. 현재 상태 (historical)

- Repo: Atlas DevOS
- 현재 브랜치: `main`
- 원격과 동기화됨
- 주요 문서 추가 완료: `PROJECT_OVERVIEW.md`, `PROJECT_EXECUTION_PLAN.md`
- Exelion 프로젝트는 `EX-GOAL-001` 및 `Sprint-001` 단계에 있으며, 초기 백로그가 정리된 상태
- `projects/exelion/backlog.json`에 4개 작업이 있으며, 첫 번째 작업은 `EX-BRAVE-001`

## 2. 주요 문서

- `README.md` — 리포지토리 전체 개요 및 구조
- `SYSTEM_MANIFEST.md` — 시스템 목표, 아키텍처, 현재 상태 요약
- `VISION.md` — 전략과 방향
- `PROJECT_OVERVIEW.md` — 현재 프로젝트 이해용 요약 문서
- `PROJECT_EXECUTION_PLAN.md` — 실행 계획 및 단계별 진행 계획
- `docs/PROJECT_STATUS.md` — 현재 상태 및 단기 실행 체크리스트
- `docs/OPERATIONS.md` — 일일 운영 절차
- `docs/ARCHITECTURE.md` — 아키텍처 계층 및 흐름
- `projects/exelion/sprints/Sprint-001.md` — 현재 스프린트 정의
- `projects/exelion/sprints/Sprint-001-tasklist.md` — 스프린트 작업 리스트
- `projects/exelion/sprints/Sprint-001-report.md` — 스프린트 보고서

## 3. 즉시 실행 항목 (historical — Exelion)

See original body below only if working on Exelion domain project.

### 현재 작업

| ID | Description | Target Stage | Estimated Time | Environment | Status |
| --- | --- | --- | --- | --- | --- |
| EX-BRAVE-001 | Brave 기본 프레임 제작 (Dummy Frame, 관절 구조, 공용 조인트) | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-002 | Brave 기본 프레임 UV 매핑 및 Export | Blender - UV 매핑 | 120 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-003 | Brave 외장 장갑 1개 제작 (Material Instance 적용, Naming Rule 검증) | Blender - Export 준비 | 150 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-004 | Brave Unreal Engine 임포트 및 셋업 (Import, Animation, Collision, Blueprint) | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |

## 5. 리스크 및 이슈 (historical)

- `excelion-forge/`, `projects/coin-s/`, `projects/exelion-forge/` tracking/cleanup may still apply under domain projects
- `DEV_WORK` vs `DEV_HOME` environment split
