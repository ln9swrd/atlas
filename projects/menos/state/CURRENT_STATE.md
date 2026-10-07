# MENOS Current State

작성일: 2026-10-07
상태: CURRENT IMPLEMENTATION STATE

## 1. 기준선

- Branch: `main`
- Git HEAD: `main` branch의 실제 HEAD는 Git이 권위 원천이며 문서에는 고정 SHA를 기록하지 않는다.
- Remote: `upstream/main`과 동기화된 상태를 유지한다.
- Working Tree: 현재 검증 기준에서는 clean 상태를 목표로 한다.
- Godot: `4.7.2.stable.official`
- Runtime Content DB: `godot/content/menos.sqlite`
- Combat Canon: `MENOS_COMBAT_CANON.md`
- Integrated Reference: `docs/MENOS_MASTER_REFERENCE.md`

## 2. 실제 구현 상태

### Content / Data
- 현재 Content authority는 `godot/content/menos.sqlite`다.
- MENOS-created `godot/content/**/*.json`는 현재 0개다.
- Robot / Unit / Tower / Stage / Map / Asset Catalog / Faction / Mission / Reward / Skill은 SQLite-backed Repository/Loader 경로를 사용한다.
- Content 저장은 `ObjectPersistence`를 통해 SQLite에 반영한다.
- 사용자 저장 데이터(`user://`)는 Content DB와 분리한다.

### Runtime
- Stage → Encounter → Wave → Group → Enemy 실행 경로가 존재한다.
- Robot 직접 이동, 기본 공격, 타깃 선택, Special, Skill, Finisher가 구현되어 있다.
- AI Allied Unit과 사전 배치 Fixed Tower의 자동 지원 경로가 존재한다.
- Giant Runtime과 Victory / Defeat / Restart 경로가 존재한다.
- Campaign Stage 전환과 Reward 처리 경로가 존재한다.
- Combat damage path는 `weapon_fired → projectile/effect → damage_requested → damage_*` 구조다.

### Editor
- Content Editor 및 개별 Content Editor들이 존재한다.
- Faction / Skill Editor의 SQLite 소비 경로가 확인되었다.
- Asset Catalog / Image Editor가 Visual Asset 메타데이터를 관리한다.
- VFX / SFX / BGM / VOICE 메뉴는 표시되지만 현재 전용 Editor Scene이 없어 비활성 상태다.

### Localization
- `locale/en.po`, `locale/ko.po`가 Localization source다.
- Runtime / Editor는 Godot `TranslationServer` 경로를 사용한다.
- 과거 JSON Localization 계획은 현재 실행 권한이 없다.

## 3. 검증 상태

### CODE VERIFIED
- Core combat event/damage path
- Robot / Enemy / Giant / Tower Runtime path
- Campaign / Stage / Map data connection
- SQLite Content loader/repository path
- Content Editor 메뉴 및 주요 SQLite 소비 경로

### BUILD VERIFIED
- Windows Release Export 성공
- `godot/builds/MENOS-test-release.exe` 생성
- Exported EXE headless startup exit 0
- `content/menos.sqlite` PCK 포함 확인

### EDITOR VERIFIED
- Content Editor GUI 실행
- Faction / Skill Editor 전환
- VFX / SFX / BGM / VOICE 메뉴 표시 및 비활성 상태 확인
- Content Editor headless initialization PASS

### RUNTIME / PIE
- Title → Single Play → Stage 1 → Wave 진입 경로 확인
- Background Combat Runtime Smoke PASS
- Giant / Combat Timing / Pilot HUD / Fixed Tower background smoke PASS
- Campaign 1 integrated background smoke PASS: 3 stages, Giant, final Campaign Victory
- 자동화 및 background/headless 검증은 PIE VERIFIED로 승격하지 않는다.
- 실제 화면 가독성/연출과 Master 직접 PIE acceptance는 미확인이다.
- Campaign smoke에서 확인된 reward `21.0`, `22.0`, `23.0` 참조 문제는 StageLoader의 정규화된 reward reference 사용으로 수정했다.

## 4. 현재 Acceptance Gap

- Giant Boss: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Pilot HUD: background Runtime Smoke PASS / 실제 전투 가독성 및 PIE VERIFIED 미확인
- Fixed Tower: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Attack → Hit → Damage: background Runtime Smoke PASS / PIE VERIFIED 미확인
- Campaign 1: integrated background Runtime Smoke PASS

## 5. 문서 정합성

- `docs/MENOS_MASTER_REFERENCE.md`는 현재 구현과 Canon을 연결하는 통합 기준이다.
- `state/HANDOFF_HISTORY.md`는 역사적 Handoff 기록이다.
- `archive/docs_consolidated_2026-10-07/`는 역사 자료이며 현재 실행 권한이 없다.
- 과거 JSON authority, 구형 Tower Defense 중심 구조, 과거 Git HEAD를 현재 사실로 재사용하지 않는다.
- 현재 파일 구조 책임 경계를 유지하며 병렬 구조를 임의로 만들지 않는다.

## 6. 최근 코드 ↔ 문서 정합성 조사

2026-10-07 코드 ↔ 문서 대조 결과:
- SQLite authority: 코드와 문서 일치
- Visual Asset Repository / Resolver 구조: 코드와 문서 일치
- Localization `.po → TranslationServer`: 코드와 문서 일치
- VFX / SFX / BGM / VOICE 비활성 메뉴 상태: 코드와 문서 일치
- Campaign / Stage / Wave / Combat damage path: 코드와 문서 일치
- 기존 문서의 HEAD 표기만 실제 HEAD보다 뒤처져 있어 현재 기준선으로 갱신함.

판정: 현재 조사 범위에서 기능 구현을 잘못 기술한 핵심 문서 오류는 발견되지 않았으며, 기준선/현재 상태 표현을 보완했다.
