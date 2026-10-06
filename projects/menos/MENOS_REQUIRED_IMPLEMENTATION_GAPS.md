# MENOS 실제 구현 필요 항목 목록

상태: PROPOSAL / IMPLEMENTATION GAP LIST
작성일: 2026-09-30

## 1. 목적

기존 설계 문서의 미구현·미확정·UNVERIFIED 항목을 모두 구현 대상으로 취급하지 않고, 현재 Master 승인 Canon과 실제 코드 상태를 대조하여 실제로 구현해야 하는 항목만 추린다.

이 문서는 새로운 Canon을 만들지 않는다. Canon과 현재 구현 사이의 구현 공백을 정리하는 작업 문서다.

## 2. 기준선

- Project: MENOS
- Branch: main
- HEAD: 8cc4e5ab321fb20db9f432bda8a13594f253244a
- Working Tree: 기존 이미지 정리 변경사항 존재. 본 문서 작성으로 기존 변경을 되돌리거나 수정하지 않는다.
- 핵심 Canon: MENOS_COMBAT_CANON.md (MASTER APPROVED / CANON, 2026-09-29)
- 보조 설계: MENOS_GAME_SYSTEMS.md, MENOS_SCREEN_ARCHITECTURE.md, MENOS_COMBAT_MIGRATION_PLAN.md

## 3. 판정 기준

- CONFIRMED: 현재 코드에서 해당 기능의 존재 또는 부족한 구현을 직접 확인.
- IMPLEMENTATION GAP: 설계 요구를 충족하기 위해 실제 코드/데이터/화면 구현이 추가 또는 변경되어야 함.
- PARTIAL: 일부 기능은 이미 있으나 Canon이 요구하는 역할까지 완성되지 않음.
- NOT IMPLEMENTATION: 검증 부족, 선택적 제안, 밸런스 결정, PIE 확인만 필요한 항목은 구현 목록에서 제외한다.

## 4. 실제 구현 필요 목록

### GAP-01 — 보스전 전용 전투 행동 구현

상태: IMPLEMENTED / MINIMUM COMPLETE

현재 확인:
- Giant 전용 공격 루틴이 구현되어 있다.
- CANNON SHOT / CRUSHING BLAST / CHARGE의 3패턴을 순환한다.
- 공격 전 wind-up 및 시각적 telegraph가 존재한다.
- 기존 Giant 데이터를 재사용하며 일반 적과 분리된 보스 행동 경로를 사용한다.

판정:
- 최소 보스 행동 요구는 충족했다.
- 패턴의 세부 밸런스와 추가 페이즈는 별도 결정 사항이며 현재 구현 공백으로 취급하지 않는다.
- PIE는 아직 미검증이다.

### GAP-02 — 전투 HUD의 파일럿 중심 완성

상태: IMPLEMENTED / MINIMUM COMPLETE

현재 확인:
- HP / Energy / XP / Level / Target 정보가 파일럿 중심 HUD에 표시된다.
- 6슬롯 액션 바가 BASIC / SPECIAL / SKILL1~3 / FINISHER로 정리되어 있다.
- 쿨다운 / ENERGY / LOCKED / READY / OFF 상태를 표시한다.
- Space는 BASE 카메라 이동으로 유지하고 Special은 마우스/HUD 입력으로 분리했다.
- Cannon/Gatling 건설 버튼은 주 HUD에서 제거했다.

판정:
- 파일럿 중심 HUD의 최소 요구는 충족했다.
- PIE는 아직 미검증이다.

### GAP-03 — 고정형 지원 시설로서의 Tower 역할 정리

상태: IMPLEMENTED / MINIMUM COMPLETE

현재 확인:
- Campaign/Stage 시작 시 Tower가 사전 배치된다.
- 전투 중 자유 건설 입력을 제거했다.
- Tower는 자동으로 적을 탐색하고 공격한다.
- Tower 클릭은 정보 확인만 수행하며 AUTO SUPPORT 역할을 표시한다.
- 기존 Cannon/Gatling 배치와 레벨 데이터는 유지한다.
- 향후 Tower 성장/업그레이드 정책은 별도 설계 항목으로 남긴다.

판정:
- 고정형 자동 지원 시설이라는 최소 역할은 충족했다.
- Tower 성장 정책은 현재 구현 공백으로 취급하지 않는다.

### GAP-04 — 전투 연출의 공격-피격 인과성 완성

상태: CODE IMPLEMENTED / RUNTIME UNVERIFIED

현재 확인:
- `game_controller.gd`의 `_process()`에서 `proj_defender` 및 `proj_threat` 진행률이 완료되면 `damage_requested` 이벤트를 발생시키는 공통 경로가 있다.
- Robot / Tower 발사 경로는 투사체 효과에 대상·피해량을 전달한다.
- 일반 Enemy 원거리 공격도 투사체 효과에 대상·피해량·source를 전달하고, 근접 공격은 짧은 `damage_delay` 후 피해를 적용한다.
- 조사 중 Giant CANNON SHOT은 투사체를 생성하면서도 피해를 즉시 적용하는 예외를 확인했다. 이를 투사체 도착 시 피해가 적용되도록 수정했다. 효과에는 `target_actor`, `source`, `weapon`, `damage`를 전달하고 즉시 피해 처리를 생략한다.
- Giant CRUSHING BLAST / CHARGE는 해당 공격 효과를 발생시키는 시점에 피해 이벤트를 처리하는 구조로 유지했다.

판정:
- Robot / Tower / Enemy의 기본 공격 피해 적용을 시각적 투사체 도착 또는 근접 타격 시점에 연결하는 코드 경로를 확인·수정했다.
- Godot headless editor 실행은 종료 코드 0으로 완료했다.
- 실제 화면에서 발사 → 도착 → 피격 → 피해가 자연스럽게 인식되는지는 PIE 검증 전까지 UNVERIFIED다.

남은 검증:
- Robot / Tower / Enemy 원거리 / Enemy 근접 / Giant CANNON SHOT의 실제 전투 동작을 PIE에서 확인한다.
- 피격 반응과 피해 숫자의 시각적 타이밍은 PIE에서 확인한다.

성공 조건:
- 화면에서 발사 → 도착 → 피격 → 피해가 자연스럽게 인식된다.

주의:
- 이것은 Canon의 필수 조작 항목 자체가 아니라 상업용 전투 완성도를 위한 구현 보강이다. 보스전이나 HUD보다 우선하지 않는다.

### GAP-05 — 캠페인 1의 Canon 전투 통합 완성

상태: IMPLEMENTED / MINIMUM INTEGRATION COMPLETE

현재 확인:
- Campaign / Single Play 분기와 Stage Select가 구현되어 있다.
- StageManager/StageLoader/MapLoader를 통한 스테이지 로딩이 구현되어 있다.
- Campaign progression과 Robot progression의 저장 경계가 분리되어 있다.
- Campaign 1 Stage 1에는 사전 배치 Tower, Robot 출격, 일반 전투, XP/레벨업, Giant 보스, 승패, Campaign progression 경로가 존재한다.
- Pilot HUD와 고정형 Tower 지원 역할도 현재 구현 상태에 반영되어 있다.

판정:
- 최소 Campaign 1 통합 루프의 코드 경로는 충족했다.
- 실제 처음부터 끝까지의 Runtime 확인은 PIE가 가능해진 후 별도 검증한다.
- 추가 Campaign 콘텐츠 제작은 현재 구현 공백으로 취급하지 않는다.

## 5. 현재 구현되어 있어 별도 구현 목록에서 제외한 항목

다음은 문서상 미구현 후보였지만 현재 코드 확인 결과 별도 신규 구현 대상으로 분류하지 않는다.

- Robot 직접 이동 — 구현 확인.
- 기본 공격 직접 입력 — try_basic_attack() 및 basic_attack 입력 경로 확인.
- 타깃 선택 — 마우스 좌클릭 대상 선택 경로 확인.
- 타깃 전환 — switch_robot_target() 및 select_target 입력 경로 확인.
- 특수공격 — try_special_attack() 구현 확인.
- 추가 스킬 슬롯 — try_skill_slot(1..3) 구현 확인.
- 필살기 — try_finisher() 구현 확인.
- XP/전투 중 레벨업 — add_robot_xp()와 즉시 레벨 증가 경로 확인.
- AI 아군 — AlliedUnitAI의 자동 타깃/이동/공격/지원 로직 확인.
- 승리/패배/재시작 — 전투 상태 전환과 restart_run() 경로 확인.
- Campaign/Single Play 분기 및 Stage Select — 기존 구현 상태 확인.
- Map/Stage 로딩 — StageManager, StageLoader, MapLoader 경로 확인.

이 항목들은 이후 변경으로 인해 코드 상태가 달라질 때만 재검증한다.

## 6. 구현 대상으로 취급하지 않는 문서 항목

다음은 현재 문서에 존재하지만 이번 목록의 실제 구현 필요에는 포함하지 않는다.

- Stage Briefing
- Robot / Loadout 독립 화면
- Robot Management / Inventory / Shop의 완전한 독립 화면
- 복잡한 장비 희귀도/판매/분해 시스템
- 다중 통화 경제 시스템
- Escort 등 미확정 미션 유형
- 멀티플레이 / 온라인 협동
- main.gd 전면 리팩터링
- 신규 대규모 맵 제작
- 추가 로봇/적을 대량 제작
- 실제 PIE에서만 확인 가능한 가독성/타격감 판정
- 최종 밸런스 수치 결정

이 항목들은 현재 Canon의 필수 구현으로 확정되지 않았거나 별도 Master 결정이 필요한 영역이다.

## 7. 현재 작업 순서

1. GAP-05 — 최소 Campaign 1 통합: IMPLEMENTED.
2. GAP-02 — Pilot HUD: IMPLEMENTED.
3. GAP-01 — Giant 보스 행동: IMPLEMENTED.
4. GAP-03 — 고정형 Tower 지원 역할: IMPLEMENTED.
5. GAP-04 — 공격-피격 연출 동기화: CODE IMPLEMENTED / PIE VERIFICATION REQUIRED.

2026-10-01 코드 대조에서 Robot·Tower·Enemy 공격 경로를 확인했고, Giant CANNON SHOT의 즉시 피해 예외를 투사체 완료 시점 처리로 수정했다. Godot headless editor 검증은 통과했으나 실제 발사-도착-피해 연출은 PIE에서 확인해야 한다.

## 8. 최소 완료 기준

현재 프로젝트를 Canon 기준의 최소 플레이 가능 상태로 판단하려면 다음이 모두 충족되어야 한다.

1. Robot 직접 이동.
2. 기본 공격 직접 사용.
3. 타깃 선택/전환.
4. 특수공격/스킬/필살기 사용.
5. XP 및 즉시 레벨업.
6. AI 아군 지원.
7. Pilot 중심 HUD.
8. 지원 시설 역할 정리.
9. 보스전 전용 행동.
10. Campaign 1 통합 플레이 루프.

1~10은 코드 경로 기준으로 구현이 확인되었다. GAP-04의 전투 연출 품질은 PIE 검증 전까지 미확정이다.

## 9. 검증 경계

- CODE VERIFIED: 본 목록 작성 시 현재 코드 경로를 직접 확인한 항목.
- EDITOR VERIFIED: 이번 문서 작업에서는 신규 Editor 변경을 하지 않음.
- BUILD VERIFIED: 이번 문서 작업에서 Build를 실행하지 않음.
- PIE VERIFIED: Master가 현재 PIE를 수행할 수 없는 상태이므로 미검증.

따라서 본 문서는 구현 필요 여부를 판정한 것이며, 구현 후 실제 플레이 품질을 PASS로 판정한 문서는 아니다.

## 10. 상태

STATUS — PASS

목적 — 기존 문서의 미구현 후보 중 실제 구현이 필요한 항목만 분리하여 목록화.

변경 사항 — GAP-04 상태 및 현재 검증 경계를 갱신.

판정 — B 범위의 코드 구현 완료. 추가 전투 구조 변경은 자동 진행하지 않는다.

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
