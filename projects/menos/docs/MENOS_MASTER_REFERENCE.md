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
  - Mission `target_id`: Legacy/Deprecated 필드로 보존하며 P0 Runtime 목표 판정에는 사용하지 않습니다. 현재 목표는 Mission `primary_type`과 Stage/Encounter/Wave 구성으로 결정합니다.
- Stage: Map + Mission + Encounter/Wave + Stage-specific gameplay controls
- Stage gameplay controls: Wave Auto Start / Wave Group Gap / Allied Support
- Single Play and Campaign both execute the selected Stage through the same StageManager/StageLoader/GameController path
- Campaign: Stage의 순서와 진행
- Runtime: 위 정의를 실행

현재 Mission Editor의 `primary_type` 허용값은 코드 기준 `defend_base`, `clear_encounters`, `defeat_giant`이다. 이는 Mission Type의 저장 식별자이며, `Tower Defense`, `Elimination`, `Giant Boss Battle` 같은 과거의 설명용 명칭을 별도 enum 또는 현재 코드값으로 간주하지 않는다. `target_id`는 호환성을 위해 보존되는 Legacy/Deprecated 필드이며 P0 Runtime 목표 판정에 사용하지 않는다. Mission Type과 Run Mode/Player Count는 동일 개념으로 취급하지 않는다.

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
- Faction / Skill Editor 전환
- VFX / SFX / BGM / VOICE 메뉴 entry 및 전용 Editor Scene 경로 확인
- VFX / SFX / BGM / VOICE의 현재 Authoring/Repository/Runtime 연결은 background smoke 기준으로 확인
- Content Editor headless initialization PASS

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

## 단기 목표 종료 및 Git 반영 절차 — CANON (Master 승인 2026-10-10)

단기 목표를 달성하면 관련 문서를 실제 구현·검증 결과에 맞춰 갱신하고, 해당 목표의 변경을 Git에 커밋·푸시한다.

1. 목표 성공 조건을 검증하고 달성 여부를 판정한다. 달성하면 해당 목표를 종료하며 후속 목표를 자동 시작하지 않는다.
2. 관련 문서에는 CONFIRMED / PROPOSAL / UNVERIFIED와 CODE / BUILD / EDITOR / PIE 검증 상태를 구분해 기록한다. 승인되지 않은 제안은 Canon으로 승격하지 않는다.
3. 커밋 전 HEAD, Branch, Working Tree 및 기존 변경사항을 확인한다. 목표와 무관한 변경, 임시 파일, 생성 산출물은 커밋 대상에서 제외한다. 기존 작업물은 임의로 삭제하거나 되돌리지 않는다.
4. 스테이징된 파일 목록과 staged diff를 검토하고, 관련 검증 및 `git diff --check`를 수행한다. 의도하지 않은 변경이나 충돌이 있으면 중단하고 보고한다.
5. 해당 목표에 속하는 검증된 변경만 커밋하고 원격 저장소에 푸시한다. 성공 후 커밋 ID, 푸시 결과, Branch, Working Tree 상태 및 미해결 사항을 보고한다.

## 6. 데이터 권위 모델 — CANON (Master 승인 2026-10-10)

다음 권위 경계를 Canon으로 한다. 이 모델의 승인만으로 현재 구현이 완성되었다고 간주하지 않는다.

- **Content Editor Authoring DB** (`content_editor/data/menos.sqlite`): 편집 가능한 기준정보의 Authoring Source. Runtime DB와 별도 소유·관리한다.
- **Map JSON**: 맵별 독립 Authoring Source. 맵 데이터의 원본이며, SQLite에 저장된 기존 맵 데이터는 이 Canon을 충족한 것으로 간주하지 않는다.
- **Runtime Built-in Content** (`godot/content/menos.sqlite` 및 Runtime 소유 Asset): Runtime 프로젝트의 내장 콘텐츠 기준선. Content Editor DB와 자동 동기화하거나 덮어쓰지 않는다.
- **Published Runtime Package**: Authoring Source에서 생성되는 파생 배포물. 필터링된 SQLite + 버전 명시 Manifest + 참조 Runtime Asset으로 구성하며 Authoring Source가 아니다.
- **Player Save Data**: 플레이어 진행/설정 데이터의 별도 저장 영역. Content Publishing은 이를 포함하거나 덮어쓰지 않는다.

기존 구현은 이 경계의 일부만 충족한다. Publisher, 맵 JSON 원본화, 자산 참조/Manifest, 패키지 호환성 및 Save Data 이전 정책은 별도 검증·계약 정의와 구현 승인이 필요하다.

### 6.1 데이터 전달 계약 — CANON (Master 승인 2026-10-10)

Master는 아래 세 가지 계약을 승인했다. 기존 구현이 계약을 충족하는지는 별도 검증 대상이며, 승인이 곧 구현 완료를 뜻하지 않는다.

**CONFIRMED — Publisher / Asset**
- Publisher는 Authoring DB의 문자열/JSON 값을 재귀 탐색해 `res://` 경로를 수집하고, 맵 JSON도 탐색한다. 발견한 파일이 Runtime root에 없으면 게시를 실패시킨다.
- 게시물은 임시 디렉터리에서 생성되고 DB/Asset 해시를 검증한 뒤 최종 경로로 이동한다. 출력 경로가 이미 존재하면 덮어쓰기를 거부한다.
- Manifest에는 `package_format_version`, `content_schema_version`, DB SHA-256, 포함 테이블, 맵 원본 해시, Asset 경로·크기·SHA-256·role이 기록된다.
- Runtime은 `package_format_version`을 검사하고 DB/Asset 무결성을 검사한다. 현재 확인한 Runtime 코드에서는 `content_schema_version`을 검사하지 않는다.
- 현재 자산 수집은 DB/맵 데이터에서 발견되는 `res://` 참조에 기반한다. 코드의 정적 `preload()`/`load()` 의존성이 모두 Manifest 대상이라고 보장하는 것은 아니다.

**CONFIRMED — Save Data**
- Player profile은 `user://menos_campaign_robot_profile.json`, 설정은 `user://menos_settings.cfg`를 사용한다.
- 사용자 프로필 파일이 없으면 `PlayerProfileRepository`는 Runtime 내장 DB의 레거시 `player_profile` 행을 읽어 사용자 파일로 저장하려 시도한다. 이는 현재 존재하는 레거시 가져오기 동작이며, Publisher가 Save Data를 배포한다는 뜻은 아니다.
- Publisher는 `player_profile` 테이블을 패키지 DB에서 제외한다.

**승인된 계약 규칙 — CANON**
1. **Asset 계약:** Publisher는 데이터 기반 리소스 참조의 누락과 안전하지 않은 경로를 거부한다. 코드 수준 정적 의존성은 별도 목록/검증 대상으로 다룬다. 데이터 스캔만으로 전체 Asset 의존성의 완전성을 주장하지 않는다.
2. **패키지 호환 계약:** `package_format_version`과 `content_schema_version`을 각각 검증한다. 미지원 또는 유효하지 않은 버전은 콘텐츠 로드 전에 fail-closed 처리한다.
3. **게시 안전성:** 패키지는 새 출력 경로에 생성한다. 기존 패키지의 교체·롤백은 별도 승인된 교체 프로토콜 없이는 수행하지 않는다.
4. **Save Data 경계:** Save Data는 콘텐츠 패키지와 분리한다. 기존 레거시 프로필 가져오기 동작은 별도로 평가하며, 신규 마이그레이션 정책은 별도 승인 없이는 추가하지 않는다.

**계약 준수 감사 — READ-ONLY (2026-10-10)**

- **CONFIRMED / Asset:** Publisher의 `collect_resource_paths()`는 DB/맵 JSON의 문자열·배열·객체를 재귀 탐색해 `res://` 참조를 수집하고 빈 경로, 절대 경로, `.`/`..` 경로 요소를 거부한다. 참조된 파일이 Runtime root에 없으면 게시 실패 처리한다.
- **GAP / Asset:** 이 탐색은 데이터에서 발견되는 참조만 대상으로 한다. Runtime 코드의 정적 `preload()`/`load()` 의존성을 전수 수집·검증하는 절차는 확인되지 않았다. 전체 Asset 계약은 **PARTIAL / NOT VERIFIED**.
- **CONFIRMED / Publish safety:** Publisher는 기존 출력 디렉터리가 있으면 덮어쓰기를 거부하고, 임시 디렉터리에서 패키지를 생성·검증한 후 최종 경로로 이동한다. 기존 패키지 교체/롤백 기능은 이번 조사 범위에서 확인되지 않았다.
- **이전 GAP 해결 / Package compatibility:** Runtime `RuntimeContentPackage`가 `package_format_version`과 `content_schema_version`을 각각 검증한다. 누락, 숫자가 아닌 값, 미지원 버전은 DB 경로를 공개하기 전에 fail-closed 처리한다. 현재 지원 버전은 두 항목 모두 `1`이다.
- **검증 결과:** `runtime_content_package_smoke_test.gd`에서 정상 패키지 통과, `content_schema_version=999` 거부, DB 경로 미공개, Manifest 원본 복구 후 재검증을 확인했다. Godot 4.7.2 headless smoke test와 Publisher Python 통합 테스트 통과. 이는 CODE/TEST VERIFIED이며 Build/Editor/PIE 검증은 아니다.
- **CONFIRMED / Save Data boundary:** Publisher는 `player_profile` 테이블을 제외하며 Runtime은 프로필을 `user://menos_campaign_robot_profile.json`에, 설정을 `user://menos_settings.cfg`에 저장한다. 프로필 파일이 없으면 내장 DB의 레거시 프로필을 사용자 파일로 가져오려는 기존 경로가 있다. 이는 기존 동작이며 신규 마이그레이션 정책으로 일반화하지 않는다.
- **검증 범위:** 초기 계약 감사는 소스 코드 정적 조사였다. 후속 승인 작업에서 버전 검사 코드와 회귀 테스트를 추가하고 headless 테스트를 실행했다. Build/Editor/PIE는 실행하지 않았다. Asset 정적 의존성 전체 목록은 여전히 미완료.

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
Content Editor 상단에 VFX / SFX / BGM / VOICE 메뉴가 존재한다.

- VFX: Definition / Repository / Loader / Validator / Runtime Adapter / Runtime Instance와 전용 Editor Scene이 구현되어 있다. Content Editor VFX entry는 활성화되어 있다.
- SFX: SFX Definition / Repository / Loader / Validator / Runtime Adapter / Editor가 구현되어 있다. ROBOT_LASER_FIRE P0 pilot과 기존 SFX Definition binding이 존재하며 Content Editor SFX entry가 활성화되어 있다. Legacy direct-file playback 경로와 SFX bus/settings는 기존 호환 경계로 유지된다.
- BGM: BGM Definition / Repository / Loader / Validator / Runtime Controller / Editor 기반이 구현되어 있다. Faction 01의 Normal / Combat / Victory / Defeat pilot binding이 존재하며 Content Editor BGM entry가 활성화되어 있다. 현재 실제 crossfade playback은 구현 범위 밖이다.
- VOICE: Voice Definition / Repository / Loader / Validator / Runtime Adapter / Editor가 구현되어 있고 VOICE_PILOT_FACTION_01_ATTACK_01_KO P0 pilot이 등록되어 있다. Wave start에서 최소 Runtime playback trigger가 구현되어 있으며 Content Editor Voice entry가 활성화되어 있다. 현재 Dialogue/Subtitle 전체 구조는 구현하지 않는다.

현재 상태와 과거 설계 문서의 "disabled / 미구현" 서술은 역사적 기록으로 취급하며, 현재 구현 판단에는 실제 코드와 state/CURRENT_STATE.md를 우선한다.

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

### Catalog Save Transaction
CATALOG의 저장 경계는 현재 구현에서 다음 순서를 따른다.

```text
Edit
  -> Validate
  -> Prepare All Changes
  -> Persistence
  -> Reload
  -> Verify
```

Catalog 데이터와 `visual_assets` 데이터는 `ObjectPersistence.save_catalog_pair_atomic()`을 통해 하나의 SQLite transaction으로 함께 저장된다. Persistence 단계에서 어느 한쪽이라도 실패하면 transaction rollback으로 기존 정상 상태를 보존한다. 저장 후 `VisualAssetRepository` / `VisualAssetResolver`를 reload하고, SQLite에 다시 읽은 Catalog와 Visual Asset 데이터가 준비된 상태와 일치하는지 검증한다.

이 경계는 이후 ROBOT / UNIT / TOWER / BUILDING 등 Content Editor 저장 흐름에 확장할 수 있는 공통 패턴으로 취급한다. 이는 현재 CATALOG 구현 계약이며 다른 Editor에 대한 적용은 별도 구현·검증 범위다.

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
- Runtime Presentation Scale is not part of the Visual Asset definition; object/context presentation owns scale.

### Animation
Animation은 Visual Asset의 Frame/Region/Anchor를 소비한다. Runtime의 직접 Frame 소비 구조를 우선 재사용하며 불필요하게 AnimationPlayer 중심 구조로 재설계하지 않는다.

### VFX / SFX / BGM
Content Definition과 Runtime 재생을 분리한다.
- Content: 어떤 효과/소리/음악이 존재하는가
- Gameplay Runtime: 어떤 이벤트에서 어떤 ODB PK를 요청하는가
- Runtime Audio/VFX System: 실제 재생/표현
- Gameplay/Settings: 전역 볼륨/활성화/정책

VFX is implemented through Definition/Repository/Loader/Editor/Validator/Runtime Adapter/Runtime Instance and uses the SQLite vfx_definitions Catalog. The impact_explosion Runtime Pilot is implemented and the Content Editor VFX entry is enabled. SFX now has Definition/Repository/Loader/Validator/Runtime Adapter/Editor support with the ROBOT_LASER_FIRE P0 pilot and existing SFX bindings. BGM now has Definition/Repository/Loader/Validator/Runtime Controller/Editor support with the Faction 01 four-context pilot binding. VOICE now has Definition/Repository/Loader/Validator/Runtime Adapter/Editor support with the approved VOICE_PILOT_FACTION_01_ATTACK_01_KO pilot and minimum Wave-start trigger. Full Dialogue/Subtitle architecture, broad Voice coverage, and actual BGM crossfade playback remain outside the current implementation boundary. Each media domain remains a separate acceptance scope.

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

## 단기목표 중심 연속 작업 운영 — CANON (Master 승인 2026-10-10)

1. 모든 작업의 기본 단위는 **단기목표**로 한다.
2. 단기목표는 개별 작업을 직렬적으로 나열하는 대신, 목적에 직접 관련된 작업을 가능한 범위에서 묶어 **연속성 있는 완성 경로**로 설계한다.
3. 연속 작업에는 필수 조사, 설계, 구현, 테스트, 문서 갱신, 필요한 Git 반영을 포함할 수 있다. 각 작업을 단순히 끝내고 후속 필수 작업을 남겨두지 않는다.
4. 단, **Scope Lock**, 변경 안전성, 필수 승인, 검증 경계를 준수하며, 서로 독립적이거나 리스크가 다른 사항은 임의로 묶어 실행하지 않는다. 실제 결정이 필요하거나 승인 범위를 넘어야 하면 HOLD 후 Master의 판단을 요청한다.
5. 단기목표의 성공 조건을 만족하면 목표에 포함된 연속 작업을 종료하고 STOP한다. 자동으로 다음 단기목표로 이동하지 않는다.
6. 각 단기목표는 목적, 범위, 성공 조건, 금지사항, 변경 권한, 검증 및 보고 기준을 명확히 한다.

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
Commit/Push는 단기목표 달성 시 수행한다. 단, 단기목표에 포함되지 않는 기존 변경사항을 함께 커밋하지 않으며, 목표 범위·Diff·검증 결과를 확인한 뒤 해당 목표에 속하는 변경만 커밋하고 Push한다. 목표 달성 여부가 불명확하거나 원격 반영에 위험이 있으면 HOLD 후 Master에게 보고한다.

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

## 12. Content Editor / Runtime Data Authority Boundary — 2026-10-09

This section records the current implementation boundary against the approved data-authority Canon.

- Existing Runtime project and shipped-content baseline: `godot/` and `godot/content/menos.sqlite`.
- Independent Content Editor project: `content_editor/`; authoring DB copy: `content_editor/data/menos.sqlite`.
- **Canon (Master-approved 2026-10-10):** the Content Editor Authoring DB is the authoring source for editable reference data; each map has an independent JSON authoring source; the Runtime DB/assets remain Runtime-owned built-in content; the published package is a derived artifact; player save data remains separate and must not be overwritten by publishing.
- This authority model is approved, but end-to-end implementation remains **UNVERIFIED**. A complete published Runtime package path, map JSON source implementation, asset collection/reference contract, schema/package compatibility contract, and failure-safe publish transaction are not yet verified together.
- Runtime dependencies include both database-driven asset paths and code-level `res://` preloads. Any future publisher must account for both categories and validate referenced resources before publishing.
- Headless smoke tests and isolated database tests are evidence for their specific paths only. They do not establish full GUI acceptance or Master PIE VERIFIED.
- For current Editor/Runtime separation progress, use `docs/CONTENT_EDITOR_RUNTIME_SEPARATION_PLAN.md`; for the latest implementation/verification status, use `state/CURRENT_STATE.md`.
- This note records the approved Canon boundary; it does not claim that implementation or Production acceptance is complete.

## Content Editor Authoring Boundary Re-review

실제 제작자 관점에서 Content Editor의 주요 메뉴를 재검토했다. Catalog는 Source Image/Visual Asset의 공통 Authoring 계층, Robot/Unit/Tower/Building은 Semantic Game Object Authoring, Map은 공간/배치, Mission은 목표, Stage는 단일 플레이 시뮬레이션 데이터, Campaign은 진행 구조, Faction은 상위 소속을 담당하는 것으로 정리했다.

상세 P0 필드와 메뉴 간 책임 경계는 CONTENT_EDITOR_IMPLEMENTATION_VERIFICATION_DECISION_MATRIX.md의 Content Authoring Menu Production Review를 기준으로 한다.

Status: PROPOSAL / NOT CANON

## GUI Verification Tooling Update — 2026-10-08

- 듀얼 모니터 및 대형 화면 환경의 GUI 검증을 위해 창/화면 캡처와 입력 방법을 검증하였다.
- mss로 필요한 화면 영역을 캡처하고, 판독용 이미지를 축소한 뒤 실제 물리 픽셀 좌표로 환산하는 방식을 사용한다.
- pyautogui로 실제 Godot GUI 클릭/키 입력을 수행한다.
- Microsoft winapp CLI는 Godot 창 탐색, DPI/좌표 확인 및 창 단위 진단용 보조 도구로 유지한다.
- pywinauto는 Godot 내부 Control이 UI Automation/Win32 child control로 노출되지 않아 제거하였다.
- 실제 GUI 최소 검증에서 ROBOT → UNIT → TOWER Editor 진입 및 각 Editor의 RELOAD 동작을 확인하였다.
- 본 검증은 Content Editor GUI 경로 확인이며 Master의 최종 PIE acceptance를 대체하지 않는다.

## Short-term Content Editor / Runtime Boundary — 2026-10-09

**Master-approved direction; the data authority boundary is now Canon (2026-10-10). Implementation remains pending separate authorization.**

- Map authoring source: one independent JSON file per map.
- Runtime delivery: filtered SQLite database + versioned manifest + referenced Runtime Assets.
- Supported short-term play modes: Campaign and Single Play only.
- Runtime owns the title/main screen, gameplay scene, HUD, navigation and execution behavior. Content Editor owns authoring tools and editable content data (including maps), validation and authoring preview. The Editor does not own the actual Runtime screens.
- Current implementation does not yet meet the map-file source-of-truth or publish-package contract. Existing SQLite map storage, JSON-looking legacy paths, empty Runtime Asset manifest and multiplayer metadata are documented gaps, not grounds for silent migration.
- The data-authority rules above are Canon. The broader implementation plan and play-mode scope do not by themselves authorize code, DB, Asset or Runtime configuration changes. Final visual/PIE acceptance remains with Master.

## Canon: Independent Project Documentation and Code Ownership (Master-approved 2026-10-09)

**CANON:** Content Editor and Runtime must separately own and manage their documentation and code.

- Content Editor-specific documentation and code belong within the `content_editor/` project boundary.
- Runtime-specific documentation and code belong within the `godot/` project boundary.
- A change in one project must not implicitly change the other project's owned documents or code.
- Shared data contracts and protocols must have explicit ownership and a defined shared boundary. Changes require cross-project impact analysis and a deliberate synchronization procedure.
- Root-level integration documents record Canon, interfaces, and status; they do not replace project-owned documentation.
- This documentation/code ownership Canon is separate from the DB-separation Canon. The approved publishing package, per-map JSON source, and mode scope remain distinct decisions.
- CONFIRMED: `content_editor/` and `godot/` are separate project directories. UNVERIFIED: completeness of project-local documentation and governance of shared contracts; inspect READ-ONLY before proposing structural changes.
- This update changes only root integration documents. It does not create, move, or duplicate project-local files and does not change code.
