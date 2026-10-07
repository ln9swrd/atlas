# MENOS 개발계획 — Canon 기준 재정립판

> 작성일: 2026-10-06
> 상태: MASTER APPROVED / CURRENT EXECUTION PLAN
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
- HEAD / Working Tree: 현재 상태 문서 및 작업 시작 시점의 실제 기준선을 사용한다.
- 기존 Working Tree 변경사항은 보존하며 임의로 수정/되돌리지 않는다.
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

## 5. 현재 검증 공백

현재 핵심 시스템은 코드상 최소 구현이 확인되어 있으며, 이 5개 항목은 신규 개발 목록이 아니라 **Runtime 수락 및 결함 판정 기준**으로 관리한다.

### GAP-01 — Giant Boss 행동
- 현재 상태: CODE VERIFIED / 최소 구현 확인
- PIE: UNVERIFIED
- 수락 기준: 기존 직접조작으로 보스전이 성립하고, 보스의 공격 패턴과 대응 가능한 빈틈이 실제 Runtime에서 확인된다.

### GAP-02 — Pilot 중심 전투 HUD
- 현재 상태: CODE VERIFIED / 최소 구현 확인
- PIE: UNVERIFIED
- 수락 기준: Robot HP/자원/XP/레벨, 타깃, 사용 가능한 전투 행동을 실제 전투 화면에서 확인할 수 있다.

### GAP-03 — Tower의 고정형 지원 시설
- 현재 상태: CODE VERIFIED / 최소 구현 확인
- PIE: UNVERIFIED
- 수락 기준: Tower가 Robot 직접조작을 방해하지 않고 자동 지원 시설로 기능한다.
- Master 결정 없이 배치/업그레이드 정책을 새로 확정하지 않는다.

### GAP-04 — 공격→피격→피해 연출 동기화
- 현재 상태: CODE VERIFIED / Runtime 미검증
- PIE: UNVERIFIED
- 수락 기준: 발사 → 도착 → 피격 → 피해의 순서와 시점이 실제 Runtime에서 납득 가능하게 연결된다.

### GAP-05 — Campaign 1 Canon 통합
- 현재 상태: CODE VERIFIED / 최소 통합 확인
- PIE: UNVERIFIED
- 수락 기준: Campaign 1 최소 1개 Stage를 시작 → 전투 → 성장 → 승리/패배 → 진행까지 실제 Runtime에서 확인한다.

이 항목들은 구현 공백 문서와 동일한 번호를 사용한다. 상태가 변경되면 `MENOS_REQUIRED_IMPLEMENTATION_GAPS.md`와 `state/CURRENT_STATE.md`를 함께 갱신한다.

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

### Phase 1 — Core Runtime Acceptance
목적: 현재 구현된 Canon-aligned core loop를 실제 Runtime에서 최소 범위로 수락 검증한다.

대상:
- 직접 이동
- 기본 공격 / 특수공격 / 스킬 / 필살기
- 타깃 및 타깃 전환
- Pilot HUD
- AI 아군
- 고정형 Tower 지원
- Giant Boss

완료 조건:
- Master가 실제 Runtime에서 핵심 전투 루프를 확인한다.
- 확인 결과를 관찰 사실만으로 기록한다.
- PIE VERIFIED는 Master의 직접 Runtime 확인 후에만 선언한다.

### Phase 2 — Combat Timing Acceptance
목적: GAP-04의 공격→피격→피해 연결을 실제 Runtime에서 검증한다.

대상:
- 기본 공격 1종
- 투사체 도착
- 피해 판정
- 피격 반응
- 피해 표시

완료 조건:
- 발사 → 도착 → 피격 → 피해의 순서가 Runtime에서 확인된다.

### Phase 3 — Campaign 1 Acceptance
목적: 현재 구현된 시스템을 Campaign 1 최소 1개 Stage의 실제 플레이 루프로 검증한다.

대상:
- 전투 시작
- 일반전
- XP / 레벨업
- AI 아군
- Tower 지원
- Boss
- 승리 / 패배
- Campaign 진행

완료 조건:
- 최소 1개 Stage를 처음부터 끝까지 실제 Runtime에서 확인한다.

### Phase 4 — Defect-driven Correction
목적: Phase 1~3의 Runtime 검증에서 실제로 발견된 결함만 최소 수정한다.

원칙:
- 관찰된 결함만 대상으로 한다.
- 원인 확인 후 최소 변경한다.
- 변경 후 Diff와 필요한 Runtime 검증을 수행한다.
- 새로운 기능이나 밸런스 설계를 자동 추가하지 않는다.

완료 조건:
- 발견된 결함이 수정되고 해당 검증이 재통과한다.

### Phase 5 — Acceptance Close
목적: 현재 개발계획의 1차 완료 여부를 판정한다.

판정 기준:
- GAP-01~05의 구현/검증 상태를 실제 결과로 갱신한다.
- 미검증 항목은 UNVERIFIED로 남긴다.
- 새로운 범위가 필요하면 별도 Master 결정 대상으로 분리한다.
- 목적 달성 시 ACCEPT·STOP한다.

## 7. Phase 의존관계

기준 순서:
`Phase 0 → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5`

이 순서는 현재 검증 경계를 기준으로 한 실행 제안이다. Master가 별도 순서를 지정하면 Master의 결정이 우선한다.

중요: Phase 1~3에서 실제 결함이 발견되지 않는 한 신규 구현을 자동 시작하지 않는다.

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

현재 개발계획은 신규 핵심 시스템을 순차적으로 만드는 로드맵이 아니라, 이미 코드상 확인된 구현을 Runtime에서 수락하고 실제 결함만 수정하는 실행계획으로 운용한다.

현재 실행 순서:

**Core Runtime Acceptance → Combat Timing Acceptance → Campaign 1 Acceptance → Defect-driven Correction → Acceptance Close**

이미 구현된 이동/공격/타깃/특수/필살기/XP/AI 아군/Tower/Boss/Campaign 경로를 검증 전에 다시 개발하지 않는다.

현재 주요 미검증 경계는 BUILD / 전체 EDITOR Acceptance / PIE이며, 실제 Runtime에서 결함이 확인될 경우에만 수정 작업을 생성한다.

상태: PLAN ACTIVE / RUNTIME ACCEPTANCE PENDING

본 계획 갱신에서는 게임 코드, Scene, Asset, Data, Canon을 변경하지 않는다.


## 2026-10-06 Data-Centric Editor Implementation Plan Update

Master-directed implementation scope:
- Implement: Faction Editor, Skill/Ability Editor, Mission/Objective Editor, Campaign Editor, Gameplay/Settings Editor, Settings Window, BGM data/management, SFX data/management, VFX data/management.
- Hold: Item Editor, Reward Editor, art/visual asset production or expansion.
- Implementation priority: Faction -> Skill/Ability -> Mission/Objective -> Campaign -> Gameplay/Settings -> Settings Window -> BGM -> SFX -> VFX.
- SQLite remains the authoritative Runtime/Editor content source.
- Audio/VFX work is data, reference, validation, and Runtime integration first; asset production is out of scope.
- Each editor is to reuse the existing Repository/Loader/ObjectPersistence/Validator patterns where applicable.

Implementation started with Faction Editor as the first task. Faction Editor currently provides SQLite-backed list/create/update/delete for faction id, name, and color data. Alliance relation modeling and Runtime consumption remain to be implemented after the existing data contract is confirmed.

Item/Reward editors and art/visual production remain HOLD.
