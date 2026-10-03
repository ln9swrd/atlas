# MENOS Animation Frame Alignment Development Plan

## 1. 목적
발키리와 향후 모든 캐릭터의 애니메이션에서 프레임마다 스프라이트의 실제 크기와 중심이 달라도 게임 화면에서 캐릭터가 불필요하게 튀거나 흔들리지 않도록 한다.

모든 프레임을 동일한 외형 크기로 강제하는 것이 목적이 아니다.
- 원본 스프라이트의 자연스러운 크기 차이는 허용한다.
- 프레임마다 발생하는 투명 여백 차이와 실제 캐릭터 위치 차이를 처리한다.
- Editor Preview와 Runtime이 동일한 정렬 규칙을 사용한다.
- Visual Asset ID를 기준으로 source / region / frames를 해석한다.
- 기존 Asset을 임의로 재가공하거나 덮어쓰지 않는다.

## 2. 현재 상태
### CONFIRMED
Robot Editor Animation Preview는 Visual Asset Resolver를 거쳐 source + region + frames를 얻은 뒤 frame 영역을 균등 분할하고 AtlasTexture로 표시한다. 프레임 내부의 실제 opaque pixel bounds나 gameplay anchor 보정은 없다.
Runtime도 Sprite2D의 hframes/vframes로 프레임을 분할하고 전체 frame size에 따라 scale을 적용한다. 프레임별 실제 캐릭터 중심은 보정하지 않는다.
따라서 Preview에서 관찰되는 frame-to-frame 위치 흔들림이 Runtime에서도 발생할 수 있는 구조다.

### 별도 확인이 필요한 문제
Runtime 일부 경로는 VisualAssetResolver를 거치지 않고 catalog field를 직접 load한다. 또한 Robot Runtime에는 animation frame count가 코드에 하드코딩된 부분이 있다.
이는 Frame Alignment 구현과 함께 검토하되, 이번 계획의 핵심은 정렬 기준과 공통 처리 계층을 정의하는 것이다.

## 3. 범위
### IN SCOPE
1. Visual Asset animation frame 추출 규칙 통일
2. frame별 실제 이미지 bounds 분석
3. 공통 animation anchor/pivot 개념 도입
4. baseline / anchor 기준 프레임 정렬
5. Editor Preview와 Runtime의 공통 frame presentation 데이터 사용
6. 발키리 전체 animation 검증
7. 다른 로봇에도 적용 가능한 구조 확보

### OUT OF SCOPE
- 캐릭터 원본 이미지 재생성
- 원본 PNG 픽셀 수정
- 임의 Sprite Atlas 재생성
- 모든 캐릭터를 동일한 외형 크기로 강제
- gameplay balance 변경
- 이동 속도/공격 판정/충돌 영역 변경
- 새로운 캐릭터 제작

## 4. 설계 원칙
### 4.1 Visual Asset이 단일 진입점
Animation은 asset_id, source, region, frames에서 시작한다. 경로 문자열 직접 해석은 Legacy compatibility 용도로만 유지한다.

### 4.2 Frame과 Character Bounds를 분리
Animation frame의 전체 사각형과 실제 캐릭터가 차지하는 영역은 서로 다른 개념으로 취급한다.
예: Frame Rect 117x176, Character Bounds 93x168. Runtime frame texture는 Frame Rect를 유지하되 alignment 계산에는 Character Bounds를 사용한다.

### 4.3 Anchor를 기준으로 정렬
기본 기준은 캐릭터의 gameplay pivot이다.
우선순위:
1. 명시적인 Asset anchor
2. animation 공통 anchor
3. 자동 분석된 baseline / center
4. legacy fallback

bounding-box center를 자동으로 gameplay anchor로 확정하지 않는다. 공격/이동 동작에서 bounding box가 움직일 수 있기 때문이다.
로봇은 우선 발/지면 접점에 해당하는 anchor를 검토한다.

### 4.4 Preview와 Runtime은 같은 계산을 사용
정렬 계산을 Editor에 별도로 구현하지 않는다. 공통 resolver/presentation layer가 source texture, frame region, frame index, frame count, character bounds, anchor, normalized frame offset, normalized scale/presentation data를 반환하고 Editor와 Runtime이 이를 소비한다.

## 5. 권장 데이터 구조
Visual Asset 또는 별도 animation metadata에 최소 alignment 정보를 정의한다.

예시:
    {
      "id": "robot.valkyrie.idle",
      "source": "res://...",
      "region": [122, 10, 936, 176],
      "frames": 8,
      "alignment": {
        "mode": "anchor",
        "anchor": [58.0, 174.0],
        "baseline": 174.0
      }
    }

위 anchor 값은 예시이며 Canon이 아니다. 실제 값은 분석 후 결정한다.
가능하면 frame별 값을 직접 저장하기보다 animation-level 공통 anchor를 우선한다.
실제로 frame별 예외가 필요한 경우에만 frame_offsets를 추가한다.

## 6. 처리 파이프라인
### Phase A — 분석
READ-ONLY.
1. 발키리 모든 animation asset resolve
2. 각 frame 실제 pixel bounds 추출
3. 각 frame의 bounds 크기/중심 계산
4. 발 위치 또는 적절한 공통 anchor 후보 계산
5. 현재 Preview와 차이 기록
6. Runtime frame count 및 source region과 대조

성공 조건: 각 animation의 실제 frame 구조가 설명 가능하고 잘못된 frame count/region은 별도 데이터 문제로 기록한다.

### Phase B — 공통 Frame Presentation API
개념적으로 Visual Asset -> Animation Frame Set -> Animation Frame Presentation 계층을 만든다.
Presentation은 frame texture/region, frame size, opaque bounds, anchor position, display offset, display scale을 제공한다.
Editor와 Runtime 모두 이 계층을 사용한다.

### Phase C — Anchor 계산
1. frame region 추출
2. alpha 기준 실제 opaque bounds 추출
3. anchor 후보 계산
4. animation 전체 frame의 anchor 분포 분석
5. 공통 anchor 선택
6. 각 frame의 presentation offset 계산

무기/이펙트가 anchor 계산을 오염시키는 경우 별도 기준이 필요하다. 필요하면 Asset authoring 단계에서 명시 anchor를 지정한다.

### Phase D — Editor Preview 적용
현재 robot_editor.gd의 단순 AtlasTexture 분할을 공통 presentation 결과 사용으로 교체한다.
Preview는 동일 frame source, frame index, anchor, display offset을 사용한다.

### Phase E — Runtime 적용
Runtime robot sprite 생성/갱신도 동일 presentation 결과를 사용한다.
특히 runtime 하드코딩 animation frame count, Visual Asset ID 직접 texture load, frame마다 동일하다고 가정한 scale 계산을 제거 또는 격리 대상으로 조사한다.
Runtime은 Asset Catalog의 frames와 presentation metadata를 authoritative source로 사용한다.

## 7. 발키리 적용 순서
1. idle
2. move
3. attack
4. hit
5. death
6. projectile
7. skill1
8. skill2
9. skill3
10. special
11. finisher

idle/move/attack부터 anchor 품질을 검증하고 동일 규칙이 성립하면 나머지 animation에 확대 적용한다.

## 8. 검증 기준
### CODE VERIFIED
- 모든 animation이 공통 presentation layer를 통과
- frame count가 Asset metadata와 일치
- Preview와 Runtime이 동일 계산을 사용

### EDITOR VERIFIED
- 발키리 모든 animation의 frame extraction 확인
- frame별 anchor/bounds 확인
- Preview에서 불필요한 위치 튐 감소 확인

### BUILD VERIFIED
- Godot project build 성공
- parser/runtime errors 없음

### PIE VERIFIED
Master가 실제 게임에서 확인한다.
최소 확인 항목: idle loop, move loop, attack transition, skill transition, hit/death, animation 전환 시 위치 튐, 바닥 접점 안정성, 팀 색상 shader 적용 후 정렬 변화 없음.
자동화 검증 PASS는 PIE VERIFIED로 간주하지 않는다.

## 9. 검증용 수치 기준
각 animation에 대해 anchor X/Y drift, opaque bounds width/height 변화, frame-to-frame display offset을 기록한다.
허용 오차는 실제 발키리 기준점을 확인한 뒤 결정한다. 임의의 숫자를 Canon으로 지정하지 않는다.

## 10. 변경 안전성
구현 시작 전 HEAD, Branch, Working Tree, 기존 변경사항을 확인한다.
기존 변경사항을 보존한다.
구현 중 한 번에 하나의 변수만 변경하고 Diff를 확인한다. Asset 원본 덮어쓰기와 외부 Asset 추가는 금지한다.
검증 결과가 예상과 다르면 즉시 HOLD한다.

## 11. 단계별 종료 조건
Phase A: 모든 발키리 frame 구조와 anchor 후보를 설명할 수 있음.
Phase B: Preview와 Runtime이 동일 presentation API를 사용함.
Phase C: 발키리 anchor가 실제 gameplay 기준으로 안정적임.
Phase D/E: Preview와 Runtime에서 동일한 정렬 결과가 관찰됨.
목적 달성 후 추가 리팩터링은 자동 진행하지 않는다.

## 12. 리스크
### R1. 캐릭터가 아닌 무기가 bounds에 포함
명시 anchor를 우선하고 필요하면 authoring metadata에서 character anchor를 정의한다.

### R2. 애니메이션마다 기준점이 다름
animation-level anchor를 허용하고 공통 robot pivot과 animation offset을 분리한다.

### R3. 원본 프레임 자체의 제작 오류
alignment layer로 해결 가능한 문제와 Asset 재제작이 필요한 문제를 분리한다. 원본 수정은 별도 승인한다.

### R4. Editor와 Runtime 구현이 다시 분기
공통 presentation layer를 단일 source of truth로 사용한다.

### R5. Legacy asset과 Visual Asset 혼용
resolver compatibility를 유지하고 신규 경로는 Visual Asset ID 우선, Legacy는 명시적인 fallback으로 격리한다.

## 13. 구현 승인 전 결정이 필요한 사항
Master 결정이 필요한 항목은 기본 gameplay anchor 정의다.
검토 후보:
A. 발/지면 접점
B. 캐릭터 몸체 중심
C. Asset별 명시 pivot
D. 기존 Runtime 좌표계를 유지하면서 Asset별 offset만 추가

이 결정 전에는 실제 anchor 값을 Canon으로 확정하지 않는다.

## 14. 최종 판정 기준
- 프레임별 자연스러운 크기 차이는 유지된다.
- 캐릭터가 불필요하게 좌우/상하로 튀지 않는다.
- Preview와 Runtime의 위치가 일치한다.
- Visual Asset metadata가 frame 정보를 authoritative하게 제공한다.
- Runtime의 하드코딩 frame count 의존이 제거 또는 격리된다.
- 원본 Asset은 변경하지 않는다.

## 15. 현재 상태
STATUS: HOLD
계획/설계 단계다.
변경 없음. 원본 Asset 변경 없음. Canon anchor 미확정. 구현 미착수.
다음 단계는 Master가 anchor 기준을 결정한 후 Phase A 분석부터 시작한다.
## Phase A 조사 결과 — 2026-10-04

- **CONFIRMED:** Valkyrie 원본 스프라이트 시트의 실제 이미지 크기는 1536x1024이다.
- **CONFIRMED:** 현재 Visual Asset Catalog의 프레임 수는 idle 8, move 8, attack 8, hit 4, death 8, projectile 6, skill1 8, skill2 10, skill3 12, special 14, finisher 18이다.
- **CONFIRMED:** 프레임별 Alpha Bounds 분석 결과 X축 중심 이동은 모든 조사 애니메이션에서 0px로 측정되었다.
- **CONFIRMED:** Y축 Alpha Bounds 중심 이동 범위는 idle 3px, move 4px, attack 6.5px, hit 0px, death 6.5px, projectile 0px, skill1 0px, skill2 0px, skill3 0px, special 0px, finisher 5px이다.
- **INFERENCE:** 현재 어색함의 주요 후보는 프레임 자체의 X 위치 문제가 아니라, 일부 포즈에서 캐릭터의 실제 불투명 영역이 프레임 중앙에서 Y축으로 이동하는 현상이다.
- **CONFIRMED:** Editor Preview는 Visual Asset의 region/frames를 사용하지만 프레임별 Body Center 보정은 하지 않는다.
- **CONFIRMED:** Runtime은 game_controller.gd에서 catalog 값을 직접 load()하고, robot animation frame count를 6/7/5/5로 하드코딩한다.
- **CONFIRMED:** Valkyrie의 catalog 값은 Visual Asset ID이므로 현재 Runtime의 직접 load() 방식과 데이터 의미가 일치하지 않는다.
- **PROPOSAL:** Body Center 기준을 유지하되, Alpha Bounds 중심을 최종 Canon으로 자동 채택하지 않는다. 공통 Presentation 계층에서 프레임의 Body Center 보정값을 계산/적용할 수 있도록 하고, 실제 Body Center 값은 핵심 동작 프레임 분석 후 확정한다.
- **다음 판단 지점:** Body Center를 공통 기준점 1개로 정의할지, 애니메이션별 공통 기준점을 허용할지 결정이 필요하다. 구현 전 이 결정이 필요하다.
