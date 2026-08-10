# Excelion Unreal Engine 개발 준비 — GitHub 작업지시

> 작성: 2026-08-10
> 목적: Unreal 실제 개발 전 설계·기술·콘텐츠 기준 확정
> 범위 제외: Unreal 프로젝트 생성 및 실제 코드 구현

---

## 작업 목적

`ln9swrd/atlas/projects/excelion`을 기준으로, Unreal Engine 실제 개발에 들어가기 전 설계·기술·콘텐츠 기준을 확정한다.

현재 단계에서는 Unreal 프로젝트를 생성하거나 코드를 구현하지 않는다.

목표는 이후 개발 환경에서 즉시 Unreal 프로젝트 구축을 시작할 수 있는 상태를 Git에 만드는 것이다.

---

## 작업 원칙

1. 기존 Excelion 문서를 먼저 조사한다.
2. 기존 설정과 충돌하는 내용을 임의로 변경하지 않는다.
3. 기존 planning, design, novel, prototype의 내용을 최대한 재사용한다.
4. 새로운 기술 결정은 실제 Unreal Engine에서 구현 가능한 수준으로 작성한다.
5. 과도한 시스템 설계를 피한다.
6. 게임의 핵심은 슈퍼로봇 메카 전투라는 점을 유지한다.
7. 건담식 리얼로봇 설계 방향으로 변경하지 않는다.
8. 모든 변경은 Git에 기록한다.
9. 작업 중단에 대비해 현재 진행상태와 다음 작업을 문서 또는 커밋에 남긴다.
10. 기존 파일을 삭제하지 않는다. 필요한 경우 새 문서를 추가하거나 최소한으로 수정한다.

---

## 1. 기존 프로젝트 조사

먼저 다음을 확인한다.

```text
projects/excelion/README.md
projects/excelion/PROJECT_CHARTER.md
projects/excelion/PROJECT_MEMORY.md
projects/excelion/backlog.json
projects/excelion/design/
projects/excelion/novel/
projects/excelion/prototype/
projects/excelion/state/
projects/excelion/sprints/
```

특히 다음 정보를 추출한다.

- 게임 장르
- 핵심 플레이
- 플레이어 메카
- 적 메카
- 보스
- 전투 방식
- 카메라
- 스토리와 게임플레이의 관계
- 기존 프로토타입의 기능
- 이미 결정된 디자인 규칙
- 아직 결정되지 않은 항목

기존 설정과 신규 설계를 구분해서 기록한다.

---

## 2. Unreal 개발 기준 문서 작성

생성:

```text
projects/excelion/docs/UNREAL_DEVELOPMENT_CHARTER.md
```

포함 내용:

- Unreal Engine 개발 목적
- 목표 플랫폼
- 게임 장르
- 핵심 게임플레이
- 카메라 방향
- 전투 중심 설계
- 개발 범위
- 개발 제외 범위
- Vertical Slice 목표
- 기술적 우선순위
- 현재 단계
- 다음 단계

---

## 3. Unreal 기술 아키텍처

생성:

```text
projects/excelion/docs/UNREAL_ARCHITECTURE.md
```

다음 영역을 실제 구현 가능성을 기준으로 설계한다.

**Engine**
- Unreal Engine 5.x

**Gameplay**
- C++
- Blueprint

핵심 시스템은 C++ 중심으로 설계하고 Blueprint는 콘텐츠 조정 및 에디터 작업에 활용한다.

**Input**
- Enhanced Input

**UI**
- UMG

**Animation**
- Animation Blueprint
- Montage
- Blend Space
- 필요 시 IK

**AI**
- AI Controller
- Behavior Tree
- EQS 필요 여부 검토

**VFX**
- Niagara

**Audio**
- MetaSounds 및 Unreal Audio 시스템

**Data**
- Data Asset
- Data Table
- Gameplay Tags 필요 여부 검토

**Save**
- SaveGame

각 기술을 단순 나열하지 말고 Excelion에서 어디에 사용하는지 명시한다.

---

## 4. 기술 요구사항

생성:

```text
projects/excelion/docs/TECHNICAL_REQUIREMENTS.md
```

포함:

- 목표 해상도
- 목표 FPS
- 카메라 요구사항
- 메카 수
- 전투 중 동시 액터 수 예상
- VFX 요구사항
- 애니메이션 요구사항
- 물리 사용 범위
- AI 요구사항
- 저장 요구사항
- UI 요구사항
- 성능 관리 기준
- 향후 확장성을 고려한 제한사항

확정되지 않은 수치는 임의로 확정하지 말고 TBD로 표시한다.

---

## 5. 핵심 게임플레이 설계

생성:

```text
projects/excelion/design/gameplay/CORE_GAMEPLAY.md
```

다음을 정의한다.

```text
탐색
 ↓
적 조우
 ↓
전투
 ↓
보상 / 진행
 ↓
다음 구역
```

각 단계의 실제 플레이 목적을 설명한다.

---

## 6. 전투 시스템 설계

생성:

```text
projects/excelion/design/gameplay/COMBAT_SYSTEM.md
```

최소 다음 항목을 정의한다.

- 이동
- 회피
- 근접 공격
- 원거리 공격
- 방어 / 가드
- 락온
- 피격
- 경직
- 다운
- 데미지
- 에너지
- 무기
- 필살기
- 적 AI
- 보스전
- 전투 종료

각 시스템에 대해:

```text
플레이 목적
↓
게임 규칙
↓
Unreal 구현 후보
↓
필요 데이터
```

순서로 정리한다.

---

## 7. 메카 시스템 설계

생성:

```text
projects/excelion/design/mecha/MECHA_SYSTEM.md
```

슈퍼로봇 중심으로 설계한다.

공통 구조:

```text
BaseMecha
 ├─ PlayerMecha
 ├─ EnemyMecha
 └─ BossMecha
```

주요 컴포넌트:

```text
Movement
Combat
Weapon
Damage
Armor
Energy
Targeting
Animation
AI
VFX
Audio
```

단, 실제 Unreal 구현에 필요하지 않은 컴포넌트를 무조건 분리하지 않는다.

---

## 8. 메카 데이터 구조

생성:

```text
projects/excelion/design/mecha/MECHA_DATA_SCHEMA.md
```

다음을 정의한다.

- 기본 스탯
- HP
- Armor
- Energy
- 이동속도
- 공격력
- 무기
- 공격속도
- 경직
- 필살기
- AI 설정
- 애니메이션 참조
- VFX 참조
- 사운드 참조

Data Asset / Data Table 중 적합한 방식을 결정하고 이유를 기록한다.

---

## 9. 아트 제작 규격

생성:

```text
projects/excelion/design/art/ART_DIRECTION.md
projects/excelion/design/art/MECHA_MODELING_GUIDELINE.md
projects/excelion/design/art/MATERIAL_GUIDELINE.md
projects/excelion/design/art/VFX_GUIDELINE.md
```

반드시 현재 Excelion의 방향을 유지한다.

**메카 디자인**
- 슈퍼로봇
- 강한 실루엣
- 곡선 적극 활용
- 캐릭터성이 명확해야 함
- 건담식 리얼로봇 방향 금지

**디테일**
- 전체 장갑은 단순화
- 가동부에는 필요한 디테일 허용
- 과도한 패널라인 금지
- 색상 기준 약 3톤
- 장거리에서도 실루엣이 먼저 읽혀야 함

아트 규격은 단순 미술 설명이 아니라 Unreal 에셋 제작으로 연결될 수 있도록 작성한다.

---

## 10. 에셋 등록표

생성:

```text
projects/excelion/docs/ASSET_REGISTER.md
```

카테고리:

```text
PLAYER MECHA
ENEMY MECHA
BOSS
WEAPON
ANIMATION
ENVIRONMENT
VFX
AUDIO
UI
```

각 에셋에:

- 이름
- 종류
- 용도
- 우선순위
- 제작 상태
- Unreal 적용 상태
- 선행 작업
- 비고

를 기록한다.

확정되지 않은 에셋은 임의로 추가하지 않는다.

---

## 11. Vertical Slice 설계

별도 문서가 필요하면:

```text
projects/excelion/docs/VERTICAL_SLICE.md
```

목표:
5~10분 내외의 실제 플레이 가능한 전투 데모

범위를 최소화한다.

예상 범위:

```text
플레이어 메카 1
적 메카 1종
보스 1
전투 지역 1
무기 2~3
기본 전투
필살기 1
기본 UI
기본 VFX
```

단, 기존 Excelion 설정과 충돌하면 기존 설정을 우선한다.

---

## 12. 개발 준비 상태 문서

현재 상태를 다음 파일에 기록한다.

```text
projects/excelion/state/UNREAL_PREPARATION_STATUS.md
```

반드시 포함:

```text
## 완료
...

## 진행 중
...

## 미착수
...

## 결정 필요
...

## 다음 작업
...
```

이 문서는 이후 다른 에이전트가 작업을 이어갈 수 있도록 작성한다.

---

## 13. Git 작업

작업 완료 후 반드시:

1. 변경 파일 확인
2. 기존 문서와 충돌 여부 확인
3. Markdown 링크/경로 확인
4. Git diff 확인
5. 커밋

권장 커밋:

```text
docs(excelion): prepare Unreal development specifications
```

작업 도중 의미 있는 단계가 완료되면 중간 커밋을 남겨도 된다.

---

## 14. 최종 검증

완료 후 다음을 확인한다.

- 기존 Excelion 설정과 충돌하지 않는가?
- Unreal에서 실제 구현 가능한가?
- 지나치게 복잡한 아키텍처가 아닌가?
- C++ / Blueprint 역할이 명확한가?
- 메카 시스템을 여러 기체가 공유할 수 있는가?
- 슈퍼로봇 디자인 방향이 유지되는가?
- Vertical Slice 범위가 현실적인가?
- 다음 에이전트가 문서만 보고 작업을 이어갈 수 있는가?
- Git commit이 남아 있는가?

그리고 최종 결과를 다음 형식으로 보고한다.

```text
[Excelion Unreal 준비 작업 결과]

완료:
- ...

생성/수정 파일:
- ...

Git Commit:
- <SHA>

결정 필요:
- ...

다음 작업:
- ...
```

---

## 중요

Unreal 프로젝트 생성 및 실제 코드 구현은 이번 작업 범위에서 제외한다.
