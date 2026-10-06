# MENOS 개발계획 — Canon 기준 재정립판

> 작성일: 2026-09-30
> 상태: MASTER REQUESTED PLAN / 실행 전 계획
> 기준: Master 승인 Canon + 현재 실제 구현 상태
> 목적: 이미 구현된 기능을 다시 개발하지 않고, 실제 구현 공백을 최소 작업 단위로 완성한다.

## 1. 개발 목표

MENOS의 최종 전투 구조는 플레이어가 슈퍼로봇 1기를 직접 조종하고, AI 아군과 고정형 지원 시설의 도움을 받아 일반 적 다수 및 거대 보스와 싸우는 싱글플레이 게임이다.

현재 프로젝트에는 직접 이동, 기본 공격, 타깃 선택/전환, 특수공격, 스킬 슬롯, 필살기, XP/즉시 레벨업, AI 아군, Campaign/Single Play, Stage/Map 로딩 등 상당수 기반 기능이 이미 존재한다.

따라서 개발계획은 처음부터 시스템을 다시 만드는 방식이 아니라 **현재 구현을 보존하면서 Canon과 실제 구현 사이의 공백을 닫는 방식**으로 재편한다.

## 2. 절대 기준

우선순위:
1. `MENOS_COMBAT_CANON.md` — Master 승인 Canon
2. 본 문서 — Canon을 실제 구현으로 완성하기 위한 개발계획
3. `MENOS_REQUIRED_IMPLEMENTATION_GAPS.md` — 실제 구현 공백 목록
4. 기존 설계/마이그레이션 문서 — Canon과 충돌하지 않는 범위에서 참고
5. 현재 코드/Asset/Data — 실제 현황

Canon과 기존 문서가 충돌하면 Canon을 따른다.

본 문서는 Canon을 변경하지 않는다.

## 3. 현재 기준선

- Branch: `main`
- HEAD: `8cc4e5ab321fb20db9f432bda8a13594f253244a`
- Working Tree: 이미지 중복/부적합 Asset 격리 작업의 기존 변경사항 존재
- 게임 코드/Asset/Scene/Data는 이번 계획 작성에서 변경하지 않는다.

현재 확인된 구현:
- Robot 직접 이동
- 기본 공격
- 타깃 선택 및 전환
- Special
- 스킬 슬롯 3개
- Finisher
- 전투 중 XP 및 즉시 레벨업
- AI 아군
- 승리/패배/재시작
- Campaign / Single Play 분기
- Stage Select
- StageManager / StageLoader / MapLoader
- 기본 Tower 자동 공격

PIE는 현재 검증하지 않는다.

## 4. 개발 원칙

### 4.1 목적 우선
각 작업은 `목적 확인 → 최소 변경 → 최소 검증 → 판정 → 종료` 순으로 수행한다.

### 4.2 이미 구현된 것은 다시 만들지 않는다
현재 코드에서 구현이 확인된 기능은 유지하고, 필요한 경우에만 Canon에 맞게 수정한다.

### 4.3 한 번에 하나의 핵심 변수를 바꾼다
전투 입력, HUD, Tower, Boss 등 서로 다른 시스템을 한 작업에서 동시에 대규모 변경하지 않는다.

### 4.4 READ-ONLY 우선
각 Phase 시작 시 현재 코드/데이터를 먼저 조사한다. 확인되지 않은 원인을 사실로 취급하지 않는다.

### 4.5 검증 상태를 분리한다
`CODE VERIFIED`, `BUILD VERIFIED`, `EDITOR VERIFIED`, `PIE VERIFIED`를 혼동하지 않는다.

### 4.6 성공하면 멈춘다
한 Phase의 성공 조건을 만족하면 자동으로 다음 Phase를 시작하지 않는다.

## 5. 최종 구현 공백

현재 실제 구현이 필요한 항목은 5개로 관리한다.

### GAP-01 — Pilot 중심 전투 HUD
우선순위: P0

필요 작업:
- Robot HP / 에너지 / XP / 레벨을 핵심 정보로 재배치
- 현재 타깃과 타깃 HP 명확화
- 기본 공격 / 특수무기 / 스킬 / 필살기 상태 표시
- 쿨다운 및 사용 가능 상태 표시
- Tower 건설/업그레이드 UI의 주 전투 HUD 의존성 제거

완료 기준:
- 전투 화면의 시각적 중심이 플레이어 Robot이다.
- 현재 사용 가능한 전투 행동을 HUD만으로 파악할 수 있다.

### GAP-02 — 보스전 전용 행동
우선순위: P0

필요 작업:
- Giant 전용 공격 패턴 또는 상태 전환
- 공격을 피하거나 대응할 수 있는 명확한 빈틈
- 보스 타깃 고정/상태 표시
- 기존 이동/공격/특수/필살기와 보스 행동 연결

완료 기준:
- 별도 조작 없이 기존 전투 조작으로 1:1 보스전이 성립한다.
- 보스가 단순 HP 증가형 적으로 끝나지 않는다.

### GAP-03 — Tower의 고정형 지원 시설 전환
우선순위: P1

필요 작업:
- Tower 자동 공격 구조 유지
- 플레이어의 반복적인 직접 Tower 운영 의존성 제거
- 지원 시설로서 역할 정의
- 필요한 경우 스테이지에 미리 배치되거나 제한된 위치에 설치되도록 정리
- 1~2종 지원 역할을 먼저 검증

주의:
- Tower 시스템을 삭제하지 않는다.
- 구체적인 배치/업그레이드 정책은 Master가 결정한다.

완료 기준:
- 플레이어가 Tower를 관리하지 않아도 Robot 직접 전투가 성립한다.
- Tower가 전투의 주체가 아니라 Robot을 보조한다.

### GAP-04 — 공격→피격→피해 연출 동기화
우선순위: P2

필요 작업:
- 기본 투사체 도착 시점과 피해 판정 연결
- 피격 반응 및 피해 표시 시점 정렬
- 필요한 공격 유형부터 최소 범위로 적용

완료 기준:
- 화면에서 발사 → 도착 → 피격 → 피해가 자연스럽게 연결된다.

### GAP-05 — Campaign 1 Canon 통합
우선순위: P0

필요 작업:
- 기존 Stage/Map/전투/성장/승패 시스템 연결
- Pilot HUD 반영
- 지원 시설 반영
- 보스전 반영
- Campaign 1 최소 1개 스테이지의 시작→전투→성장→승패→진행 루프 완성

완료 기준:
- Campaign 1 최소 1개 스테이지를 새 Canon으로 처음부터 끝까지 플레이할 수 있다.

## 6. 개발 Phase

### Phase 0 — 기준선 및 안전성 고정
목적: 구현 전에 현재 상태를 보호하고 작업 범위를 확정한다.

작업:
- HEAD / Branch / Working Tree 확인
- 기존 변경사항 보호
- 관련 코드 경로 READ-ONLY 확인
- 대상 Scene / Data / Asset 확인
- 해당 Phase의 성공 조건 고정

완료 조건:
- 변경 대상과 보존 대상이 명확하다.

판정: PASS 후 STOP.

### Phase 1 — Pilot HUD
목적: 플레이어 직접조종 중심의 전투 인터페이스를 확립한다.

작업:
- 기존 HUD 구조 조사
- Robot 상태 표시 우선순위 재배치
- 타깃 정보 정리
- 공격/특수/필살기 액션 상태 정리
- Tower 관련 주 조작 UI 축소/분리

검증:
- CODE
- EDITOR
- 가능하면 최소 실행 확인
- PIE는 Master 확인 전까지 UNVERIFIED

완료 조건:
- HUD가 Pilot 중심으로 동작한다.

### Phase 2 — 보스전
목적: 같은 직접조작 체계로 일반전과 보스전을 모두 성립시킨다.

작업:
- 기존 Giant 구현 READ-ONLY 분석
- 보스 상태/공격 패턴 추가
- 빈틈 또는 대응 창 구현
- 타깃/HUD 연계
- 승패 조건과 기존 Stage 구조 연결

검증:
- CODE
- 관련 Stage/Enemy Data
- 가능하면 Build
- PIE는 Master 확인 전까지 UNVERIFIED

완료 조건:
- 보스전 전용 행동이 실제 전투 시스템에 연결된다.

### Phase 3 — Tower 지원 시설 전환
목적: Tower Defense 운영이 아닌 Robot 지원 구조로 역할을 정리한다.

작업:
- 기존 Tower 자동 공격 코드 보존
- 직접 운영에 필요한 입력 경로 조사
- Canon과 충돌하는 주 조작 제거/축소
- 지원 역할 최소 1~2종 구성
- Stage에서 실제 사용 가능한 데이터 구조 확인

주의:
- Tower 전체 삭제 금지
- 배치/업그레이드 정책을 임의로 확정하지 않음

완료 조건:
- Robot 직접조종을 방해하지 않고 Tower가 자동 지원한다.

### Phase 4 — 공격/피격 연출 보강
목적: 전투의 시각적 인과성을 확보한다.

작업:
- 기본 공격 1종을 대상으로 투사체와 피해 시점 연결
- 피격 반응과 피해 표시 동기화
- 결과가 유효하면 필요한 공격 유형으로 최소 확장

완료 조건:
- 기본 공격에서 발사와 피해가 시각적으로 납득 가능하다.

### Phase 5 — Campaign 1 통합
목적: 개별 시스템을 하나의 실제 게임 루프로 통합한다.

작업:
- Campaign 1 Stage 선정
- 기존 Map/Stage/Enemy/Robot 데이터 재사용
- Phase 1~4 결과 통합
- 전투 시작
- 일반전
- XP/레벨업
- 보스전
- 승리/패배
- 결과 및 Campaign 진행 연결

완료 조건:
- Campaign 1 최소 1개 스테이지가 처음부터 끝까지 Canon 구조로 연결된다.

## 7. Phase 의존관계

기준 순서:
`Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5`

이 순서는 기술적 의존성을 줄이기 위한 제안이다. Master가 별도 순서를 지정하면 Master의 결정이 우선한다.

특히 Phase 5 이전에 대규모 신규 콘텐츠를 만들지 않는다.

## 8. 이번 개발에서 하지 않는 것

다음은 현재 실제 구현 공백 목록에서 제외된 항목이며 이번 계획에서도 자동 개발하지 않는다.

- Stage Briefing 독립 시스템
- 별도 Robot / Loadout 화면
- 완성형 Shop
- 복잡한 경제 시스템
- 복잡한 장비 희귀도/분해/판매 시스템
- 멀티플레이
- 온라인 협동
- 여러 Robot 동시 직접조종
- 대규모 신규 맵 제작
- 대규모 신규 Enemy/Robot 제작
- Replay 시스템
- main.gd 전면 재작성
- 최종 밸런스 수치 확정
- 최종 아트 제작 전체

이 항목들은 필요성이 새로 확인되고 Master가 범위를 확정한 경우 별도 계획으로 분리한다.

## 9. 개발 완료 정의

현재 단계의 목표는 '모든 콘텐츠가 완성된 상용 출시판'이 아니다.

1차 개발 완료는 다음 조건으로 정의한다.

1. 플레이어 Robot 직접조종이 유지된다.
2. 기본 공격/타깃/특수/필살기가 직접조작 체계로 동작한다.
3. Pilot 중심 HUD가 전투 정보를 전달한다.
4. AI 아군이 플레이어 조작을 방해하지 않고 지원한다.
5. Tower가 고정형 자동 지원 시설 역할을 수행한다.
6. 일반전과 보스전이 동일한 기본 조작으로 성립한다.
7. XP/즉시 레벨업이 전투 흐름에 연결된다.
8. Campaign 1 최소 1개 Stage가 전체 루프로 연결된다.

## 10. 검증 기준

### CODE VERIFIED
실제 코드 경로가 요구사항을 충족하는지 확인.

### EDITOR VERIFIED
실제 Asset / Scene / Data / Editor에서 필요한 설정이 가능함을 확인.

### BUILD VERIFIED
실제 Build 성공 확인.

### PIE VERIFIED
Master가 실제 Runtime 결과를 직접 확인.

자동화 테스트나 headless 로드 성공만으로 PIE VERIFIED를 선언하지 않는다.

## 11. 작업 보고 형식

각 주요 Phase 종료 시:

**STATUS** — PASS / HOLD / FAIL / UNVERIFIED

**목적** — 해당 Phase에서 해결하려던 문제

**기준선** — HEAD / Branch / Working Tree / 관련 Asset

**조사 결과** — CONFIRMED 중심

**기술 판단** — 근거 포함

**변경 사항** — 실제 변경만

**검증 상태** — CODE / BUILD / EDITOR / PIE

**미확인 사항** — UNVERIFIED

**OUT OF SCOPE** — 수행하지 않은 작업

**판정** — CONTINUE / CHANGE METHOD / ACCEPT·STOP

## 12. 변경 안전성

모든 구현 Phase 시작 전에:
- HEAD 확인
- Branch 확인
- Working Tree 확인
- 기존 변경사항 확인

변경 후:
- Diff 확인
- 의도하지 않은 변경 발견 시 즉시 중단
- 삭제/덮어쓰기/대규모 Asset 변환은 사전 승인 없이는 수행하지 않음
- 기존 변경사항을 임의로 수정/되돌리지 않음
- Commit/Push는 Master의 명시적 요청 없이는 수행하지 않음

## 13. Master 승인 경계

다음은 구현 중 새 설계 판단이 필요하므로 자동 결정하지 않는다.

- Tower 배치 방식
- Tower 업그레이드 정책
- 보스 공격 패턴의 최종 설계
- Robot 무기 종류와 수치
- 레벨업 선택 구조
- 최종 HUD 디자인
- Campaign 1의 구체적인 보스 구성

이런 문제가 발생하면 HOLD 후 Master에게 필요한 결정만 요청한다.

## 14. 최종 판정

현재 개발계획은 과거의 '처음부터 전체 게임을 만드는 로드맵'을 폐기하고, 실제 구현 상태를 기준으로 **5개의 구현 공백을 닫는 단계적 계획**으로 재정립한다.

핵심 순서는:

**Pilot HUD → Boss → Support Tower → 전투 연출 → Campaign 1 통합**

이미 구현된 이동/공격/타깃/특수/필살기/XP/AI 아군/Stage 구조를 다시 개발하지 않는다.

상태: PLAN COMPLETE / IMPLEMENTATION NOT STARTED

본 문서 작성 자체는 계획 수립 작업이며 게임 코드, Scene, Asset, Data는 변경하지 않았다.

## Handoff — 2026-10-05 자동공격 토글 / 수동 입력 검증 갱신

**STATUS — PASS / 부분 검증 완료**

**목적**
자동공격을 수동 모드로 전환하고, 수동 입력 동작이 실제 Runtime 전투 흐름에서 사용할 수 있는지 최소 검증한다.

**기준선**
- 프로젝트: `D:\Atlas\projects\menos\godot`
- Godot: `D:\Godot_v4.7.2`
- PAD Flow: `gpt`
- 관련 입력 Action: `move_up`
- 이번 검증에서는 Godot 프로젝트 코드/Asset/Scene/Data를 변경하지 않음.
- PAD Flow는 테스트를 위해 키 입력 표현을 수정하고 저장함.

**CONFIRMED**
- Runtime에서 `ATTACK: AUTO`를 `ATTACK: MANUAL`로 전환했다.
- Godot Input Map에서 W/Up이 `move_up`으로 등록되어 있다.
- `update_robot_manual_input()`이 수동 이동 입력을 실제 Robot 위치 변경에 연결한다.
- PAD `gpt` Flow의 Send Keys 입력을 `wwwwwwwwww`에서 `{W:10}`으로 변경했다.
- Master의 실제 Runtime 테스트에서 자동공격 토글 및 수동 입력동작이 성공했다.

**검증 상태**
- CODE VERIFIED: PASS
- EDITOR VERIFIED: PASS — PAD Flow 저장 확인
- BUILD VERIFIED: NOT VERIFIED
- PIE VERIFIED: PASS — Master 실제 Runtime 확인

**마리의 판정**
수동 입력 검증의 해당 목적은 달성했다. 이 결과는 Phase 1의 전체 완료가 아니라, Phase 1 내 수동 조작 검증 항목의 완료로 기록한다.

**변경 사항**
- 개발계획 문서에 본 검증 결과를 추가.
- Godot 코드/Asset/Scene/Data 변경 없음.
- PAD Flow `gpt` 변경은 테스트 범위에서 실제 반영됨.

**미확인 사항**
- Phase 1의 전체 Canon 전투 루프(공격/타깃/특수/스킬/필살기/AI 아군/지원 시설/보스/승패/재시작)는 별도 PIE 검증 필요.

**OUT OF SCOPE**
- 추가 공격 입력 자동화
- 보스/스킬/필살기 추가 검증
- Phase 2 이후 작업

**판정**
ACCEPT·STOP. 본 검증 항목은 종료하며 다음 Phase로 자동 진행하지 않는다.

## 2026-10-06 CURRENT IMPLEMENTATION AUDIT — AUTHORITATIVE CURRENT STATE

This section supersedes older HEAD/Working Tree snapshots in this document. It does not change Canon.

- Project: MENOS
- Branch: `main`
- HEAD: `7c97acc97be9262b50fe84b691de9b0dbdbd94e5`
- Working Tree at audit start: CLEAN.
- Godot: `D:\Godot_v4.7.2-stable`, version `4.7.2.stable.official`.
- Directly confirmed implementation: manual robot movement, basic attack, special attack, skill slots, finisher, target switching, XP/level progression, AlliedUnitAI, Giant boss attack patterns, Tower auto support, Campaign/Stage/Map loading paths.
- GAP-01 HUD: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-02 Giant boss behavior: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-03 fixed Tower support: CODE VERIFIED / minimum implementation present; PIE not verified in this audit.
- GAP-04 attack-to-hit-to-damage timing: CODE VERIFIED; PIE UNVERIFIED.
- GAP-05 Campaign 1 minimum integration: CODE VERIFIED / minimum integration present; full start-to-finish PIE UNVERIFIED.
- BUILD VERIFIED: UNVERIFIED in this audit.
- EDITOR VERIFIED: UNVERIFIED as a full manual Editor acceptance pass.
- PIE VERIFIED: NOT VERIFIED. Master runtime acceptance remains required.

The Godot process used during this audit regenerated tracked `.import` metadata. Those generated changes were reverted after verification because the working tree was CLEAN before the audit. No code, scene, asset, or Canon change was retained by this audit.

Conclusion: implementation documents are now aligned to the current repository baseline. The remaining verification boundary is Runtime/PIE, not a newly identified core-code gap.
## 2026-10-06 PIE TOOLING / ENVIRONMENT BASELINE

This section records the verified local tooling required for Godot PIE testing. It does not change Canon or gameplay scope.

- Godot: `D:\Godot_v4.7.2-stable`, `4.7.2.stable.official.ed1daf0bf` — REQUIRED / VERIFIED.
- VS Code: `1.140.0` — development/log inspection / VERIFIED.
- Git: `2.54.0` — baseline and diff inspection / VERIFIED.
- Git LFS: `3.7.1` — repository asset support / VERIFIED.
- PowerShell: Windows PowerShell `5.1.19041.6456` — execution/automation / VERIFIED.
- Python: `3.14.5` — optional tooling / VERIFIED.
- Node.js: `22.23.3`, npm `10.9.9` — optional tooling / VERIFIED.
- ripgrep: `15.2.0` — code/log search / VERIFIED.
- fd: `10.5.0` — file discovery / VERIFIED.
- jq: `1.8.2` — JSON inspection / VERIFIED.
- GitHub CLI: `2.102.0` — repository operations / VERIFIED.
- 7-Zip: `19.00 (x64)` — archive utility installed; `7z` is not on PATH.

PIE does not require CMake, Ninja, Make, MSBuild, or PowerShell 7 for the current GDScript-only MENOS project. No additional program is currently required for PIE execution.

Verification boundary:
- CODE VERIFIED: existing implementation audit remains valid.
- BUILD VERIFIED: NOT VERIFIED.
- EDITOR VERIFIED: NOT VERIFIED as a full manual acceptance pass.
- PIE VERIFIED: NOT VERIFIED. Master runtime acceptance remains required.

No code, scene, asset, or Canon changes were made by this tooling audit. Do not revert pre-existing Working Tree changes.
