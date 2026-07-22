# Atlas Project Overview

## 1. 프로젝트 요약

- 프로젝트명: Atlas DevOS
- 현재 버전/상태: v1.2 RC, 아키텍처 기반이 안정화된 상태
- 목적: AI 중심 개발 운영체제로서 프로젝트 실행을 자동화하고, 실질적인 게임/IP 제작 과제를 통해 시스템을 검증
- 주력 프로젝트: Excelion (mecha IP, 프로토타입 시작)
- 핵심 가치: 증거 기반( Evidence-First ), 프로젝트 중심, 실행 중심, 반복 가능한 작업 흐름

## 2. 현재 주요 문서

- `README.md` - 전체 리포지토리와 디렉토리 구조, 실행 흐름, 에이전트 매핑
- `PROJECT_OVERVIEW.md` - 프로젝트 전반 요약
- `PROJECT_EXECUTION_PLAN.md` - 실행 계획과 우선순위
- `PROJECT_ANALYSIS_PLAN.md` - Atlas DevOS 심층 분석 계획서
- `PROJECT_ANALYSIS_REPORT.md` - Atlas DevOS 심층 분석 결과 보고서
- `PROJECT_IMPLEMENTATION_PLAN.md` - Atlas DevOS 코어 플랫폼 구현 계획서
- `SYSTEM_MANIFEST.md` - 시스템 목적, 핵심 개념, 아키텍처 링크, 현재 상태 요약
- `VISION.md` - 전략적 미션과 장기 목표
- `PROJECT_REGISTRY.md` - Atlas/Excelion/Coin-S 등 프로젝트 현황
- `docs/ARCHITECTURE.md` - 층별 아키텍처와 런타임 흐름
- `docs/OPERATIONS.md` - 일일 운영 절차 및 실행 흐름
- `docs/ROADMAP.md` - v1.2, v1.3, v2.0 단계
- `ATLAS_SPRINT_021_DECISIONS.md` - 핵심 아키텍처 결정과 원칙
- `projects/excelion/PROJECT_CHARTER.md` - Excelion 프로젝트 헌장
- `projects/excelion/goals/EX-GOAL-001.md` - 첫 번째 Excelion 실행 목표
- `todo.md` - 현재 검토된 작업 목록

## 3. 핵심 구조 요약

### Atlas 구조
- `core/` - Atlas 엔진, 룰, 리뷰, 실행, 워크플로우
- `projects/` - 실제 프로젝트 인스턴스 (현재 Excelion 중심)
- `docs/` - 아키텍처, 운영, 결정 기록, 플레이북 등 지식 기록
- `tools/` - 실행 도구 및 Runner

### 핵심 개념
- RuntimeContext: 실행 컨텍스트를 불변으로 구성
- Registry: 공용 데이터(목표, 환경, 상태 등)
- Resolver: 상황에 맞는 컨텍스트 수집
- Priority Engine: 다음 작업 추천
- Runner: 실행 및 상태 업데이트

## 4. 지금까지 한 일

- Atlas DevOS의 기본 아키텍처 수립
- RuntimeContext / ContextResolver / Priority Engine 설계
- 운영 절차와 일일 실행 루프 문서화
- Excelion을 첫 번째 실증 프로젝트로 정의
- Phase 3 아키텍처 동결 목표 설정

### 현재 주요 백로그

| ID | Description | Target Stage | Estimated Time | Environment | Status |
| --- | --- | --- | --- | --- | --- |
| EX-BRAVE-001 | Brave 기본 프레임 제작 (Dummy Frame, 관절 구조, 공용 조인트) | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-002 | Brave 기본 프레임 UV 매핑 및 Export | Blender - UV 매핑 | 120 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-003 | Brave 외장 장갑 1개 제작 (Material Instance 적용, Naming Rule 검증) | Blender - Export 준비 | 150 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-004 | Brave Unreal Engine 임포트 및 셋업 (Import, Animation, Collision, Blueprint) | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-005 | Primary Weapon (Rifle/Sword) 3D Modeling & UV | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-006 | Joint Rigging & Basic Motion Clips | Blender - 리깅 | 150 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-007 | Unreal Animation Blueprint (ABP) & Socket Setup | Unreal - 임포트/설정 | 210 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-008 | Action Camera & Motion Test Map Validation | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-009 | Enemy Mech 3D Modeling & Collision Setup | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-010 | Enemy Behavior Tree (BT) & AI Perception | Unreal - 임포트/설정 | 210 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-011 | Weapon Hit Impact & FX Particle System | Unreal - 임포트/설정 | 150 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-012 | Prototype Battle Arena Map & Playtest Validation | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-013 | Player HUD & Mech Status UI Blueprint Setup | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-014 | Audio Sound Cue & Spatial SFX Attenuation Setup | Unreal - 임포트/설정 | 150 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-015 | Post-Processing & Cinematic Lighting Polish | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-016 | Alpha Prototype Standalone Build & Pre-flight Review | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-017 | Secondary Weapon (Heavy Launcher / Energy Shield) 3D Asset & Rigging | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-018 | Weapon Swap & Ammo Management Gameplay System | Unreal - 임포트/설정 | 210 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-019 | Boss Class Heavy Mech AI Pattern & Phase Transition | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-020 | Destructible Environmental Props & Chaos Physics Setup | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-021 | Multi-Weapon Attachment & Socket Mesh Dynamic Component | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-022 | Particle System Performance Profiling & LOD Optimization | Unreal - 임포트/설정 | 210 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-023 | Local Multiplayer Split-Screen / Co-op Arena Blueprint | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-024 | Beta Build Packaging & Production Readiness Audit | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-025 | High-poly Hero Mech LOD Group & Mesh Reduction | Blender - 모델링 | 180 | DEV_WORK (Company PC) | Pending |
| EX-BRAVE-026 | Global Post-Process Volume & Color Grading Finalization | Unreal - 임포트/설정 | 180 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-027 | Cross-Platform Input Remapping & Gamepad Profile | Unreal - 임포트/설정 | 210 | DEV_HOME (Home PC) | Pending |
| EX-BRAVE-028 | Release Candidate Build Pipeline & Final Scorecard Audit | Unreal - 임포트/설정 | 240 | DEV_HOME (Home PC) | Pending |

## 5. 지금 진행 중인 방향

- Excelion Alpha Prototype 패키징 완료 및 검증 통과 (Scorecard 93.7점)
- 차기 버티컬 슬라이스(Vertical Slice) 및 베이직 콘텐츠 확장 백로그 준비
- Atlas DevOS 실행 런타임 및 Pre-flight Rule Check 동기화 유지

### 자동화 및 사용 가이드 (요약)

- 일일 시작: `python3 tools/atlas_runner.py start` 또는 `./scripts/daily_start.sh` — 추천 작업 생성 및 `ATLAS_STATE.json` 초기화
- 작업 전환: `python3 tools/atlas_runner.py next` — 다음 작업 선택 및 상태 업데이트
- 작업 완료/종료: `python3 tools/atlas_runner.py finish-task` 또는 `./scripts/daily_end.sh` — 검증 엔진 및 리뷰 엔진 실행 포함
- CI: `.github/workflows/atlas-ci.yml`가 추가되어 push/PR 시 규칙 엔진 및 시뮬레이션을 실행합니다.

위 명령어는 WSL 환경에서는 `python3`로 실행하세요. Windows PowerShell에서는 `python`일 수 있습니다.

## 6. 다음에 해야 할 일

1. `projects/excelion` 내부 현황과 백로그를 확인하여 현재 진행 중인 실제 작업을 정리
2. `SYSTEM_MANIFEST.md`와 `docs/OPERATIONS.md`를 기준으로 현재 우선순위와 일일 실행 방법을 명확히 정리
3. 문서 자동화 계획 수립
   - 주요 문서 요약 자동 생성
   - `git` 반영 흐름 정의
4. 필요한 추가 문서 작성
   - `PROJECT_OVERVIEW.md` (현재 완료)
   - `docs/PROJECT_STATUS.md` 또는 `docs/PROJECT_EXECUTION.md`
   - `DECISIONS.md` 스타일 결정 기록

## 7. 제안된 단계별 진행 계획

### 단계 1: 현재 문서 정리
- 현재 문서 목록과 핵심 내용을 빠르게 정리
- `PROJECT_OVERVIEW.md`로 전체 현황 요약
- `todo.md`에 현재 바로 할 일 정리

### 단계 2: 액션 아이템 정의
- Excelion의 현재 목표와 다음 스프린트 작업 추출
- `SYSTEM_MANIFEST.md` 기준으로 현재 초점 확인
- `docs/ROADMAP.md`와 실제 작업의 간극 분석

### 단계 3: 문서 자동화 준비
- 문서 자동화 스크립트 설계
- `scripts/` 또는 `tools/`에 자동 문서 갱신 스크립트 추가
- 자동 커밋/푸시 프로세스 설계

### 단계 4: 실행 및 검토
- 하루 시작 / 종료 절차에 맞춰 문서와 상태를 업데이트
- 변경 사항을 `git`으로 관리하고 커밋
- 문서화된 현황을 기준으로 다음 작업 계획

## 8. 현재 git 상태 요약

- 현재 브랜치: `main`
- 원격 `origin/main`과 동일
- 로컬에 `excelion-forge/`, `projects/coin-s/`, `projects/excelion-forge/`가 언트랙된 상태

> 먼저 원격과 동기화된 상태로 문서를 정리하고, 이후 실작업과 커밋 흐름을 단계적으로 진행하는 것이 적절합니다.
