# MENOS 통합 구현 계획서

상태: PROPOSAL / Master 승인 전 실행 기준 아님
작성일: 2026-10-01
목적: 기존 MENOS 문서를 Canon 및 최신 확인 가능한 구현 상태에 맞춰 통합하고, 실제 구현·검증·결정이 필요한 작업을 분리한다.

## 1. 문서 권한과 기준

우선순위:
1. `MENOS_COMBAT_CANON.md` — Master 승인 Canon
2. Master의 최신 직접 지시
3. 본 문서 — 통합 구현 계획 제안
4. `MENOS_REQUIRED_IMPLEMENTATION_GAPS.md` — 구현 공백 기록
5. `MENOS_IMPLEMENTATION_STATUS.md`, `MENOS_CURRENT_STATE.md` 및 개발/설계/마이그레이션 문서
6. 실제 코드·Scene·Data·Asset — 구현 사실 확인 근거

본 문서는 Canon을 변경하지 않는다. 기존 계획 문서의 상태가 서로 다르면 날짜와 실제 코드 확인 범위를 함께 고려하며, 문서의 오래된 상태를 현재 사실로 단정하지 않는다.

## 2. 검토 결과 요약

### CONFIRMED
- 승인된 전투 정체성은 파일럿이 슈퍼로봇 1기를 직접 조종하는 싱글플레이 전투다.
- Canon은 이동, 공격, 타깃/전환, 특수공격, 필살기, 다수전/보스전, 파일럿 중심 HUD를 요구한다.
- AI 아군은 자동 전투하며 플레이어가 개별 지휘하지 않는다.
- 기존 Tower는 폐기 대상이 아니라 고정형 지원 시설로 재정의된다.
- 프로젝트에는 Godot 구현, Browser fallback, Map/Stage/Enemy/Tower/Robot/Image 에디터와 콘텐츠 데이터가 존재한다.
- 2026-09-30 GAP 문서는 Canon 최소 구현의 상당 항목을 CODE 기준으로 완료 처리하고, PIE는 미검증으로 구분한다.

### 문서 충돌 및 신뢰 경계
- 오래된 `MENOS_DEVELOPMENT_PLAN.md`는 HUD·보스·Tower·Campaign 통합을 구현 예정으로 기록하지만, 2026-09-30 GAP 문서는 이들을 최소 구현 완료로 기록한다. 최신 문서와 실제 코드 확인을 우선하고, 구 계획은 이력으로 취급한다.
- `MENOS_CONTENT_DEVELOPMENT_PLAN.md`는 A-1을 다음 작업으로 제시하지만, 이후 문서/코드 상태가 달라졌을 수 있다. 실행 전 재확인이 필요하다.
- `MENOS_GAME_SYSTEMS.md`는 PROPOSED이며 성장, 장비, 경제, 수리, 저장 정책을 Canon으로 확정하지 않는다.
- 현재 작업 기준선은 Branch `main`, HEAD `98bee270662300758c6fe14cd5163386d48b9f4b`이다. 확인 당시 기존 변경 `editor/content_editor.gd`가 존재했다. 본 문서 작성 시점의 최종 Working Tree 재확인은 별도 필요하다.
- 문서에 기록된 CODE/Headless 성공은 EDITOR·BUILD·PIE 성공을 의미하지 않는다.

## 3. 현재 상태의 작업 분류

### A. Canon 구현
GAP 문서상 최소 기능은 CODE 경로에서 구현 완료로 기록되어 있다: 직접 조작, 기본/특수 공격, 타깃, 스킬/필살기, XP/즉시 레벨업, AI 아군, Pilot HUD, 자동 지원 시설, Giant 전용 패턴, Campaign 1 최소 통합.

판정: 기능을 처음부터 다시 만들지 않는다. 다음 핵심은 최신 코드 기준 재확인과 Master의 실제 플레이 검증이다. GAP 문서가 표시한 공격-피격 동기화도 구현 완료 기록과 실제 타격감/PIE 미검증을 분리한다.

### B. 콘텐츠 제작 도구
현재 에디터: Map, Stage, Enemy, Tower, Robot, Image. Content Editor는 이들을 호스팅한다.
미확인: 모든 편집 필드가 저장되고, 검증되며, 런타임에 동일하게 반영되는지; 에디터의 실제 시각적 가독성/사용성; 데이터 오류 복구와 사용자 피드백.

### C. 미확정 시스템
성장 곡선/상한, 장비 슬롯·호환성, 인벤토리, 수리 시점/비용, 업그레이드 규칙, 통화/보상, 저장 포맷/버전/복구, 맵 간 손상 유지, 추가 미션 유형은 결정 전까지 구현 대상으로 간주하지 않는다.

### D. 검증만 필요한 항목
Campaign 1 전체 플레이, 보스 패턴, HUD 가독성, 공격 도착-피격 인과성, 콘텐츠 에디터 편집→저장→로드→런타임 반영. 이들은 검증 과제이며, 실패 원인을 확인하기 전 기능을 재작성하지 않는다.

## 4. 구현 목표

현재 Canon에 명시된 싱글플레이 전투를 기존 Godot 프로젝트와 콘텐츠 파이프라인으로 안정적으로 제작·실행·검증할 수 있게 한다. 미확정 성장/경제/장비 시스템을 임의로 추가하거나 출시 범위를 확장하는 것은 목표에 포함하지 않는다.

## 5. 권장 실행 로드맵

순서는 기술적 제안이다. 각 항목은 별도 Master 지시 후 실행하며, 한 단계 성공 시 STOP한다.

### Phase 0 — 기준선 및 문서 정합성
목적: 실행 기준을 고정하고 오래된 계획의 재작업을 방지한다.
- 시작 시 HEAD/Branch/Working Tree 및 기존 변경 확인.
- Canon, GAP, 구현 상태, 관련 코드·데이터를 대조.
- 상충하는 문서에는 상태/날짜/검증 경계를 명시하고 원본 기록은 보존.
완료: 실행 대상과 보존 범위가 명확하고, 문서상 구현 상태를 코드 근거 없이 승격하지 않음.

### Phase 1 — Canon 전투의 최소 PIE 검증
목적: CODE로 기록된 최소 전투 루프가 실제 게임에서 연결되는지 확인.
- Master가 실행 가능한 환경에서 Stage 1을 시작부터 종료까지 검증.
- 직접 이동/공격/타깃/전환/특수/스킬/필살기, AI 아군, 지원 시설, 보스, 승패 및 재시작을 관찰.
- 실패는 증상→가능 원인→확인 방법→결과 순으로 좁히고, 재현되는 결함만 수정 대상으로 제안.
완료: 확인 항목별 PIE 결과와 미확인 항목이 분리 기록됨. 자동화 테스트는 PIE 대체 불가.

### Phase 2 — 콘텐츠 파이프라인 검증
목적: 에디터 데이터가 런타임에 반영되는 실제 경로를 검증.
- Robot, Enemy, Tower 중 기존 데이터와 필드가 명확한 단일 대상부터 선택.
- 값 하나를 바꾸어 저장→재로드→런타임 로드까지 추적.
- 누락/잘못된 경로·필드·범위에 대한 Validator 동작을 확인.
- Map/Stage는 별도 데이터 책임(Map 공간, Stage 규칙/구성)을 보존.
완료: 선택 대상의 편집값-저장값-런타임값이 일치하고 실패가 사용자에게 식별 가능.
HOLD: 편집 필드의 의미 또는 런타임 계약이 불명확하면 임의로 필드/규칙을 추가하지 않음.

### Phase 3 — 콘텐츠 에디터 사용성
목적: 콘텐츠 제작자가 에디터를 읽고 조작할 수 있게 한다.
- 실제 화면을 기준으로 글자 크기, 대비, 계층, 여백, 긴 목록/창 크기 대응을 평가.
- 색상 테마 적용만으로 완료 판정하지 않음.
- 공통 테마와 각 하위 에디터의 로컬 폰트/스타일 override를 분리 조사.
- 기능/데이터 계약을 바꾸지 않는 시각 변경만 최소 적용.
완료: Master의 화면 확인으로 가독성과 주요 작업 흐름이 확인됨.
현재 글자 크기 12 조정은 임시 조정이며 시각적 최종 검증은 UNVERIFIED.

### Phase 4 — 전투 표현 품질
목적: 기존 공격 로직을 바꾸지 않고 화면상 인과성과 가독성을 검증.
- 발사→이동→도착→피격→피해 표시의 시간 관계 확인.
- Robot/Tower/Enemy 경로 중 재현되는 한 경로부터 조사.
- 실제 문제가 확인될 때만 최소 수정. 밸런스/공격 규칙은 범위 밖.
완료: 대표 상황에서 시각적 인과성이 Master에 의해 확인되거나 구체적 잔여 이슈가 기록됨.

### Phase 5 — 미확정 메타 시스템 결정 게이트
성장, 장비, 수리, 경제, 저장/복구, 맵 간 상태 유지, 추가 미션은 구현 전 별도 기획·Canon 승인 필요.
각 시스템은 사용자 가치, 데이터 소유권, 상태 전이, 실패/복구, UI, 저장 호환성, 검증 시나리오를 정의한 뒤 구현 여부를 결정한다.
기본 판정: 승인 전 HOLD / 구현하지 않음.

## 6. 우선순위와 중단 조건

P0 — Canon 최소 전투 루프의 Master PIE 확인 및 실제 차단 결함 처리.
P1 — 콘텐츠 편집→저장→런타임 반영의 데이터 계약 검증.
P1 — 콘텐츠 에디터 가독성/사용성 검증과 필요한 최소 수정.
P2 — 공격-피격 연출의 실제 인과성 확인 및 필요한 보강.
P3 — 미확정 성장/장비/경제/저장 시스템은 별도 승인 이후에만 계획 수립.

다음 상황은 HOLD:
- Canon/데이터 계약과 충돌
- 기존 변경사항 또는 Asset 손상 위험
- Master 결정이 필요한 규칙 발견
- 실제 화면/PIE 결과가 예상과 다름
- 범위 확장 또는 외부 Asset 필요
- 확인 가능한 근거 부족

## 7. 공통 완료 기준

각 작업은 다음을 기록한다.
1. 목적과 범위
2. 기준선: HEAD / Branch / Working Tree / 관련 Asset
3. CONFIRMED 사실과 UNVERIFIED 항목
4. 변경 전후 Diff 및 기존 변경 보존 여부
5. CODE / BUILD / EDITOR / PIE 검증 상태
6. 성공 조건 충족 여부와 ACCEPT·STOP / CONTINUE / HOLD 판정
7. OUT OF SCOPE 및 추가 결정 사항

Headless/자동화 PASS를 PIE VERIFIED로 표시하지 않는다. 코드 경로 확인을 실제 플레이 품질의 증거로 확대하지 않는다.

## 8. 범위에서 제외

- 멀티플레이/온라인 협동
- Canon에 없는 RTS식 아군 지휘
- Tower Defense 운영을 전투 중심으로 복원
- Master 승인 없는 신규 로봇/적/타워/대규모 맵/스토리
- Master 승인 없는 외부 Asset
- 성장·경제·장비의 수치 및 규칙 임의 확정
- 대규모 main.gd 리팩터링
- Commit / Push

## 9. 문서 유지 방침

본 문서는 기존 문서를 대체하지 않는다. 충돌하는 오래된 계획은 삭제하지 않고, 이력/상태 차이를 본 문서에서 설명한다. 후속 구현 완료 시 실제 변경 파일과 검증 결과를 각 관련 상태 문서에 반영하고, 계획의 해당 항목만 갱신한다. Canon 변경은 Master 승인으로만 수행한다.

## 10. 최종 판정

STATUS — DOCUMENTATION PASS / IMPLEMENTATION NOT STARTED
목적 — 문서 간 기준을 통합하고 구현/검증/결정 항목을 분리.
변경 — 신규 문서 `MENOS_MASTER_IMPLEMENTATION_ROADMAP.md` 작성. 기존 Canon/코드/Asset/데이터는 변경하지 않음.
현실성 — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE. BUSINESS VIABLE은 시장·비용 자료 부족으로 UNVERIFIED.
다음 단계 — Master가 Phase 또는 개별 작업을 지정할 때만 착수한다.
## 11. 실제 코드 대조 결과 (2026-10-01)

조사 범위: 현재 작업 트리의 일부 핵심 스크립트와 콘텐츠 에디터. 전체 코드베이스 전수 감사나 런타임 테스트는 아니다.

### CONFIRMED — 직접 읽은 코드
- `scripts/stage_manager.gd`: 캠페인/선택 스테이지 ID, 캠페인 JSON 로드, 스테이지 카탈로그, 다음 캠페인 스테이지 조회, StageLoader 호출 및 현재 스테이지 데이터 보유 경로가 있다.
- `scripts/stage_loader.gd`: JSON 파싱과 필수 키, map_file 존재, balance 수치, allied_units, encounters/waves/groups 구조 검증이 구현되어 있다.
- `scripts/robot_progression_state.gd`: level/xp/unlocked_abilities의 메모리 상태, Dictionary 역직렬화/직렬화, ability 조회/해금이 있다.
- `scripts/campaign_progression_state.gd`: unlocked/completed stage ID의 메모리 상태, 직렬화/역직렬화, 초기 스테이지 보장, 완료 및 다음 스테이지 해금이 있다.
- `editor/content_editor.gd`: Map/Stage/Enemy/Tower/Robot/Image 씬을 연결하고, 사이드바 버튼으로 에디터를 교체하며, 시작 시 Map Editor를 연다.
- Content Editor는 전역 Theme를 적용한다. 현재 코드의 `default_font_size`는 12이며, 버튼·입력·탭·패널 스타일을 설정한다.

### INFERENCE — 코드에서 도출되나 추가 확인 필요
- StageLoader는 Stage JSON 구조를 검증하지만, 이 코드만으로 Enemy/Robot/Tower 모든 참조 ID가 유효한지 또는 런타임 전체 계약이 검증되는지는 확인되지 않는다.
- progression state 클래스는 직렬화 API를 제공하지만, 이 파일만으로 실제 디스크 저장·로드 호출 및 세이브 호환성/복구를 확정할 수 없다.
- StageManager의 next-stage 조회는 다음 ID를 반환하지만, 해금 조건/결과 화면/진행 저장까지의 완전한 사용자 흐름은 이 조사 범위에서 확인하지 않았다.
- Content Editor가 하위 씬을 로드하는 것은 확인했으나, 모든 하위 에디터의 저장 동작·데이터 무결성·화면 사용성은 미검증이다.

### UNVERIFIED
- 현재 코드에서 직접 조종, 특수기/필살기, AI 아군, 보스 패턴, 타워 자동 공격의 모든 세부 경로.
- GAP-04 공격 투사체 도착과 피해 적용의 동기화 완료 여부.
- 모든 편집 데이터가 저장 후 재로드되어 실제 전투에 반영되는지.
- BUILD, 실제 Editor 조작, 전체 Stage 1 PIE, 최종 UI 가독성.

## 12. 실제 대조 후 갱신 판정

앞선 §10의 "IMPLEMENTATION NOT STARTED"는 문서 작성 시점의 상태 표기다. 본 대조 작업에서 실제 코드 일부를 READ-ONLY로 확인했으며, 문서 기준을 다음과 같이 보정한다.

- 구현 착수 여부: 기존 프로젝트에는 다수 구현이 존재. 본 문서 작업은 구현 변경이 아닌 일부 코드 대조.
- 검증 완료 여부: 전체 구현 감사가 아니며 BUILD/EDITOR/PIE 검증을 수행하지 않음.
- GAP-04: GAP 문서 내부에 PARTIAL과 IMPLEMENTED가 공존하는 모순을 확인. 해당 경로를 이번 조사에서 직접 확인하지 않았으므로 UNVERIFIED로 재분류하고 재검증 대상으로 명시.
- 콘텐츠 파이프라인: Stage JSON의 로드/구조 검증은 코드 확인. 모든 에디터 저장→런타임 반영은 아직 확인되지 않음.
- 성장/캠페인 상태 클래스: 직렬화 API는 확인했으나 디스크 영속성은 별도 추적 필요.

STATUS — PARTIAL PASS / READ-ONLY CODE COMPARISON
범위 — 핵심 스크립트 일부 및 Content Editor 호스트 경로.
변경 — 계획서 갱신, GAP 문서의 GAP-04 상충 상태 수정. 코드/Asset/데이터/Canon 변경 없음.
검증 — 문서 재열람과 Git diff-check 결과 확인 필요. BUILD/EDITOR/PIE는 수행하지 않음.


## 2026-10-06 DOCUMENT UPDATE — CURRENT REPOSITORY BASELINE

이 섹션은 이전 문서의 HEAD/Working Tree 스냅샷보다 우선하는 현재 문서 기준선이다. Canon을 변경하지 않는다.

- Project: MENOS
- Branch: `main`
- HEAD: `178cac776cfa21d3446e5a199ad7db5025f64589`
- Working Tree: 기존 변경사항 다수 존재. 이번 문서 갱신은 기존 변경을 수정/되돌리지 않는다.
- Godot: `D:\\Godot_v4.7.2-stable`, `4.7.2.stable.official.ed1daf0bf`
- Core implementation assessment: 직접 조종, 기본 공격, 타깃 전환, 특수공격, 스킬 슬롯, 필살기, XP/레벨, AlliedUnitAI, Giant 보스 패턴, 고정형 Tower 지원, Campaign/Stage/Map 경로가 코드상 확인됨.
- BUILD VERIFIED: UNVERIFIED
- EDITOR VERIFIED: 전체 수동 Acceptance 기준 UNVERIFIED
- PIE VERIFIED: UNVERIFIED
- 따라서 현재 핵심 공백은 신규 핵심 전투 코드의 존재 여부보다 Runtime/PIE 검증 경계에 있다.

### JSON → SQLite 콘텐츠 파이프라인 기준선

- JSON은 당분간 Authoritative Source로 유지한다.
- SQLite 전환은 콘텐츠 타입별로 하나씩 수행한다.
- 첫 대상은 Robot이다.
- 현재 Robot JSON과 SQLite의 의미상 데이터 비교 결과는 동일하다. `asura`, `valkyrie` 두 항목이 일치한다.
- `ContentCatalogLoader`는 Robot JSON 경로 요청을 SQLite `robots` 테이블에서 읽도록 연결되어 있다.
- `ObjectPersistence.sync_catalog_to_sqlite()`는 Robot에 한정된 동기화 경로를 추가했으나 Editor Save에 자동 연결하지 않는다.
- Editor Save → 자동 SQLite 갱신은 Canon상 아직 적용하지 않는다.
- Robot Sync 실제 실행 및 Runtime/PIE 검증은 별도 검증 항목이며, 확인 전에는 VERIFIED로 표시하지 않는다.
- 다른 콘텐츠 타입의 SQLite 전환은 수행하지 않는다.

### 문서 정합성 판정

- 오래된 HEAD/Working Tree 기록은 역사적 기록으로 보존한다.
- 현재 상태 판단에는 본 섹션의 2026-10-06 기준선을 사용한다.
- Canon 변경 없음.
- 코드/Asset/Scene/Data 변경 없음.
- Commit/Push 없음.
