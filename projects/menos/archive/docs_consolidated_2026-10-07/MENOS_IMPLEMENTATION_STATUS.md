# MENOS 구현 상태 기준선

작성일: 2026-10-06
상태: CURRENT IMPLEMENTATION STATUS / SUPPORTING EVIDENCE
목적: Canon과 현재 구현의 차이, 코드 검증 상태, 남은 Runtime 수락 경계를 기록한다.

현재 실행계획은 `MENOS_DEVELOPMENT_PLAN.md`가 담당하며, 현재 전체 상태는 `state/CURRENT_STATE.md`가 담당한다.

## 1. 판정 원칙

- MASTER CANON은 `MENOS_COMBAT_CANON.md`를 우선한다.
- 기존 PoC 구현 사실은 Canon과 별도로 기록한다.
- PROPOSAL은 구현 완료로 취급하지 않는다.
- CODE VERIFIED와 Runtime/PIE VERIFIED를 구분한다.
- 이번 작업에서는 코드/Asset/Scene/Data를 변경하지 않는다.
- Git Commit / Push를 수행하지 않는다.

## 2. 핵심 기준 충돌

기존 설계 문서에는 플레이어가 지휘관으로서 Robot 위치를 지시하고
Robot이 자동 전투하는 구조가 기록되어 있다.

2026-09-29 Master 승인 Canon은 다음을 확정했다.

- 플레이어는 파일럿이다.
- 슈퍼로봇 1기를 직접 조종한다.
- 이동, 공격, 타깃, 타깃 전환, 특수공격, 필살기를 직접 사용한다.
- AI 아군은 자동 전투한다.
- 타워는 고정형 지원 시설이다.
- RTS식 다수 유닛 지휘와 Tower Defense 중심 운영은 핵심 조작이 아니다.

따라서 기존 Commander/Auto-Robot 구조는 현재 구현 사실이지
최종 Canon 구현으로 간주하지 않는다.
## 3. 구현하려고 하는 것 — 설계/Canon

### 핵심 전투
- 슈퍼로봇 직접 조종
- 직접 이동
- 기본 공격
- 타깃 선택
- 타깃 전환
- 특수공격
- 필살기
- 다수전
- 거대 보스전
- 파일럿 중심 전투 HUD
- 전투 중 즉시 경험치/레벨업

### 전장 구성
- 플레이어 로봇 1기
- AI 아군 유닛
- 고정형 지원 시설/타워
- 일반 적
- 거대 보스

### 게임 진행
- 싱글플레이 캠페인
- 스테이지/맵 기반 전투
- 승리/패배
- 전투 결과
- 반복 플레이
- 캠페인 엔딩 이후 자유 전투

### 콘텐츠 제작
- Map Editor
- Stage Editor
- Content Editor
- Enemy/Unit/Tower/Robot 콘텐츠 편집
- 데이터와 런타임 로직 분리
- Map Data와 Stage Data 분리

### 장기 설계 후보
- 로봇 성장
- 장비/인벤토리
- 수리/강화
- 경제/보상
- 저장/불러오기
- 캠페인 연출
- Replay/분석 도구

장기 항목 상당수는 아직 PROPOSAL이며 구현 완료를 의미하지 않는다.
## 4. 현재 구현된 것 — 문서상 확인

### 전투/PoC
- Godot 4.7.2 프로젝트와 Combat Scene 존재
- 4개 Wave 데이터
- Cannon / Gatling Tower
- Normal / Rusher / Heavy / Giant Enemy
- Robot 출격
- Robot 위치 선택/이동 및 자동 전투 경로
- Robot 기본 공격
- AREA / PIERCE 계열 특수 공격 데이터
- Giant의 Robot 직접 공격
- Robot 파괴 상태 및 재출격 시 HP 복구
- Tower 배치와 자동 공격
- Wave 진행
- Victory / Defeat / Restart
- 전투 HUD 및 최근 UI 개선 STEP 1~5 코드 반영

### 콘텐츠/개발 도구
- Content Editor Shell
- Map Editor
- Stage Editor MVP
- Enemy Editor
- Tower Editor
- Robot Editor
- Asset Catalog / Image 관련 도구
- Stage JSON Load/Save
- 콘텐츠 데이터 JSON 구조
- Content Validator 기반

### 맵/표현
- 28x18 기본 Godot 전장
- Ground / Road / Vegetation 구성
- Base / Tower / Spawn / Robot Start 배치
- ATLAS / Enemy / Tower 관련 이미지 Asset
- 기본 공격/피격/투사체 표현
- Victory / Defeat 상태 표현

### 검증 상태
- CODE VERIFIED: 다수 핵심 경로 확인됨.
- EDITOR VERIFIED: 일부 도구/프로젝트 로드 확인.
- BUILD VERIFIED: 전체 Production Build는 미확정.
- PIE VERIFIED: 일부 과거 비교 실험만 직접 확인되었으며 전체 프로젝트는 아님.
- 현재 문서 기준으로 상업용 게임 전체 완성은 UNVERIFIED.
## 5. 구현이 필요한 것 — Canon과 현재 구현의 차이

### P0 — Canon 전투 전환
- Robot 직접 이동 조작으로 전환
- 직접 기본 공격 조작
- 명확한 타깃 선택
- 타깃 전환
- 특수공격 직접 사용
- 필살기 시스템
- 직접 조작과 자동 전투 로직의 책임 재정의
- 기존 Commander/위치 지시 핵심 루프와 충돌하는 UI/입력 정리

### P0 — 전투 기반
- 다수전과 보스전이 동일한 조작 체계에서 안정적으로 동작
- Giant/보스의 공격 패턴과 대응 구조
- 플레이어 로봇의 회피/생존 플레이
- 아군 AI 유닛의 실제 전투 참여
- 고정형 지원 시설로서 Tower 역할 정리
- 전투 HUD를 Canon의 파일럿 중심 구조로 정렬

### P1 — 성장/진행
- 전투 중 XP 즉시 레벨업의 완전한 런타임 연결
- 레벨/성장 데이터의 최종 구조
- 능력/특수공격 해금과 실제 전투 변화 연결
- 스테이지 결과와 다음 진행 연결
- 맵 선택 및 자유 전투
- 저장/불러오기

### P1 — 콘텐츠 파이프라인
- Robot Editor 저장값의 실제 런타임 반영 검증
- Enemy Editor의 전투 데이터 완전 연결
- Tower Editor의 전투 데이터 완전 연결
- 공통 Content Validator 강화
- Map Editor의 추가/이동/삭제/저장 기능 완성
- Stage Data와 Runtime의 완전한 연결
- 서로 다른 크기의 맵을 실제 런타임에서 검증

### P2 — 캠페인/장기 시스템
- 캠페인 진행 구조
- 미션/스테이지 해금
- 결과/보상
- EXCELION 기반 캠페인 콘텐츠
- 로봇 프로필/영구 성장
- 장비/인벤토리/수리/강화
- 경제/상점

### P3 — 완성/출시
- 최종 Asset
- 애니메이션/VFX/SFX
- HUD 최종 디자인
- Minimap
- 승리/패배/웨이브 연출
- 성능/저장/입력 안정성
- Steam 출시 검증
- Replay/분석 도구

## 6. 현재 문서 간 상태 정리

- `MENOS_COMBAT_CANON.md`: MASTER APPROVED / CANON
- `MENOS_DESIGN_SPEC.md`: 상업용 설계 기준선이나 일부 기존 내용은 Canon과 충돌
- `MENOS_GAME_SYSTEMS.md`: PROPOSED
- `MENOS_DEVELOPMENT_PLAN.md`: PROPOSED
- `MENOS_CONTENT_DEVELOPMENT_PLAN.md`: PROPOSAL
- `MENOS_GAMEPLAY_UI_IMPROVEMENT_PLAN.md`: PROPOSAL, STEP 1~5는 코드 수준 완료 기록
- `state/CURRENT_STATE.md`: 현재 구현/검증 Handoff 기록
- 본 문서: 구현 상태 통합 기준선
## 7. 중요한 미확인 사항

- 현재 프로젝트 전체를 최종 Canon 전투로 평가한 PIE 검증은 없음.
- 직접 조종으로 전환했을 때 기존 전투 시스템이 어떤 범위까지 재사용 가능한지는 추가 READ-ONLY 조사가 필요함.
- AI 아군의 실제 런타임 구현 범위는 현재 문서만으로 완전 확정하지 않음.
- 필살기의 구체 규칙/수치/연출은 미확정.
- XP/레벨/성장 수치와 최종 기술 목록은 미확정.
- 캠페인 전체 콘텐츠 수량과 미션 구성은 미확정.
- 상업용 최종 밸런스와 반복 재미는 UNVERIFIED.

## 8. 이번 문서화의 판정

STATUS — PASS

목적 — MENOS의 문서 기준에서 구현 예정/현재 구현/추가 구현 필요를 구분해 기준선을 만든다.

기준선 — 프로젝트 문서 전체 검토. 코드/Asset/Scene 변경 없음.

마리의 판정 — 문서화 목적은 충족했다. 기존 PoC와 Master Canon의 차이를 분리해 기록했으므로 현재 상태를 혼동하지 않는 기준선으로 사용할 수 있다.

변경 사항 — `MENOS_IMPLEMENTATION_STATUS.md` 신규 작성.

검증 상태 — 문서 READ-ONLY 검토 완료. CODE/BUILD/EDITOR/PIE 검증을 새로 수행하지 않음.

OUT OF SCOPE — Canon 전환 구현, 코드 수정, Asset 수정, 밸런스 결정, 캠페인 추가, Commit/Push.

현실성 판단 — TECHNICALLY POSSIBLE / PRACTICALLY FEASIBLE. 다만 실제 구현 순서는 Canon 전투 전환 범위를 먼저 확정한 뒤 진행해야 한다.

다음 단계 — Master 지시 전 자동 진행하지 않는다.

## 2026-10-05 Gameplay Definition / Map 책임 갱신

STATUS: DOCUMENTATION BASELINE UPDATE

CONFIRMED:
- Master가 지정한 현재 Mission Type은 Tower Defense, Elimination, Giant Boss Battle 세 가지다.
- 세 가지는 Gameplay Mode가 아니라 Mission Type이다.
- Stage Editor는 현재 Map + Mission + Encounter/Wave + Stage 설정을 함께 편집하는 Gameplay Definition 중심 도구다.
- Map Editor와 Map JSON은 이미 Gameplay 환경 요소를 관리한다.
- Map Gameplay 요소에는 Spawn Area, Movement Area, Blocked Area, Obstacle Area, Tower Placement Area/Point, Goal Area, Robot Position Point가 확인된다.
- StageLoader는 Stage가 map_file로 Map을 참조하고 mission_id로 Mission을 참조하도록 검증한다.

DESIGN BOUNDARY:
- Map: 재사용 가능한 맵 구조와 맵 종속 Gameplay 공간/지점
- Stage: 선택한 Map에서 실행할 Mission과 Encounter/Wave 및 Stage별 설정
- Mission: 목표/승패 의미와 Mission Type
- Runtime: 정의된 Stage를 실행

UNVERIFIED:
- 1인/2인 등 Player Count의 최종 데이터 소유 위치
- 기존 campaign / single / multiplayer와 Player Count의 관계
- 세 Mission Type의 최종 Runtime 판정 계약

이번 갱신에서는 코드/Asset/Scene/Data를 변경하지 않았다.


## 2026-10-06 SQLite Content Migration / Editor Verification Update

- MENOS-created Content JSON files under `godot/content/` are no longer present; SQLite is the authoritative Content Canon.
- Final direct-JSON audit found no MENOS Content JSON file I/O in runtime/editor GDScript.
- Robot, Unit, Tower, Stage, Map, and Asset Catalog Editors use SQLite-backed repositories/loaders for Content data.
- All six Editor scenes launched successfully in headless Godot verification.
- Tower Editor empty `sprite_anim` resource loading was guarded; the scene was revalidated successfully.
- This update does not claim full-project PIE acceptance.
