# Gameplay Settings / Content Editor 책임 경계 제안

STATUS — PROPOSAL / NOT CANON

목적: Gameplay/Settings와 Content Editor가 동일 데이터를 중복 관리하지 않도록 책임 경계를 정의하고, 다국어 지원에서 설정·UI·콘텐츠 번역 데이터를 분리한다.

## 1. 기본 원칙

- Gameplay/Settings = 게임 전체가 어떻게 동작하는가.
- Content Editor = 게임 안에 무엇이 존재하고 어떻게 구성되는가.
- Content Definition과 Runtime Rule을 분리한다.
- 하나의 데이터는 가능하면 하나의 시스템이 소유한다.
- 다국어 지원은 MENOS의 Canon 요구사항이다.
- 언어 선택 설정과 번역 데이터는 서로 다른 책임으로 분리한다.
- Content Definition에는 표시 문자열을 직접 하드코딩하지 않고 안정적인 Localization String ID를 참조하는 방향을 사용한다.

## 2. Gameplay / Settings 관리 후보

- Game Rules: 난이도, 게임 속도, 일시정지 규칙
- Combat Rules: 피해 계산, 타깃 규칙, 사망/부활 규칙
- Player Control: 입력, 조작 감도, 기본 조작 정책
- Camera: 추적, 거리, 줌, 흔들림
- HUD: 표시 정책 및 정보 표시 수준
- Progression: XP/레벨 시스템의 전역 규칙
- Economy: 전역 화폐/경제 규칙
- Shop / Marketplace: 활성화 여부와 거래 정책
- Steam: Steam 기능 및 Workshop/결제 기능의 활성화 정책
- Localization Settings: 기본 언어, 현재 선택 언어, fallback 정책
- Save: 저장 및 진행 정책
- Audio: BGM/SFX 기본 정책 및 볼륨
- Accessibility: 접근성 설정
- Debug: 개발/테스트 기능

개별 Robot/Enemy/Tower/Skill의 능력치나 개별 Stage 구성은 Gameplay/Settings가 직접 소유하지 않는다.

## 3. Content Editor 관리 후보

- Robot: 기본 능력치, 무기, 스킬 연결, 이동/방어 정의
- Enemy: HP, 공격력, 속도, 방어, AI 타입, 보상 연결
- Tower: 공격력, 사거리, 공격속도, 비용, 타깃 정책
- Faction: ID, 이름, 색상, Alliance 관계
- Skill / Ability: 효과, 피해, 범위, 쿨다운, 비용, 연출 참조
- Item: 종류, 효과, 장착 위치, 가격/획득 정보
- Mission: 목표, Mission Type, 승패 조건
- Campaign: 순서, Stage 연결, 해금 조건
- Map: 지형, 영역, Spawn, Goal, Tower Placement 등
- Stage: Map + Mission + Encounter/Wave + Reward 구성
- Wave / Encounter: 적 구성, 수량, Spawn 및 시간 구성
- Reward: XP, Currency, Item, Unlock 구성
- Shop Product: 판매 상품과 가격/조건 정의
- Audio / VFX Reference: 콘텐츠별 재생 Asset 참조
- Localization String Reference: 콘텐츠 이름/설명/스킬 문구/미션 문구 등에 사용할 String ID

## 4. Localization / 다국어 책임 경계

다국어 지원은 Canon 요구사항이다. 다만 언어 선택과 실제 번역 문장은 분리한다.

### Gameplay / Settings가 소유

- Default Language
- Selected Language
- Fallback Language 정책
- 사용 가능한 언어 목록을 어떤 설정으로 노출할지
- 언어 변경 정책 및 저장

기본 언어는 English를 사용한다. 사용자가 선택한 언어에 따라 UI와 콘텐츠 텍스트가 해당 언어로 표시되어야 한다.

### Localization Data가 소유

실제 번역 문자열은 별도의 Localization 데이터가 소유한다.

예:

    robot.atlas_01.name
      en = ATLAS-01
      ko = 아틀라스-01
      ja = アトラス-01

    robot.atlas_01.description
      en = ...
      ko = ...
      ja = ...

Localization Data는 UI 문자열과 콘텐츠 문자열을 모두 포함할 수 있으나, 원본 Content Definition과 분리한다.

### Content Definition이 소유

Content Definition은 번역 문장 자체가 아니라 String ID를 참조한다.

예:

    {
      "id": "robot_atlas_01",
      "name_key": "robot.atlas_01.name",
      "description_key": "robot.atlas_01.description"
    }

금지 방향:

    {
      "id": "robot_atlas_01",
      "name": "ATLAS-01"
    }

즉:

    Gameplay / Settings
        ↓
    Selected Language
        ↓
    Localization Data
        ↑
    Content Definition ── String ID

## 5. Content Editor UI 자체의 다국어화

현재 Content Editor UI가 영어로만 표시되는 문제도 동일한 분리 원칙으로 처리한다.

Editor의 버튼, 메뉴, 필드명, 안내문, 검증 오류, 상태 메시지 등 UI 문자열을 코드에 직접 고정하지 않는다.

예:

    editor.save
    editor.cancel
    editor.validate
    editor.publish
    editor.field.hp
    editor.field.attack
    editor.validation.invalid_id

이 String ID를 Localization Data에서 현재 선택 언어에 대응시키고, Content Editor UI가 현재 언어 설정을 사용하도록 한다.

따라서 사용자가 Korean을 선택하면:

    Save → 저장
    Cancel → 취소
    Validate → 검증

등으로 대응하고, English를 선택하면 영어 UI를 사용한다.

Editor UI 언어와 게임 Runtime UI 언어가 동일한 Localization 체계를 사용할 수 있도록 설계하되, Editor 전용 문자열과 Runtime 전용 문자열은 ID namespace 또는 데이터 영역으로 구분한다.

## 6. 번역 데이터의 소유권

- Gameplay/Settings: 언어 선택과 언어 정책
- Localization Data: 번역 문자열
- Content Definition: Localization String ID 참조
- Editor UI: Localization String ID를 사용하여 UI 표시
- Runtime UI: Localization String ID를 사용하여 게임 UI 표시

동일한 문장을 Content Editor 코드, Runtime 코드, Content JSON에 각각 복제하지 않는다.

## 7. 경계 예시

Robot의 HP = 220은 Content Definition이다.

Combat Rules의 피해 계산 방식은 Gameplay Rule이다.

Shop의 Product A와 가격은 Content Definition이고, Shop Enabled 및 거래 제한 정책은 Gameplay/Settings가 소유한다.

Robot 이름의 실제 번역 문장은 Localization Data가 소유하고 Robot Definition은 해당 String ID만 참조한다.

Save 버튼의 영어/한국어 문구는 Localization Data가 소유하고 Editor UI 코드는 String ID만 사용한다.

## 8. 데이터 흐름

    Gameplay / Settings
            ↓
    Selected Language
            ↓
    Localization Data
            ↑
    Content Definitions ──→ Stage / Map / Campaign Data
            ↓                         ↓
            └──────── Runtime ─────────┘

Editor UI도 동일한 Localization Data를 참조한다.

## 9. 현재 개발 적용

현재 Master-directed Editor 우선순위의 Gameplay/Settings Editor는 전역 규칙과 Localization Settings를 관리하고, Faction/Skill/Mission/Campaign 등 개별 Editor는 Content Definition을 관리하는 방향을 권장한다.

현재 영어로 고정되어 있는 Content Editor UI는 향후 UI 문자열을 Localization String ID로 분리하여 사용자 언어 설정에 대응해야 한다.

Item/Reward Editor가 향후 활성화될 경우에도 동일한 경계를 유지한다.

본 문서는 데이터 분리 원칙과 설계 방향을 기록하며, 최종 데이터 스키마와 Editor UI 범위는 Master 결정 및 실제 코드/DB 조사 후 확정한다.
