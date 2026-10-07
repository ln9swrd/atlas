# MENOS — Single-Player TD Mission Content Development Plan

STATUS — PROPOSAL / NOT CANON

## 1. 목적

본 개발계획은 다음의 싱글플레이 Tower Defense 미션을 실제 게임에서 재현하기 위해 Content Editor와 Runtime이 어떤 콘텐츠를 갖추어야 하는지 정의한다.

핵심 플레이 루프:

```text
20분 방어
→ Wave 생존
→ Robot 전방 전투
→ Enemy 처치 / Gold 획득
→ Tower 건설 / Upgrade
→ Robot Level Up
→ Robot 파괴 시 증가하는 Respawn Penalty
→ 기지 복귀 / 수리 / 재출격
→ 후반 Enemy Robot 등장
→ 최종 승부
```

승리 조건:
- Wave 생존 / 제한 시간 달성
- Enemy Base 파괴
- Dimension Gate 파괴

패배 조건:
- 아군 방어 목표 파괴
- Mission에서 정의한 기타 패배 조건

초반에는 Enemy Base / Dimension Gate 직접 파괴가 현실적으로 어려운 구조를 전제로 한다.

## 2. 개발 원칙

1. Content Definition과 Gameplay Rule을 분리한다.
2. 모든 Content Schema의 식별자는 ODB PK 번호를 사용한다.
3. Name / Title / Display Name은 변경 가능한 속성이다.
4. Content 간 참조는 이름이나 파일명이 아니라 ODB PK를 사용한다.
5. Wave는 단순 Spawn List가 아니라 전술 콘텐츠다.
6. Unit은 개별 전투 특성, Wave는 전술적 구성과 진군 방식을 정의한다.
7. Godot 기본 VFX 시스템은 제작 도구이며 완성된 게임 VFX Asset Library가 아니다.
8. 성공한 콘텐츠는 최소 검증 후 다음 콘텐츠로 진행한다.
9. 실제 Schema와 Runtime 소비 경로를 확인하지 않은 상태에서 새로운 참조 구조를 임의로 확정하지 않는다.

## 3. 전체 Content 구조

```text
Campaign
 └─ Mission
     └─ Stage
         └─ Map
             ├─ Base / Dimension Gate
             ├─ Spawn Point
             ├─ Waypoint / Path
             ├─ Tower Zone
             ├─ Robot Base / Repair Point
             └─ Fog / Minimap Data

Mission
 ├─ Wave
 │   └─ Encounter / Group
 │       └─ Unit
 │
 ├─ Robot
 │   └─ Skill
 │
 ├─ Tower
 │   └─ Upgrade
 │
 ├─ Reward / Economy
 ├─ BGM
 ├─ SFX
 └─ VFX
```

## 4. 개발 단계

### Phase 0 — 기존 구조 대조

목적:
현재 프로젝트에 이미 존재하는 Content와 Runtime 경로를 확인한다.

대상:
- Mission
- Stage
- Map
- Unit
- Robot
- Tower
- Skill
- Faction
- Reward / Economy
- BGM / SFX / VFX
- Content Catalog
- Runtime Loader / Repository

작업:
- 기존 Schema 확인
- ODB PK 생성/할당 방식 확인
- Content 간 기존 참조 방식 확인
- Runtime 소비 경로 확인
- Editor가 이미 제공하는 필드 확인
- 중복 Schema 방지

판정:
```text
EXISTS
PARTIAL
MISSING
CONFLICT
```

이 단계에서 구조적 충돌이 발견되면 구현을 중지하고 HOLD한다.

---

### Phase 1 — Mission / Stage / Map 기반 구축

목적:
20분 TD 미션이 실행될 전장과 미션 정의를 준비한다.

#### Mission
필수 콘텐츠:
- ODB PK
- Name / Title
- Mission Type = TD
- Stage 참조
- 제한 시간
- 승리 조건
- 패배 조건
- 시작 Gold
- Wave 구성 참조
- Enemy Base / Dimension Gate 참조
- Fog 설정
- Minimap 설정
- Enemy Robot 등장 조건

#### Stage
필수 콘텐츠:
- ODB PK
- Name / Title
- Map 참조
- Mission 참조
- Wave 순서
- Spawn 설정
- 시간축
- 난이도 정보

#### Map
필수 콘텐츠:
- ODB PK
- Tile Size / Map Size
- Terrain
- 이동 가능 영역
- Tower 건설 가능 영역
- Player Base
- Enemy Base
- Dimension Gate
- Ground Spawn
- Air Spawn
- Path / Waypoint
- Robot Start / Repair Point
- Minimap 정보
- Fog of War 정보

완료 기준:
전장에 Player Base, Enemy 목표, Spawn, Path, Tower Zone, Robot Repair Point를 배치할 수 있다.

---

### Phase 2 — Faction / Unit 기반 구축

목적:
Wave가 사용할 적 세력과 전투 Unit을 준비한다.

#### Faction
- ODB PK
- Name / Title
- Team / Alignment
- Color / Identity
- 소속 Unit / Robot 참조

#### Unit
최소 역할:
- Light
- Heavy
- Ranged
- Air

필수 데이터:
- ODB PK
- Name / Title
- Faction
- Ground / Air
- Role
- HP
- Defense
- Attack
- Attack Range
- Attack Speed
- Base Movement Speed
- Target Type
- Base / Gate 공격 여부
- Gold Reward
- 이동 / 공격 / 피격 / 파괴 Asset 참조
- SFX / VFX 참조

완료 기준:
각 Unit이 독립적으로 Spawn되어 이동하고 공격할 수 있는 정의를 제공한다.

---

### Phase 3 — Wave / Encounter 구축

목적:
20분 미션의 전술적 압박을 구성한다.

#### Wave
필수 데이터:
- ODB PK
- Name / Title
- Wave Type
- Unit Composition
- Group
- Formation
- Spawn Pattern
- Spawn Interval
- Movement Speed Policy
- Speed Synchronization
- Group Delay
- Special Rule

Movement Speed Policy:
- INDIVIDUAL
- SYNCHRONIZED
- ANCHOR
- FORMATION

필수 Wave 유형:
1. Light Swarm
2. Air Assault
3. Heavy Breakthrough
4. Ranged Support
5. Mixed Assault
6. Heavy-anchored Synchronized Formation
7. Final Enemy Robot Wave

완료 기준:
동일한 Unit Catalog를 이용해 서로 다른 전술적 Wave를 제작할 수 있다.

---

### Phase 4 — Tower / Upgrade 구축

목적:
플레이어가 Gold를 사용해 방어 구조를 구축하도록 한다.

Tower 유형:
- Ground Tower
- Air Tower
- Universal Tower

필수 데이터:
- ODB PK
- Name / Title
- Target Type
- HP
- Attack
- Attack Speed
- Range
- Build Cost
- Build Time
- Upgrade 단계
- Upgrade Cost
- Upgrade별 능력치
- 건설 가능 조건
- 공격 Asset
- Attack SFX ODB PK
- Attack VFX ODB PK
- Destroy VFX ODB PK

Universal Tower:
- EMP Effect 참조
- 긴 Cooldown
- Enemy Movement Slow
- 재사용 전까지의 상태

완료 기준:
Wave 유형에 따라 Ground / Air / Universal Tower의 선택 가치가 발생한다.

---

### Phase 5 — Robot / Skill 구축

목적:
Tower Defense만으로 해결할 수 없는 전방 전투를 Robot이 담당하도록 한다.

#### Robot
필수 데이터:
- ODB PK
- Name / Title
- Faction
- HP
- Attack
- Defense
- Movement Speed
- Attack Range
- Basic Attack Skill
- Skill 1
- Skill 2
- Skill 3
- Level
- Level Growth
- Base Respawn Time
- Repair Time
- Repair Cost
- Robot Asset

#### Skill
필수 데이터:
- ODB PK
- Name / Title
- Target Type
- Range
- Damage / Effect
- Cooldown
- Resource Cost
- Area
- Status Effect
- VFX ODB PK
- SFX ODB PK
- Animation

조작은 Gameplay에서 담당한다.

```text
Map / Minimap Click → Move
R → Recon
H → Hold / Shooter command
A → Attack
Skill 1~3 → Skill execution
```

완료 기준:
Robot이 전장 이동, 기본 공격, Skill 1~3, 정찰/사수/공격 행동을 사용할 수 있는 Content Definition을 제공한다.

---

### Phase 6 — Robot Death / Repair / Respawn Content

목적:
Robot 파괴가 지속적인 전략적 비용이 되도록 한다.

Robot Content:
- Base Respawn Time
- Repair Time
- Repair Cost

Gameplay Rule:
- Death Count
- Respawn Penalty
- 누적 Penalty 계산
- Base 복귀
- Repair
- 재출격

예시:

```text
기본 10초
→ 1회 파괴 15초
→ 2회 파괴 20초
→ 3회 파괴 30초
→ 이후 추가 증가
```

실제 수치는 별도 Balance 작업에서 결정한다.

---

### Phase 7 — Economy / Reward 구축

목적:
Robot 전투가 Tower 건설과 Upgrade로 연결되도록 한다.

Content:
- Enemy Kill Reward
- Wave Reward
- Enemy Robot Reward
- Tower Build Cost
- Tower Upgrade Cost
- Robot Level Up Cost
- Repair Cost

Gameplay:
- Gold Wallet
- Gold 지급
- Gold 소비
- Wave Reward 처리
- Level Up 처리

완료 기준:
Robot 전투 → Gold → Tower 건설/Upgrade → 다음 Wave 대응이라는 순환이 성립한다.

---

### Phase 8 — BGM / SFX / VFX 구축

#### BGM
필수 콘텐츠:
- ODB PK
- Name / Title
- Category
- Audio Asset
- Volume
- Pitch
- Loop
- Fade In / Fade Out
- Priority
- Transition

최소 Category:
- Mission Start
- Battle
- Heavy Wave
- Enemy Robot
- Victory
- Defeat

BGM 제작 원칙:
- 게임 플레이를 방해하지 않으면서 반복 재생할 수 있는 구조를 우선한다.
- 기본 Battle BGM은 짧은 Intro 이후 Main / Variation 구간을 거쳐 자연스럽게 Loop되도록 제작한다.
- 전투 상황에 따라 동일 테마의 변주를 사용할 수 있도록 구성한다.
- BGM Asset과 Gameplay 상태 전환을 분리하고 Runtime에서 재생 / Loop / Fade / Transition을 제어한다.
- 동일한 원본 음악을 재사용하고 필요하면 Runtime Volume / Pitch 등으로 제한적으로 변형한다.
- 외부 음악 Asset은 필수성이 확인되고 Master가 승인한 경우에만 사용한다.

권장 Battle BGM 구조:
- Intro: 약 4~8초
- Main A: 약 16초
- Main B: 약 16초
- Variation: 약 16초
- 이후 Main A로 Loop

최소 BGM 제작 구성:
- Battle — 기본 전투 Loop BGM
- Mission Start — 임무 시작용 짧은 전환 음악
- Heavy Wave — 강한 적 공세용 변주
- Enemy Robot — 강적 등장/전투용 변주
- Victory — 승리 결과 음악
- Defeat — 패배 결과 음악

제작 도구:
- 현재 PC에는 Audacity 4.0.1이 설치되어 있으며 기본 편집 / Loop 제작에 사용할 수 있다.
- FFmpeg가 설치되어 있어 포맷 변환 및 기본 오디오 처리를 사용할 수 있다.
- 전문 DAW는 Cakewalk Product Center를 설치하여 현재 공식 Cakewalk Sonar 경로를 준비했다.
- Sonar 본체는 아직 설치되지 않았으며 Product Center의 사용자 로그인 후 설치가 가능하다.
- Cakewalk 계열은 무료 사용 범위와 유료 기능/멤버십이 분리될 수 있으므로, MENOS에서는 유료 구매를 전제로 하지 않는다.
- 과거 Cakewalk by BandLab(CbB) 설치 시도에서 잔여 설치 프로세스와 설치 파일이 남아 있으므로 강제 제거는 하지 않고 재부팅 등 안전한 정리 시점으로 보류한다.
- 본격적인 작곡 / 편곡은 무료 도구를 우선 사용하며, 필요 시 무료 DAW 대체 후보를 별도 검토한다.
- 현재 PC의 Audacity / FFmpeg만으로도 기본적인 BGM / SFX 편집과 포맷 변환이 가능하므로 추가 DAW 설치는 필수 작업으로 보지 않는다.
- Vrew 역시 무료 사용 범위와 유료 기능/사용량 제한이 있을 수 있으므로, MENOS의 자막/음성 편집 작업은 무료 대체 도구를 우선 검토한다.
- Vrew 대체 후보로 Subtitle Edit를 우선 검토한다. Whisper 기반 음성 인식과 자막 편집을 로컬 중심으로 구성할 수 있다.
- 영상 편집이 필요한 경우 Kdenlive 또는 DaVinci Resolve Free를 후보로 검토하되, 실제 필요성이 확인되기 전에는 추가 설치하지 않는다.
- 외부 Asset이나 유료 DAW / 영상 도구 구매는 목적과 필요성이 확인되기 전에는 진행하지 않는다.
- 현재 PC에는 별도 AI TTS / AI Voice Generator(예: ElevenLabs 계열) 설치가 확인되지 않았다.
- 현재 확인된 오디오 도구는 Audacity / FFmpeg이며, 녹음·편집·포맷 변환에는 사용할 수 있지만 AI 캐릭터 보이스 생성 환경은 별도 준비가 필요하다.
- 게임용 AI 보이스는 상업 이용 조건, 음성 라이선스, 캐릭터별 음색 일관성을 확인한 외부 TTS 서비스를 후보로 조사한 뒤 필요 시 도입한다.
- 외부 AI 음성 서비스 도입 및 음성 Asset 생성은 필수성이 확인되고 Master가 승인한 경우에만 진행한다.

#### SFX
필수 콘텐츠:
- ODB PK
- Name / Title
- Category
- Audio Asset
- Volume
- Pitch
- Pitch Random Range
- Loop
- 2D / 3D
- Attenuation
- Priority
- Concurrency

SFX 제작 원칙:
- 하나의 원본 SFX를 여러 Robot / Tower / Skill이 재사용할 수 있도록 제작한다.
- Robot별 차이는 Runtime Pitch / Volume / Filter 등으로 우선 변형한다.
- Gameplay 판정과 SFX 재생을 분리한다.
- 발사음과 적중음을 분리하여 재사용한다.
- 장시간 Loop SFX는 실제 필요성이 확인된 경우에만 제작한다.

Beam SFX 최소 구성:
- Beam_Fire — 에너지 충전/방출을 포함한 발사음
- Beam_Impact — 적중 순간의 충격음
- 선택: Beam_Charge — 긴 충전 시간이 필요한 무기
- 선택: Beam_Travel_Loop — 빔이 지속되는 무기

Beam_Fire 제작 레이어:
1. Low — 짧은 저주파 에너지 압력
2. Mid — 에너지 방출 질감
3. High — 날카로운 전자/에너지 질감
4. Tail — 짧은 잔향

권장 시작 길이:
- Beam_Fire: 약 0.4~0.7초
- Beam_Impact: 약 0.2~0.5초
- Beam_Charge: 약 0.15~0.3초

제작 도구:
- 현재 PC의 Audacity를 우선 사용한다.
- FFmpeg를 포맷 변환 및 기본 오디오 처리에 사용한다.
- 추가 외부 Asset은 필수성이 확인되고 Master가 승인한 경우에만 사용한다.

최소 SFX:
- Robot Attack
- Robot Hit
- Robot Destroy
- Tower Attack
- Tower Destroy
- EMP
- Skill 1~3
- Beam Fire
- Beam Impact
- Repair
- Level Up
- Warning
- Victory
- Defeat

#### VFX
최소 콘텐츠:
- ODB PK
- Name / Title
- Category
- Sprite / Texture Reference
- Particle
- Shader
- Animation
- Light
- Layer / Z Order
- Duration

최소 VFX:
- Attack
- Hit
- Explosion
- EMP
- Tower Destroy
- Robot Destroy
- Skill 1~3
- Repair
- Level Up
- Victory
- Defeat

---

### Phase 9 — UI / Minimap / Fog 연결

Content 또는 Runtime에서 필요한 참조:
- Robot HP
- Robot Level
- Skill 1~3
- Cooldown
- Gold
- Wave Number
- Wave Timer
- Mission Timer
- Base HP
- Respawn Timer
- Tower Upgrade
- Minimap
- Fog of War

Minimap과 Fog는 Mission/Map 설정을 Runtime UI가 소비하는 구조를 우선 검토한다.

---

### Phase 10 — Enemy Robot / Final Wave

목적:
20분 미션의 최종 승부를 만드는 단계.

필수 Content:
- Enemy Robot
- Enemy Robot Skill
- Enemy Robot Faction
- Final Wave
- 등장 조건
- Spawn Point
- Reward
- Victory / Defeat 연결

Enemy Robot은 일반 Wave보다 높은 전투 영향력을 가지며, 플레이어 Robot의 직접 개입과 Tower 방어를 동시에 요구하는 최종 전투 요소로 구성한다.

---

## 5. 최종 Content Checklist

20분 TD 미션 재현에 필요한 최소 Content:

```text
[WORLD]
Map
Stage
Mission

[COMBAT]
Faction
Unit
Robot
Skill
Tower

[WAVE]
Wave
Encounter / Group
Formation
Spawn Pattern

[ECONOMY]
Reward
Tower Cost / Upgrade
Robot Level Up
Repair Cost

[AUDIO]
BGM
SFX

[VFX]
VFX

[UI / PRESENTATION]
Icon / Portrait / Animation / Minimap Asset
```

## 6. 개발 우선순위

최소 구현 순서는 다음을 권장한다.

```text
1. 기존 Schema / Runtime 조사
2. Map / Stage / Mission
3. Faction / Unit
4. Wave / Encounter
5. Tower
6. Robot
7. Skill
8. Economy / Reward
9. Repair / Respawn
10. BGM / SFX / VFX
11. Minimap / Fog / HUD
12. Enemy Robot / Final Wave
```

단, Phase 0 조사 결과 기존 구조가 이미 존재하면 해당 Editor를 재사용하고 중복 구현하지 않는다.

## 7. 현재 구현 상태 — 2026-10-07

### Content Editor 메뉴

현재 `godot/editor/content_editor.tscn`의 상단 메뉴에 다음 콘텐츠 분류 메뉴가 추가되어 있다.

- VFX
- SFX
- BGM
- VOICE

현재 프로젝트에는 이 4개 항목에 대응하는 전용 Editor Scene이 아직 확인되지 않았으므로 메뉴는 비활성 상태로 표시한다. 존재하지 않는 Editor를 임시 연결하지 않는다.

### GUI / Editor 검증 기반

- Windows 기반 화면 캡처: VERIFIED
- 마우스 이동 입력: VERIFIED
- 키보드 입력: VERIFIED
- 실제 MENOS Content Editor GUI 실행: VERIFIED
- VFX / SFX / BGM / VOICE 4개 메뉴의 화면 표시: VERIFIED
- 기존 Faction Editor / Skill Editor 버튼의 실제 화면 전환: VERIFIED
- VFX 버튼의 비활성 상태 및 클릭 시 무전환: VERIFIED
- Content Editor 씬의 Godot 4.7.2 headless editor 초기화: PASS
- `git diff --check`: PASS
- Windows Export Templates 4.7.2 설치: VERIFIED
- Windows Release Export: VERIFIED
- Exported EXE headless startup: VERIFIED
- `content/menos.sqlite` PCK 포함 및 exported runtime 접근: VERIFIED
- `godot/export_presets.cfg`에 `include_filter="content/menos.sqlite"` 적용
- `campaign_editor.gd:62` Variant type inference warning이 export log에서 확인됨. Editor 전용 경로로 보이며 현재 Build/EXE 실행은 차단하지 않음. 수정은 별도 범위로 유지한다.

위 검증은 GUI 입력 수단 확보와 씬 구조 검증을 의미하며, 실제 사용자 수준의 Content Editor 클릭/편집/저장/Runtime 반영 검증과는 구분한다.

### Build / Export 검증 — 2026-10-07

- Godot 4.7.2 Windows Export Templates를 설치했다.
- Windows Desktop Release Export가 성공했다.
- 최초 Export에서 `res://content/menos.sqlite`가 PCK에 포함되지 않아 exported runtime DB open이 실패했으나, `export_presets.cfg`의 `include_filter`에 해당 DB를 명시한 후 재Export하여 해결했다.
- Export log에서 `res://content/menos.sqlite`가 `savepack` 단계에 포함되는 것을 확인했다.
- Exported EXE를 `--headless --quit-after 10`으로 실행하여 exit code 0을 확인했다.
- 따라서 현재 기준 `BUILD VERIFIED` 및 `EXE START VERIFIED`는 PASS다.
- `PIE VERIFIED`는 실제 foreground 사용자 화면 검증을 수행하지 않았으므로 UNVERIFIED로 유지한다. 화면 테스트는 프로젝트 Canon에 따라 background 방식으로 수행한다.
- 임시 Export log는 삭제했으며, 생성된 Windows build artifact는 `godot/builds/`에 남아 있다.
- 이번 작업에서는 commit/push를 수행하지 않았다.

## 8. 완료 판정

### Content 준비 완료

각 Content Editor에서 필요한 정의를 저장하고 ODB PK로 서로 참조할 수 있다.

### Runtime 준비 완료

Mission → Stage → Map → Wave → Unit / Tower / Robot / Skill의 전체 경로가 실제 Runtime에서 소비된다.

### Gameplay 준비 완료

다음 루프가 실제로 성립한다.

```text
Spawn
→ Wave 진군
→ Robot 전투
→ Gold 획득
→ Tower 건설
→ Tower Upgrade
→ 다음 Wave
→ Robot Level Up
→ Robot 파괴
→ 증가한 Respawn Time
→ Repair / 재출격
→ Enemy Robot
→ Victory / Defeat
```

### 최종 검증

- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED

자동화 테스트 PASS만으로 PIE VERIFIED를 선언하지 않는다.

## 8. 범위 제한

본 문서는 개발계획이다. 실제 Schema, 수치 Balance, Runtime 구현 상세 및 Canon 변경을 확정하지 않는다.

특히 다음은 Master 승인 또는 별도 검증 없이 확정하지 않는다.

- 새로운 ODB PK 할당 체계
- 기존 Schema의 대규모 변경
- 기존 Asset 삭제/교체
- 실제 20분 Wave 수와 난이도 곡선
- 실제 Unit / Tower / Robot 수치
- Enemy Robot의 구체적인 설계
- 외부 Asset 사용

PROPOSAL ≠ CANON.
