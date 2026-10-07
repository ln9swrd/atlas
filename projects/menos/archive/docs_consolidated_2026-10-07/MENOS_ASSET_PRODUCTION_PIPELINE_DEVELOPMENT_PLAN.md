# MENOS Asset Production Pipeline Development Plan

> 작성일: 2026-10-06
> 상태: SPECIALIZED EXECUTION PLAN / CURRENT STATUS RECORDED
> 목적: 원본 아트부터 Catalog Editor, Visual Asset, Animation, Runtime까지의 Asset 제작·관리·검증 흐름을 하나의 명확한 파이프라인으로 정의한다.

## 1. 목적

Catalog Editor를 단독으로 모든 제작 문제를 해결하는 도구로 만들지 않고, MENOS Asset Production Pipeline의 핵심 제작·관리·검증 도구로 위치시킨다.

목표 흐름:

    MASTER CANON
        ↓
    Original Art / Source
        ↓
    Catalog Editor
        ├─ Image Processing
        ├─ Sprite Sheet / Frame
        ├─ Variant
        └─ Team Mask
        ↓
    Visual Asset
        ├─ Source / Variant
        ├─ Frame / Region
        ├─ Anchor
        └─ Team Mask
        ↓
    Animation / Game Editor
        ↓
    Runtime
        ├─ Animation Playback
        ├─ Team Color
        ├─ VFX / Hit Feedback
        └─ Gameplay

각 단계는 역할을 넘지 않는다.

## 2. 범위

### 포함

- Original Art에서 Runtime Asset까지의 역할 정의
- Catalog Editor의 위치와 책임
- Visual Asset 데이터 연결
- Sprite Sheet / Frame / Region / Anchor
- Variant 및 Team Mask
- Animation Editor/Runtime 연결
- Runtime Asset 소비 규칙
- Asset Validation
- Source → Result 추적성
- 제작/검증 단계별 완료 조건

### 제외

- 게임의 Team Color Canon 결정
- 신규 Runtime Shader 설계
- 전투 규칙 변경
- 대규모 신규 Asset 제작
- 원본 Asset 삭제/덮어쓰기
- SQLite 콘텐츠 타입 추가 전환
- Commit / Push
- 최종 아트 스타일 결정

## 3. 역할 분리

| 단계 | 책임 | 하지 않는 것 |
|---|---|---|
| Original Art | 캐릭터/무기/VFX 원본 제작 및 복잡한 아트 수정 | Runtime 데이터 정의 |
| Catalog Editor | 색상/Alpha/투명/Frame/Variant/Mask 제작·관리 | 게임플레이 규칙 |
| Visual Asset | Source/Frame/Anchor/Mask/Usage 연결 | 픽셀 편집 자체 |
| Animation | Frame 순서/재생 정의 | 원본 픽셀 수정 |
| Runtime | Animation 재생, Team Color, VFX, Gameplay 소비 | 원본 Asset 제작 |
| Content Data | Robot/Enemy/Tower 등의 게임 데이터 | 아트 픽셀 처리 |
| Validation | 경로/Region/Frame/Mask/참조 검증 | 임의 수정 |

## 4. Catalog Editor의 핵심 위치

Catalog Editor는 MENOS Asset Production Pipeline의 중앙 제작·정리·검증 도구로 취급한다.

핵심 책임:
1. Source Image 열기
2. 색상 샘플링
3. 배경 투명화
4. 색상 치환
5. Alpha 처리
6. Entire / Selected Frame / All Frames 처리
7. Sprite Sheet Frame Region 보존
8. Variant 생성
9. Team Mask 생성
10. Preview / Apply / Save
11. Visual Asset 연결
12. 저장 후 Validation

Catalog Editor는 Photoshop 대체품이 아니다.

## 5. Asset 상태 모델

    SOURCE
      │
      ├── VARIANT
      │
      └── TEAM MASK
              ↓
         VISUAL ASSET
              ↓
          ANIMATION
              ↓
           RUNTIME

원칙:
- SOURCE는 보존한다.
- VARIANT는 SOURCE와 Recipe로 추적 가능해야 한다.
- TEAM MASK는 SOURCE와 동일한 Frame 좌표 체계를 사용한다.
- VISUAL ASSET은 실제 파일과 Frame/Anchor/Mask를 연결한다.
- ANIMATION은 Visual Asset을 소비한다.
- RUNTIME은 최종 Asset을 소비한다.

## 6. Sprite Sheet 제작 규칙

Sprite Sheet는 단순 PNG가 아니라 다음 정보를 포함한 제작 단위로 취급한다.

- Source
- Frame count
- Frame regions
- Frame order
- Anchor
- Optional Team Mask
- Optional Variant

처리 범위:
- Entire Image
- Selected Frame
- All Frames

성공 조건:
- 선택하지 않은 Frame은 변경하지 않는다.
- Frame Region이 임의로 재계산되지 않는다.
- Anchor가 보존된다.
- Team Mask와 Source의 좌표가 일치한다.

## 7. Team Color 파이프라인

Team Color는 일반적인 색상 치환과 분리한다.

    Source Sprite Sheet
          ↓
    Team Mask Generation
          ↓
    Visual Asset.team_mask
          ↓
    Runtime Team Color

Catalog Editor 책임:
- Team Mask 생성
- Frame별 Mask 생성
- Mask/Source 크기 검증
- Frame 정합성 검증
- Visual Asset 연결

Runtime 책임:
- Mask를 이용한 실제 Team Color 적용
- 팀별 색상 선택/적용
- Animation 중 색상 유지

팀 색상 자체의 Canon은 Master가 결정한다.

## 8. Animation 연결

Animation 단계에서는 이미 정의된 Visual Asset을 소비한다.

    Visual Asset
      ↓
    Frame / Region / Anchor
      ↓
    Animation Definition
      ↓
    Animation Playback

Animation Editor가 담당할 수 있는 항목:
- Animation 이름
- Frame 순서
- Frame duration
- Loop 여부
- Animation 상태

Animation Editor가 원본 이미지 픽셀을 직접 수정하는 구조는 기본적으로 사용하지 않는다.

## 9. Runtime 연결

Runtime은 다음을 소비한다.
- Visual Asset
- Frame/Region
- Anchor
- Animation Definition
- Team Mask
- Gameplay Content Data

Runtime에서 수행한다.
- Animation 재생
- Team Color 적용
- VFX
- Hit/Damage feedback
- Gameplay state와 Animation 연결

Editor에서 Runtime 결과를 직접 확정하지 않는다.

PIE 결과는 Master 확인이 필요한 별도 검증 상태다.

## 10. Validation 경계

### Source → Catalog Editor
- 파일 존재
- 이미지 포맷
- 읽기 가능 여부

### Catalog Editor → Visual Asset
- Source 존재
- Variant 존재
- Region 유효성
- Frame count 일치
- Anchor 유효성
- Mask 존재

### Visual Asset → Animation
- Frame 참조 유효성
- Region 유효성
- Animation Frame 범위

### Animation → Runtime
- 실제 Runtime 경로 연결
- Animation 재생 가능 여부
- Team Mask 연결 가능 여부

검증 실패 시 자동으로 다음 단계로 진행하지 않는다.

## 11. 개발 Phase

### APP-0 — Pipeline Baseline
목적: 현재 Source / Catalog / Visual Asset / Animation / Runtime의 실제 연결 경로를 READ-ONLY로 확정한다.

성공 조건:
- 실제 파일/코드 경로가 확인된다.
- 기존 Asset ID/Region/Anchor를 보호할 수 있다.

검증:
- CODE VERIFIED
- EDITOR VERIFIED는 실제 Editor 확인 후 별도 판정

판정: PASS → STOP

### APP-1 — Catalog Editor Scope
목적: Entire / Selected Frame / All Frames를 공통 처리 모델로 확립한다.

의존: Catalog Editor 계획 CED-1, CED-2

성공 조건:
- Frame 외부 변경 없음
- 동일 처리 로직 재사용
- Source 보존

실행 결과: APP-1 COMPLETE
- Catalog Editor에 `Entire Image / Selected Frame / All Frames` Scope 모델을 추가했다.
- Background Remove / Color Replace / Team Alpha가 동일한 `_process_scoped_color_operation()` 경로를 사용한다.
- `frame_regions`가 있으면 기존 Region을 사용하고, 없으면 Columns / Rows / Frame Order로 계산한다.
- Selected Frame은 현재 Frame Index만 처리하고, All Frames는 각 Frame Region만 처리한다.
- 처리 Region은 실제 이미지 경계와 교차시켜 Frame 외부 변경을 차단한다.
- Source 파일 자체는 변경하지 않으며 현재 편집 Image에만 적용한다.
- Edge-connected 처리는 각 Scope Region 내부 경계 기준으로 수행한다.

검증:
- CODE VERIFIED — Godot 4.7.2 `--check-only --script res://editor/image_editor.gd` PASS
- `git diff --check` PASS

판정: PASS → STOP

### APP-2 — Variant / Team Mask
목적: 편집 결과를 Source와 분리하고 Team Mask를 별도 Asset으로 관리한다.

의존: CED-3, CED-4, CED-5

성공 조건:
- Source 불변
- Variant 추적 가능
- Mask/Source 정합성 확보

실행 결과: APP-2 CODE IMPLEMENTATION COMPLETE
- `Save Variant`를 추가했다. 기존 Visual Asset Source를 Reconnect하지 않고 `edited_assets`에 별도 PNG를 저장한다.
- Variant는 새 Visual Asset ID를 만들고 `variant_of`에 원본 Visual Asset ID를 기록한다.
- 기존 Region / Frame / Anchor metadata를 Variant에 복사하여 frame alignment를 유지한다.
- `Generate Team Mask`를 추가했다. 현재 편집 Image의 Alpha를 0..1 grayscale mask로 변환하여 별도 PNG로 저장한다.
- Team Mask는 `visual_assets.json`의 기존 `team_mask.source` 구조에 연결한다.
- 기존 Asura/Valkyrie profile mask 구조와 동일한 `team_mask.source` metadata를 재사용한다.
- 기존 Source/Asset ID/Region/Anchor를 삭제하거나 변경하는 경로는 추가하지 않았다.

검증:
- CODE VERIFIED — Godot 4.7.2 `--check-only --script res://editor/image_editor.gd` PASS
- `git diff --check` PASS
- EDITOR VERIFIED — NOT VERIFIED
- 실제 Variant 저장 및 Mask 생성은 아직 실행하지 않음

판정: PASS (CODE) → STOP

### APP-3 — Visual Asset Integration
목적: Catalog Editor 결과가 실제 Visual Asset 정의와 연결되도록 한다.

의존: CED-6

성공 조건:
- Asset ID
- Source/Variant
- Region
- Anchor
- Team Mask
가 서로 일관되게 연결된다.

### APP-4 — Animation Integration
목적: Animation이 Visual Asset을 소비하도록 연결한다.

성공 조건:
- Animation이 유효한 Visual Asset Frame만 참조한다.
- Frame/Anchor가 일관된다.

### APP-5 — Runtime Integration
목적: Runtime에서 Asset/Animation/Team Mask를 실제 소비하는 경로를 확인한다.

성공 조건:
- 코드 경로가 연결된다.
- Build가 필요한 경우 Build 검증을 통과한다.
- 실제 Runtime 동작은 Master PIE 확인 전까지 PIE VERIFIED로 선언하지 않는다.

### APP-6 — End-to-End Acceptance
최소 흐름:
1. Original Source 선택
2. Catalog Editor에서 편집
3. Variant 또는 Team Mask 생성
4. Visual Asset 연결
5. Animation 연결
6. Runtime Asset 소비
7. Validation
8. 필요 시 Master PIE 확인

성공하면 STOP한다.

## 12. 우선순위

### P0
- Source 보존
- Catalog Editor 편집 범위
- Frame/Region/Anchor 보존
- Variant/Mask 분리
- Visual Asset 연결
- 기본 Validation

### P1
- Animation 연결
- Runtime Asset 소비 경로
- Team Mask Runtime 적용
- Save/Reopen 검증
- End-to-End acceptance

### P2
- Recipe
- Source hash/stale detection
- Batch processing
- 다중 Mask
- 고급 Preview
- Asset dependency 검색

P2는 P0/P1 성공 후 실제 필요성이 확인될 때만 진행한다.

## 13. 안전성 규칙

변경 전:
- HEAD
- Branch
- Working Tree
- 관련 Source
- 관련 Visual Asset
- 관련 Animation
- 관련 Runtime 소비 경로

확인한다.

변경 후:
- Diff
- 파일 존재
- Asset ID
- Region
- Anchor
- Mask 정합성
- 최소 기능 검증

확인한다.

다음은 Master 승인 없이 수행하지 않는다.
- 원본 삭제
- 원본 덮어쓰기
- Asset ID 변경
- 대규모 Asset 변환
- 외부 Asset 추가
- Canon 변경
- Commit / Push

## 14. 검증 상태

- CODE VERIFIED — 코드 경로 확인
- EDITOR VERIFIED — 실제 Editor에서 Asset/설정 확인
- BUILD VERIFIED — 실제 Build 성공
- PIE VERIFIED — Master가 실제 Runtime 결과 확인
- NOT VERIFIED — 아직 확인하지 않음

Headless 검사만으로 PIE VERIFIED를 선언하지 않는다.

## 15. 현재 프로젝트와의 관계

상위 Pipeline 계획:

    MENOS Asset Production Pipeline
            │
            └── Catalog Editor Development Plan
                    │
                    ├── CED-1 Scope
                    ├── CED-2 Processing
                    ├── CED-3 Preview/Save
                    ├── CED-4 Variant
                    ├── CED-5 Team Mask
                    ├── CED-6 Visual Asset
                    ├── CED-7 Validation
                    ├── CED-8 Recipe
                    └── CED-9 Stability

따라서 기존 MENOS_CATALOG_EDITOR_DEVELOPMENT_PLAN.md를 대체하지 않는다.

본 문서는 그 계획의 상위 파이프라인 역할과 Animation/Runtime 연결 경계를 정의한다.

## 16. 현재 상태

APP-6 HOLD / CODE VERIFIED / EDITOR VERIFIED PARTIAL / PIE VERIFIED PARTIAL

APP-6 E2E 검증 결과:
- 실제 Godot Editor 실행 확인.
- 실제 Content Editor → Asset Catalog 진입 확인.
- 실제 Catalog Editor에서 등록 Asset 선택 및 Sprite Sheet Preview 확인.
- 실제 Main Project PIE 진입 확인.
- 실제 Stage 1 전투 진입 및 Wave/HP/Gold/Combat Log 변화 확인.
- 따라서 Editor/PIE 실행 경로 자체는 확인되었으나 전체 Acceptance를 의미하지 않는다.
- Catalog Save/Reopen은 미검증.
- 실제 Animation Sprite 시각 재생은 미검증.
- 실제 PIE에서 Valkyrie Team Mask 색상 적용은 미검증.

Team Mask 최종 확인:
- `robot.valkyrie.profile` Visual Asset에 `team_mask.source`가 실제로 연결되어 있음을 확인했다.
- 연결 파일 `res://images/robot/valkyrie/profile_team_mask.png`가 실제 존재함을 확인했다.
- 이전 기록의 "Team Mask 연결 데이터 없음" 판정은 잘못된 조사 결과이며 본 문서에서 정정한다.
- Catalog Editor의 `Generate Team Mask` 코드 경로도 존재하며 기존 `team_mask.source` 구조를 재사용한다.

APP-5 구현:
- Runtime이 VisualAsset Team Mask 정보를 일반 경로로 소비하도록 일반화했다.
- 기존 Shader 인터페이스는 유지한다.
- Mask가 없거나 정합성이 맞지 않는 경우 임의 전체 Tint를 적용하지 않는다.

검증:
- CODE VERIFIED — Image Editor / Content Validator / Game Controller 관련 check 통과.
- EDITOR VERIFIED — Catalog Editor 진입, Asset 선택, Preview 확인.
- PIE VERIFIED — Main Project 진입 및 실제 전투 진행 확인.
- Animation 시각 검증 및 Team Color 시각 검증은 NOT VERIFIED.

판정:
- APP-0 ~ APP-5: 목적 범위 내 구현 및 코드 검증 완료.
- APP-6: HOLD. 핵심 Runtime Team Color/Animation 시각 검증이 남아 있으므로 전체 Acceptance PASS로 승격하지 않는다.
- 추가 기능 개발은 하지 않고 현재 범위에서 종료한다.

APP-5 구현과 검증 경계를 완료했다.
- Runtime이 VisualAsset.team_mask_source를 직접 소비하도록 일반화했다.
- 기존 Asura 전용 하드코딩 Team Mask 경로를 제거했다.
- Source 전체 크기 Mask, Frame 크기 Mask, Visual Asset Region 크기 Mask를 각각 지원한다.
- Frame Region은 VisualAssetFrame.region_for()를 사용한다.
- 기존 Shader의 team_color / team_mask / use_team_mask 인터페이스는 유지했다.
- Team Mask가 없거나 해상도가 맞지 않으면 전체 Sprite에 임의 Tint를 적용하지 않는다.

검증:
- CODE VERIFIED — Godot 4.7.2 game_controller.gd --check-only PASS
- git diff --check PASS
- 실제 Editor/Runtime 실행은 하지 않았으므로 EDITOR VERIFIED와 PIE VERIFIED는 미확인이다.


APP-4 구현과 검증 경계를 완료했다.
- 기존 Animation 구조는 유지한다. AnimationPlayer를 새로 도입하지 않는다.
- Robot Editor와 Runtime은 VisualAssetFrame.region_for()를 통해 Visual Asset의 explicit Frame Region을 우선 사용하고, 없을 경우 Grid metadata를 fallback으로 사용한다.
- Frame별 Anchor가 있으면 Animation Preview에서도 해당 Anchor를 사용할 수 있는 기존 경로를 유지한다.
- Content Validator가 Robot animation ID와 Visual Asset ID의 참조를 검사한다.
- Allied Unit projectile animation의 Visual Asset ID 참조도 검사한다.
- Runtime의 직접 Frame 소비 구조는 변경하지 않았다.

검증:
- CODE VERIFIED — Godot 4.7.2 content_validator.gd --check-only PASS
- CODE VERIFIED — Godot 4.7.2 robot_editor.gd --check-only PASS
- git diff --check PASS
- 실제 Editor animation preview 실행은 하지 않았으므로 EDITOR VERIFIED는 미확인이다.


APP-3 구현과 검증 경계를 완료했다.
- Visual Asset Repository/Resolver가 Asset ID를 기준으로 Source, Region, Frame, Anchor, Team Mask metadata를 재구성한다.
- Content Validator가 Visual Asset Source 존재/Texture 여부를 검사한다.
- 선언된 전체 Region과 각 Frame Region이 Source 이미지 범위 안에 있는지 검사한다.
- Team Mask가 지정된 경우 Source와 Mask의 존재 및 해상도 정합성을 검사한다.
- 기존 Runtime의 VisualAssetResolver 소비 경로는 유지하며 Runtime 일반화는 APP-5 범위로 남긴다.

검증:
- CODE VERIFIED — Godot 4.7.2 content_validator.gd --check-only PASS
- CODE VERIFIED — Godot 4.7.2 image_editor.gd --check-only PASS
- git diff --check PASS
- 실제 Editor UI에서 Catalog 재오픈/저장까지는 실행하지 않았으므로 EDITOR VERIFIED는 미확인이다.



확인된 핵심 경계:
- Catalog Editor → Visual Asset 연결은 실제 구현되어 있다.
- Visual Asset은 JSON 카탈로그로 관리되며 Frame/Region/Anchor/Team Mask 메타데이터를 가진다.
- Robot/Enemy/Tower Runtime은 Visual Asset ID를 일부 해석하여 Source/Region/Frame을 소비한다.
- Robot Runtime의 Team Mask 적용은 APP-5에서 Visual Asset 기반 일반 경로로 일반화되었다. 위의 Asura 전용 경로 언급은 APP-5 이전 조사 기록이다.
- Animation은 별도 AnimationPlayer 기반 시스템이 아니라 Catalog의 animation ID와 Frame Region을 Runtime에서 직접 소비하는 구조가 확인되었다.

현재 다음 실제 실행 대상은 없다. APP-6은 최종 시각 검증 일부가 남아 있어 HOLD 상태로 종료한다.

## 17. 기준선 / 종료 기록

- Project: MENOS
- Branch: main
- Baseline HEAD: `be074c5db35b7c4d548a24cf448b404463e5fe6d`
- Godot: 4.7.2.stable.official.ed1daf0bf
- Project root: `D:\Atlas\projects\menos\godot`
- 2026-10-06 작업 종료 시점에 기존 Working Tree 변경사항을 보존한다.
- 이번 작업에서 생성/수정한 개발계획 문서와 MENOS 관련 코드 변경만 구분하여 Commit/Push한다.
- 미확인 TMP/캡처/기존 Asset 변경은 Commit 대상에서 제외한다.
