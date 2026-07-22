# EXCELION DESIGN BIBLE

> Status : Active
> Version : 1.0
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 EXCELION 프로젝트의 모든 설계 문서를 연결하는 최상위 인덱스이다.

새로운 문서를 작성하기 전에 반드시 이 문서를 확인한다.

---

# 1. 프로젝트 비전

| 문서                   | 설명       | 상태 |
| -------------------- | -------- | -- |
| VISION.md            | 프로젝트 비전  | ✅  |
| 01_DESIGN_PILLARS.md | 핵심 설계 철학 | ✅  |

---

# 2. 게임 디자인

| 문서                   | 설명          | 상태 |
| -------------------- | ----------- | -- |
| 02_GAMEPLAY.md       | 게임플레이       | ✅  |
| 03_WORLD.md          | 세계관         | ✅  |
| 04_EXCELION.md       | EXCELION 설정 | ✅  |
| 05_ENEMIES.md        | 적 설계        | ✅  |
| 05_S_CORE.md         | S-Core 시스템  | ✅  |
| 07_COMBAT_SYSTEM.md  | 전투 시스템      | ✅  |
| 08_MISSION_DESIGN.md | 미션 구조       | ✅  |
| 09_GAME_LOOP.md      | 게임 루프       | ✅  |
| 10_PROTOTYPE.md      | 프로토타입 정의    | ✅  |

---

# 3. 기술 설계

| 문서                        | 설명                     | 상태 |
| ------------------------- | ---------------------- | -- |
| 11_PROJECT_ROADMAP.md     | 로드맵 및 실행 개요          | ✅  |
| 12_PROJECT_STRUCTURE.md   | 저장소 구조                 | ✅  |
| 13_UNREAL_ARCHITECTURE.md | Unreal 아키텍처            | ✅  |
| 14_CODING_STANDARD.md     | 코딩 규칙                  | ✅  |
| 15_ASSET_PIPELINE.md      | Blender → Unreal 파이프라인 | ✅  |
| 16_GIT_WORKFLOW.md        | Git 운영 규칙              | ✅  |

---

# 4. 프로젝트 관리

| 문서                           | 설명          | 상태 |
| ---------------------------- | ----------- | -- |
| 17_DEVELOPMENT_ROADMAP.md    | 장기 개발 계획    | ✅  |
| 18_SPRINT_01.md              | 첫 번째 Sprint | ✅  |
| 19_DEVELOPMENT_PRINCIPLES.md | 개발 원칙       | ✅  |

---

# 5. Excelion Forge

| 문서            | 설명              | 상태 |
| ------------- | --------------- | -- |
| ROADMAP.md    | Forge 개발 로드맵   | ✅  |
| SPEC.md       | Forge 검증 범위     | ✅  |
| ARCHITECTURE.md | Forge 구조 흐름   | ✅  |
| API.md        | Python API 기준   | ✅  |
| CHANGELOG.md  | 변경 이력           | ✅  |

---

# 문서 작성 규칙

새로운 문서를 추가할 때는 다음을 반드시 수행한다.

1. INDEX.md에 등록한다.
2. 관련 문서를 연결한다.
3. 버전을 기록한다.
4. 변경 이력을 남긴다.

---

# 문서 의존성

```text
VISION
    │
    ├── DESIGN PILLARS
    │
    ├── GAMEPLAY
    │     ├── COMBAT
    │     │      ├── S-CORE
    │     │      └── ENEMIES
    │     │
    │     └── MISSION
    │             │
    │             └── GAME LOOP
    │                     │
    │                     └── PROTOTYPE
    │
    ├── TECHNICAL
    │      ├── PROJECT STRUCTURE
    │      ├── UNREAL
    │      ├── CODING
    │      ├── PIPELINE
    │      └── GIT
    │
    └── PRODUCTION
           ├── ROADMAP
           ├── SPRINT
           └── DEVELOPMENT PRINCIPLES
```

---

# 프로젝트 진행 순서

Design

↓

Prototype

↓

Vertical Slice

↓

Alpha

↓

Beta

↓

Steam Release

---

# 최종 목표

EXCELION은 단순한 게임 프로젝트가 아니다.

재사용 가능한 메카 액션 개발 플랫폼과 오리지널 IP를 구축하는 것을 목표로 한다.
