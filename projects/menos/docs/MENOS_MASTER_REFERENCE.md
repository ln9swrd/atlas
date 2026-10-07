# MENOS Master Reference

작성일: 2026-10-07
상태: CURRENT PROJECT REFERENCE / MASTER-ALIGNED
목적: MENOS의 설계, 현재 구현, 개발계획, Content/Editor/Asset 책임, 검증 경계를 하나의 문서에서 확인한다.

> 권한 순서
> 1. `MENOS_COMBAT_CANON.md` — Master 승인 Canon
> 2. `state/CURRENT_STATE.md` — 현재 실제 프로젝트 상태
> 3. 본 문서 — Canon과 현재 상태를 연결하는 통합 기준
> 4. `MENOS_WORK_METHOD_COPILOT_WORKER_SERA.md` — 작업 운영 규칙
> 5. Archive — 역사적 기록/이전 계획
>
> 본 문서는 Canon을 변경하지 않는다. Canon과 충돌하는 과거 문서는 역사적 기록으로만 취급한다.

## 1. 프로젝트 정체성

MENOS는 싱글플레이 슈퍼로봇 전투 게임이다. 현재 Master Canon의 핵심은 플레이어가 슈퍼로봇 1기를 직접 조종하여 다수의 적과 거대 보스를 상대하는 것이다.

플레이어는 파일럿이며, 핵심 직접 조작은 이동, 기본 공격, 타깃 선택/전환, 특수공격, 필살기다. AI 아군은 자동 전투하고, Tower/고정형 지원 시설은 자동 지원한다.

현재 범위는 싱글플레이 캠페인을 우선한다. 멀티플레이, 온라인 협동, 다수 로봇 동시 직접조종, 복잡한 RTS 운영은 현재 핵심 범위가 아니다.

## 2. 전투 Canon 요약

### 플레이어 Robot
- 직접 조종 대상: 기본 1기
- 이동: 직접 조작
- 공격: 직접 사용 가능한 기본 공격/특수공격
- 타깃: 선택 및 전환 가능
- 필살기: 별도 강력한 전투 행동
- 성장: 전투 중 XP/레벨업

### AI 아군
- 자동 이동/타깃/공격
- 플레이어가 개별 지휘하지 않음
- 플레이어 Robot의 전투를 지원

### 고정형 지원 시설
- 기존 Tower 시스템을 폐기하지 않음
- Tower Defense의 주력 조작 대상이 아니라 자동 지원 시설로 취급
- 현재 최소 구현에서는 사전 배치 Tower가 자동 공격

### 적 / Giant
- 일반 적은 다수전의 상대
- Giant는 거대 보스급 전투 유닛
- Giant는 Robot과 직접 교전
- 현재 Giant Runtime에는 CANNON SHOT / CRUSHING BLAST / CHARGE 패턴이 존재

## 3. 게임 진행 구조

```text
Campaign
  -> Stage
      -> Map
      -> Mission
      -> Encounter / Wave
          -> Enemy / Unit
      -> Reward

Runtime
  -> StageManager / StageLoader / MapLoader
  -> GameController
  -> Robot / Allied Unit / Tower / Enemy Runtime State
```

책임 경계:
- Map: 재사용 가능한 전장 구조와 맵 종속 Gameplay 공간/지점
- Mission: 목표와 승패 의미
- Stage: Map + Mission + Encounter/Wave + Stage별 설정의 실제 실행 단위
- Campaign: Stage의 순서와 진행
- Runtime: 위 정의를 실행

현재 Master가 지정한 Mission Type은 Tower Defense, Elimination, Giant Boss Battle이다. Mission Type과 Run Mode/Player Count는 동일 개념으로 취급하지 않는다.

## 4. 현재 실제 구현 상태

### 전투
코드상 다음 경로가 확인되어 있다.
- Robot 직접 이동
- 기본 공격
- 타깃 선택/전환
- Special
- Skill 슬롯
- Finisher
- XP / 즉시 레벨업
- AI 아군
- Giant 보스 패턴
- 고정형 Tower 지원
- Victory / Defeat / Restart
- Campaign / Single Play
- Stage / Map 로딩

### 전투 피해 경로
현재 공통 이벤트 경로는 다음과 같다.

```text
weapon_fired
  -> projectile/effect
  -> progress 완료
  -> damage_requested
  -> damage_enemy / damage_allied_unit / damage_robot
```

특수공격은 `damage_delay` 기반 경로를 사용할 수 있다.

2026-10-07 백그라운드 Runtime Smoke 검증에서 실제로 다음을 확인했다.

```text
COMBAT_RUNTIME_CONTROLLER_READY
WEAPON_TO_EFFECT_PASS
PROJECTILE_DAMAGE_PASS hp=538.0
DIRECT_DAMAGE_PASS hp=506.0
COMBAT_RUNTIME_SMOKE_PASS
```

Giant 초기 HP 620, Armor 18 기준으로 100 피해가 실제 HP 538로 적용되어 Armor 계산이 일치했고, 직접 피해 경로도 확인했다.

판정: CODE VERIFIED / Runtime Smoke PASS. 자연스러운 화면상의 발사→도착→피격 연출은 별도 PIE 시각 검증 경계다.

### Giant
현재 코드 기준:
- HP 620
- Armor 18
- 기본 공격 45
- Robot 공격 거리 120
- Robot 공격 주기 2초
- Robot 피해 20
- CANNON SHOT / CRUSHING BLAST / CHARGE

현재 데이터/Runtime 구현은 존재하지만 최종 밸런스와 전체 보스전 시각 체감은 별도 검증 대상이다.

### HUD
Pilot 중심 HUD의 코드 경로가 존재한다.
주요 정보:
- Robot HP
- Energy
- Level / XP
- Target
- Basic
- Special / Skill 슬롯
- Finisher
- Auto/Manual 및 전투 상태 정보

실제 전투 화면에서의 최종 가독성은 별도 Runtime acceptance 대상이다.

## 5. 현재 Runtime / Build 검증 상태

### CODE VERIFIED
- 핵심 전투 경로
- Giant 패턴
- Robot/Tower/Enemy 피해 경로
- Campaign/Stage/Map 데이터 연결
- SQLite Content loader 경로
- Content Editor의 현재 메뉴 구조

### BUILD VERIFIED
2026-10-07:
- Godot 4.7.2 Windows Export Template 설치 확인
- Windows Release Export 성공
- `godot/builds/MENOS-test-release.exe` 생성
- Exported EXE headless startup exit code 0
- `content/menos.sqlite`가 PCK에 포함됨을 확인

### EDITOR VERIFIED
- Content Editor GUI 실행
- Faction/Skill Editor 전환
- VFX/SFX/BGM/VOICE 메뉴 표시
- 현재 4개 메뉴는 전용 Editor Scene이 없어 비활성
- Content Editor headless initialization PASS
- 관련 Editor의 SQLite 소비 경로 확인

### PIE / Runtime
- 실제 GUI Runtime에서 Title → Single Play → Stage 1 → Wave 1/2 진입 확인
- Enemy animation Asset path 문제 수정 후 실제 Runtime에서 오류 재현되지 않음
- 2026-10-07 background/headless smoke 검증:
  - Giant Boss pattern cycle / damage
  - Attack → Projectile → Hit → Damage timing
  - Pilot HUD runtime state/layout linkage
  - Fixed Tower automatic attack / upgrade
  - Campaign 1 start-to-finish: 3 stages, Giant encounter, final Campaign Victory
- 위 자동화/headless 검증은 PIE VERIFIED로 승격하지 않는다.
- 실제 화면 가독성/연출과 Master 직접 PIE acceptance는 별도 경계로 유지한다.
- Campaign smoke에서 확인된 reward `21.0`, `22.0`, `23.0` 참조 문제는 StageLoader의 정규화된 reward reference 사용으로 수정했다.

중요: 자동화/headless PASS는 PIE VERIFIED와 동일하지 않다.

## 6. 현재 데이터 파이프라인

SQLite가 MENOS Runtime/Editor Content의 authoritative source다.

현재 확인된 원칙:
- `godot/content/menos.sqlite`가 Content Canon
- MENOS-created `godot/content/**/*.json`는 0개
- Robot / Unit / Tower / Stage / Map / Asset Catalog / Faction / Mission / Reward / Skill 등의 Content는 SQLite-backed Repository/Loader를 사용
- Content 저장은 ObjectPersistence를 통해 SQLite에 반영
- `user://` 사용자 저장 JSON은 Content SQLite와 분리

ODB PK 원칙:
- Content 간 식별/참조는 ODB PK 기반
- Name/Title/Display Name은 변경 가능한 속성
- 이미 검증된 현재 독립 Content Type의 PK migration은 완료
- Faction, Map, Wave/Encounter, BGM, SFX, VFX는 추가 정규화가 별도 판단 대상

## 7. Editor 구조

현재 Content Editor는 상위 Shell 역할을 한다.

기존/확인된 Editor:
- Content Editor
- Map Editor
- Stage Editor
- Mission Editor
- Faction Editor
- Skill Editor
- Enemy Editor
- Tower Editor
- Robot Editor
- Unit Editor
- Campaign Editor
- Building Editor
- Asset Catalog / Image Editor

원칙:
- Editor는 Content Definition을 편집한다.
- Gameplay/Settings는 전역 Gameplay Rule과 설정을 담당한다.
- 개별 Robot/Enemy/Tower/Skill 수치와 Stage 구성은 Gameplay/Settings가 중복 소유하지 않는다.
- 독립 Editor는 반복 편집 가치와 독립 데이터 책임이 확인될 때만 만든다.

### 현재 VFX / SFX / BGM / VOICE
Content Editor 상단에 4개 메뉴가 존재한다.

현재 전용 Editor Scene이 확인되지 않아 메뉴는 비활성 상태다. 임시 Scene 연결은 하지 않았다.

이는 메뉴 구조 준비 상태이며 해당 Content Editor 구현 완료를 의미하지 않는다.

## 8. Asset Production Pipeline

권장 책임 구조:

```text
Original Art / Source
        ↓
Catalog Editor
        ↓
Visual Asset
        ↓
Animation
        ↓
Runtime
```

### Catalog Editor
현재 구현 기반:
- 이미지 색상 샘플링/처리
- Background Color 제거
- Color Replace
- Alpha 처리
- Tolerance
- Frame Scope
- Variant / Team Mask 경로
- Visual Asset 연결
- Validation

원본 Asset은 보존한다. Variant와 Team Mask는 Source와 분리한다.

### Visual Asset
핵심 메타데이터:
- Source
- Region
- Frames
- Columns / Rows
- Frame Order
- Anchor
- Owner / Usage
- Team Mask
- Frame Regions / Anchors

### Animation
Animation은 Visual Asset의 Frame/Region/Anchor를 소비한다. Runtime의 직접 Frame 소비 구조를 우선 재사용하며 불필요하게 AnimationPlayer 중심 구조로 재설계하지 않는다.

### VFX / SFX / BGM
Content Definition과 Runtime 재생을 분리한다.
- Content: 어떤 효과/소리/음악이 존재하는가
- Gameplay Runtime: 어떤 이벤트에서 어떤 ODB PK를 요청하는가
- Runtime Audio/VFX System: 실제 재생/표현
- Gameplay/Settings: 전역 볼륨/활성화/정책

현재 VFX/SFX/BGM은 메뉴 수준 준비 상태이며 Schema/Runtime 연결은 별도 범위다.

## 9. UI / 화면 구조

현재 화면의 핵심은 Combat Screen이다.

```text
Title
  -> Stage Select / Campaign
  -> Stage Runtime
  -> Combat
  -> Victory / Defeat
```

개발 도구:
```text
Content Editor
  -> object-specific Editor
```

Stage는 무엇을 실행할지 정의하고 Runtime System은 어떻게 실행할지를 담당한다.

화면을 만들었다는 사실만으로 Runtime 기능이 완성된 것으로 판정하지 않는다.

## 10. Localization

MENOS는 다국어 지원을 목표로 하며 기본 언어는 English다.

책임:
- Gameplay/Settings: 언어 선택, Default Language, Fallback 정책
- Localization Data: 실제 번역 문자열
- Content Definition: 문자열 자체가 아니라 String ID 참조
- Content Editor: 선택 언어에 맞는 UI/콘텐츠 표시
- Runtime: 동일 Localization Data 소비

Editor UI와 Runtime UI의 문자열을 중복 저장하지 않는다.

## 11. 작업 운영 원칙

모든 작업은 다음 순서다.

```text
목적 확인
→ 최소 필요 조건
→ READ-ONLY 조사
→ 최소 변경/검증
→ 판정
→ 성공하면 STOP
```

변경 전:
- HEAD
- Branch
- Working Tree
- 기존 변경사항

변경 후:
- Diff
- 의도하지 않은 변경 여부
- 최소 검증

삭제/덮어쓰기/대규모 Asset 변환/외부 Source는 별도 승인 없이 수행하지 않는다.
Commit/Push는 Master가 명시적으로 승인한 경우에만 수행한다.

화면 테스트는 프로젝트 Canon에 따라 background 방식으로 우선 수행한다. background 방식으로 판별할 수 없는 경우 foreground 조작으로 우회하지 않고 HOLD한다.

## 12. 현재 개발계획

현재 개발은 새로운 시스템을 무조건 추가하는 방식이 아니라 이미 구현된 Canon-aligned 경로를 Runtime에서 수락하고 실제 결함만 수정하는 방식으로 운용한다.

현재 핵심 acceptance 영역:
1. Core Runtime
2. Combat Timing
3. Campaign 1
4. 실제 결함이 발견된 경우의 최소 수정
5. Acceptance Close

구현이 이미 확인된 항목을 다시 개발하지 않는다.

## 13. 현재 Acceptance Gap

### GAP-01 — Giant Boss
상태: background Runtime Smoke PASS / PIE VERIFIED 미확인

검증:
- CANNON SHOT / CRUSHING BLAST / CHARGE 패턴 cycle
- wind-up / damage 경로
- Giant 피해 배율

### GAP-02 — Pilot HUD
상태: background Runtime Smoke PASS / 실제 전투 가독성 및 PIE VERIFIED 미확인

### GAP-03 — Fixed Tower
상태: background Runtime Smoke PASS / PIE VERIFIED 미확인
- 사전 배치
- 자동 공격
- Level 2 upgrade

### GAP-04 — Attack → Hit → Damage Timing
상태: background Runtime Smoke PASS / PIE VERIFIED 미확인

최소 기준:
```text
발사 → 도착 → 피격 → 피해
```

### GAP-05 — Campaign 1
상태: background integrated Runtime Smoke PASS / PIE VERIFIED 미확인
- 3개 Campaign Stage 순회
- Wave / 일반 적 전투
- Giant 등장 및 처치
- 최종 Campaign Victory
- Campaign smoke에서 확인된 reward `21.0`, `22.0`, `23.0` 참조 문제는 StageLoader의 정규화된 reward reference 사용으로 수정함.

## 14. 문서 상태 관리

### 유지해야 하는 핵심 문서
- `MENOS_COMBAT_CANON.md` — 유일한 전투 Canon
- `docs/MENOS_MASTER_REFERENCE.md` — 통합 프로젝트 기준
- `state/CURRENT_STATE.md` — 현재 실제 상태
- `state/HANDOFF_HISTORY.md` — 역사적 Handoff
- `MENOS_WORK_METHOD_COPILOT_WORKER_SERA.md` — 작업 방식
- `docs/vfx_beam_sprite_sheet_generation_prompt.md` — 현재 Beam Sprite Sheet 생성용 프롬프트
- `docs/vfx_beam_sprite_sheet_guidelines.md` — Beam Asset 기준안
- `docs/vfx_beam_image_generation_prompt.md` — Beam 이미지 생성용 보조 프롬프트

### Archive로 이동한 문서
이전의 설계/개발/조사 문서는 내용 손실을 막기 위해 삭제하지 않고 `archive/docs_consolidated_2026-10-07/`에 보존한다.

Archive 문서는 현재 설계/실행 권한이 없다. 역사적 근거가 필요한 경우에만 참조한다.

## 14.1 파일 구조 유지 원칙

현재 실제 파일 구조를 기준 구조로 유지한다. 기존 디렉터리의 책임을 임의로 재편하거나 같은 종류의 파일을 새로운 병렬 디렉터리로 분산하지 않는다.

주요 책임 경계:
- 프로젝트 루트: Canon, README, 상태/운영 문서, 역사적 Browser PoC
- `godot/`: 실제 Godot 프로젝트
- `godot/editor/`: Content Editor
- `godot/scripts/`: Runtime/Repository/Loader/Definition 코드
- `godot/ui/`: Runtime UI
- `godot/content/`: SQLite 및 Editor Content 데이터
- `godot/images/`: Runtime/Visual Asset
- `godot/sound/`: Runtime Audio Asset
- `godot/shaders/`: Shader
- `godot/map_data/`: Map 데이터
- `godot/tests/`: 자동화/백그라운드 검증 코드
- `godot/builds/`: 생성 Build 산출물
- `docs/`: 현재 운영·설계·생성 프롬프트 문서
- `state/`: 현재 상태 및 Handoff
- `archive/`: 폐기/과거 문서 및 역사 자료

파일을 새 위치에 만들 필요가 생기면 기존 책임 경계를 먼저 재사용한다. 구조 변경이 목적에 직접 필요하지 않으면 이동/이름변경/병합을 하지 않는다. 특히 Asset, Content, Editor, Runtime 코드를 임의의 새 병렬 구조로 분리하지 않는다.

생성 프롬프트도 기존 `docs/` 체계를 우선 사용하며, 이미지/VFX/SFX/BGM/VOICE/스프레드시트 등 생산 유형별 하위 구조가 실제로 필요해질 때만 추가한다.

## 15. 폐기/충돌 문서의 처리 원칙

다음과 같은 과거 서술은 현재 기준으로 자동 적용하지 않는다.
- 플레이어가 Robot 위치만 지시하고 Robot이 전투를 전부 자동 수행한다는 구형 Commander 구조
- 전투 중 Tower 건설/Upgrade가 핵심 조작이라는 구형 TD 중심 구조
- 아직 구현되지 않은 20분 TD 경제/Repair/Enemy Robot 구조를 현재 Runtime 사실처럼 서술하는 내용
- 과거 JSON Content를 authoritative source로 보는 내용
- 과거 HEAD를 현재 기준선으로 사용하는 내용

이 내용들은 삭제하지 않고 Archive에 보존한다.

## 16. 현실성 및 범위 판단

TECHNICALLY POSSIBLE: 현재 코드/데이터/Editor 기반으로 핵심 게임 루프를 계속 검증할 수 있다.

PRACTICALLY FEASIBLE: 기존 시스템을 보존하면서 최소 단위로 검증/수정하는 방식이 현실적이다.

RECOMMENDED: 새 시스템 추가보다 현재 Acceptance Gap의 실제 Runtime 판별을 우선한다.

BUSINESS VIABLE: 아직 최종 상업성은 검증되지 않았다. 반복 전투 재미와 완성도 검증이 필요하다.

## 17. 종료 기준

현재 문서 통폐합의 목적은 다음을 달성하는 것이다.
1. Canon과 현재 상태를 명확히 분리한다.
2. 중복된 설계/개발계획/구현상태 문서를 하나의 Reference로 통합한다.
3. 과거 문서는 삭제하지 않고 Archive로 보존한다.
4. 현재 실행 권한을 가진 문서를 소수로 줄인다.
5. 오래된 문서의 수치나 계획이 현재 Canon처럼 재사용되지 않도록 한다.

문서 통폐합 자체가 게임 기능 개발을 의미하지 않는다.

## 18. 현재 기준선

- Project: MENOS
- Branch: `main`
- Git HEAD: 실제 현재 커밋 SHA는 Git `main` HEAD를 권위 원천으로 사용하며 이 문서에는 고정하지 않는다.
- Godot: `4.7.2.stable.official`
- Runtime Content DB: `godot/content/menos.sqlite`
- Current State: `state/CURRENT_STATE.md`
- Canon: `MENOS_COMBAT_CANON.md`

기존 Working Tree 변경사항은 통폐합 작업에서 임의로 수정/되돌리지 않는다.
