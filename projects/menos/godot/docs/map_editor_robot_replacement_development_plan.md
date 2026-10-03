# Map Editor 로봇 교체 기능 개발계획
## 1. 목적
기존 Map Editor에서 map_01의 Robot Position Point를 선택하고 Robot Catalog의 Robot Definition으로 교체할 수 있도록 확장한다.
목표 흐름:
Map Editor → map_01 → Robot Position Point 선택 → Robot 선택 → Valkyrie 선택 → Apply → Save → Runtime 확인
이번 단계에서는 기존 Map 구조와 Robot Editor/Visual Asset 구조를 최대한 보존한다.
## 2. 범위
포함:
- Map Editor Gameplay UI 확장
- Robot Catalog 연동
- Robot Position Point와 Robot Definition 연결
- map_01 저장/로드 호환
- legacy robot_spots 호환
- Valkyrie 선택/적용
- 최소 자동 검증 및 데이터 검증
제외:
- Robot Editor 변경
- Visual Asset 구조 변경
- 이미지/애니메이션 제작
- Runtime 전투 시스템 전체 개편
- 대규모 JSON migration
- Commit/Push
## 3. 현재 조사 결과
CONFIRMED — Map Editor에는 Robot Position Point 생성/선택/이동/삭제가 있다.
CONFIRMED — Gameplay Properties는 ID, 이름, 위치, enabled, area 등을 편집한다.
CONFIRMED — Robot Definition을 선택하는 UI/필드가 없다.
CONFIRMED — Asset Catalog는 일반 Map Asset Catalog이며 Robot Catalog 선택 기능이 없다.
CONFIRMED — content/maps/map_01.json에는 gameplay_points의 robot_position_point가 있다.
CONFIRMED — 해당 point는 type=robot_position_point, position=[1008,378]이다.
CONFIRMED — map_loader.gd는 legacy robot_spots를 위치 Vector2 Dictionary로 변환한다.
CONFIRMED — map_loader.gd에서 robot_spots의 Robot ID/Definition 소비는 확인되지 않았다.
UNVERIFIED — Runtime에서 robot_position_point/robot_spots가 실제 Robot 생성에 사용되는 최종 경로는 아직 확인되지 않았다.
## 4. 현재 데이터 구조
현재 map_01에는 두 표현이 공존한다.
1. legacy robot_spots
2. gameplay_points의 robot_position_point
legacy 예:
{
  "robot_spots": {
    "LEFT": [480,300],
    "CENTER": [720,250],
    "RIGHT": [480,540]
  }
}
현재 Map Editor가 직접 편집하는 것은 gameplay_points의 Robot Position Point다.
따라서 legacy robot_spots를 즉시 제거하지 않고 Editor가 관리하는 Point에 Robot Definition 참조를 추가하는 방향을 제안한다.
## 5. 권장 데이터 계약
Robot Position Point를 위치점에서 Robot Spawn Definition으로 확장한다.
예상:
{
  "id": "gameplay.robot_position_point.northbridge",
  "name": "Valkyrie Spawn",
  "position": [1008,378],
  "type": "robot_position_point",
  "enabled": true,
  "robot_id": "valkyrie"
}
robot_id는 Robot Catalog의 stable ID를 참조한다.
Map JSON에 Robot Definition 자체를 복사하지 않는다.
의존 관계:
Map → robot_id → content/robots/robots.json → animations → Visual Asset ID → visual_assets.json
## 6. ID 정책
Valkyrie의 현재 Robot ID는 valkyrie다.
Map은 robot.valkyrie.idle 같은 Visual Asset ID를 직접 저장하지 않는다.
Map은 Robot Definition만 참조한다.
따라서 Robot Editor에서 Valkyrie 이미지/애니메이션을 교체해도 map_01을 수정할 필요가 없다.
## 7. Map Editor UI 변경안
기존 Gameplay Properties를 유지하고 Robot Position Point 선택 시에만 Robot Properties를 추가한다.
예상:
GAMEPLAY
  Robot Position Point
    ID
    Name
    Position
    Enabled
    Robot
      [ Valkyrie ▼ ]
    [Apply]
    [Delete]
Robot Position Point가 아닌 Gameplay Area/Point에는 Robot selector를 표시하지 않는다.
Robot 목록은 Robot Catalog에서 읽는다.
display_name과 ID를 함께 보여주고 검색 가능한 목록을 권장한다.
## 8. Robot Catalog 연동
Map Editor가 content/robots/robots.json을 읽는 최소 Loader/Resolver를 사용한다.
향후 공통 Catalog Browser 재사용은 가능하지만 이번 구현에서 Image Editor의 Visual Asset Browser와 Robot Definition Catalog를 혼합하지 않는다.
구분:
Robot Catalog = 어떤 로봇인가
Visual Asset Catalog = 어떤 이미지/영역인가
Map Editor = Robot Catalog만 선택
## 9. 적용 동작
Robot Position Point 선택 시 현재 robot_id를 읽는다.
Robot 목록에서 Valkyrie를 선택하고 Apply하면 해당 point에 robot_id=valkyrie를 기록한다.
Apply 전에는 map_data를 변경하지 않는다.
Apply 성공 시 기존 undo snapshot 정책을 사용한다.
Save 시 기존 map_loader 저장 포맷을 통해 JSON에 기록한다.
## 10. 기존 데이터 호환
robot_id가 없는 기존 Robot Position Point는 legacy point로 유지한다.
허용 상태:
- robot_id 없음 = legacy
- robot_id 존재 = 명시적 Robot Definition
기존 map_01에 임의의 기본 Robot을 자동 입력하지 않는다.
기본 Robot 결정은 Runtime/게임 설계 판단이므로 결정 전 HOLD한다.
legacy robot_spots도 즉시 삭제하지 않는다.
## 11. 사용자 작업 흐름
1. Map Editor에서 map_01을 연다.
2. GAMEPLAY → SELECT를 선택한다.
3. Robot Position Point를 클릭한다.
4. Inspector에서 Robot을 연다.
5. Robot Catalog에서 Valkyrie를 선택한다.
6. Apply를 누른다.
7. Save Map을 수행한다.
8. 저장된 map_01에서 robot_id=valkyrie를 확인한다.
9. Runtime에서 해당 위치에 Valkyrie가 생성되는지 확인한다.
## 12. 구현 단계
Phase 0 — Runtime 소비 경로 확인
- map_loader.gd 이후 map_data 소비 코드 조사
- Robot spawn/placement 코드 조사
- map_01 로딩 경로 확인
- 기존 Robot ID API 확인
성공 조건: Robot Position Point → Runtime Robot 생성 경로를 설명할 수 있음.
이 단계가 확인되지 않으면 구현을 진행하지 않는다.
### Phase 1 — 데이터 계약
- robot_id optional field 정의
- Robot ID validation 정의
- 기존 JSON 보존 확인
- save/load round-trip 검증 추가
성공 조건: robot_id가 추가된 map JSON을 안전하게 읽고 저장한다.
### Phase 2 — Map Editor UI
- Robot Position Point 선택 시 Robot selector 표시
- robots.json 기반 목록
- 현재 robot_id 표시
- Apply/Cancel
성공 조건: Editor에서 Valkyrie 선택 후 map_data에 robot_id가 기록된다.
### Phase 3 — Save/Load
- map_loader 저장 경로에 robot_id 보존
- 재로드 후 선택 상태 복원
성공 조건: 저장 → 재로드 → Valkyrie 선택 상태 유지.
### Phase 4 — Runtime
- map_01 로드
- 해당 Robot Position Point 확인
- Valkyrie Definition 로드
- Visual Asset 연결
- PIE에서 실제 생성 확인
성공 조건: PIE VERIFIED.
## 13. 검증 기준
CODE VERIFIED — loader/editor/data contract 코드 경로 확인.
BUILD VERIFIED — Godot build 성공.
EDITOR VERIFIED — selector 표시, Valkyrie 선택, 저장 확인.
PIE VERIFIED — 실제 map_01 Runtime에서 Valkyrie 생성 확인.
자동화 테스트 PASS는 PIE VERIFIED로 승격하지 않는다.
## 14. 안전성
작업 시작 전 HEAD, Branch, Working Tree 확인.
기존 map_01 변경사항 보존.
legacy robot_spots 삭제 금지.
대규모 map JSON migration 금지.
변경 후 git diff 및 JSON 구조 확인.
의도하지 않은 map/tile/asset 변경 발견 시 즉시 중단.
## 15. 결정이 필요한 사항
핵심 결정:
A안 — Robot Position Point가 특정 Robot 1개의 Spawn Definition을 의미한다.
B안 — Robot Position Point는 단순 위치점이고 실제 Robot 선택은 별도 Spawn/Unit 배치 데이터가 담당한다.
현재 Editor 구조만 보면 A안 구현이 자연스럽지만 Runtime 소비 경로 확인 전에는 Canon으로 확정하지 않는다.
추가 결정:
- robot_id 기본값을 둘 것인지
- 한 Point에 1개 Robot만 허용할지
- 여러 Robot을 같은 위치에 Spawn할 수 있는지
- Robot Catalog UI를 공통 Browser로 만들 시점
- legacy robot_spots를 장기적으로 제거할지
## 16. 현재 판정
STATUS — HOLD
목적: 개발계획 문서화 및 결정 전 조사.
조사 결과: Map Editor에는 Robot Definition 교체 기능이 없으며 Robot Position Point는 위치 정보 중심으로 구현되어 있다.
다음 구현 단계는 Runtime에서 robot_position_point/robot_spots의 실제 소비 경로를 확인하는 것이다.
이 확인 없이 robot_id의 의미를 Canon으로 확정하지 않는다.
## 17. 종료 조건
Phase 0에서 Runtime 소비 경로를 확인하고 데이터 계약을 확정할 수 있으면 Phase 1 이후 구현으로 진행한다.
핵심 의미가 확인되지 않거나 새로운 설계 판단이 필요하면 HOLD 후 Master에게 보고한다.
목적 달성 후 다른 Editor 기능이나 Catalog migration을 자동으로 시작하지 않는다.
## 18. Phase 0 추가 조사 결과
CONFIRMED — game_controller.gd의 apply_map_spatial_data()는 gameplay_points에서 type=robot_position_point를 찾아 ROBOT_SPOTS에 위치로 등록한다.
CONFIRMED — point의 현재 처리 코드는 id와 position만 ROBOT_SPOTS에 기록하며 robot_id는 읽지 않는다.
CONFIRMED — gameplay_points가 존재하면 legacy robot_spots는 fallback으로만 사용된다.
CONFIRMED — 따라서 현재 Runtime 데이터 경로에는 Robot Definition 선택 정보가 없다.
CONFIRMED — game_controller.gd는 현재 robots.json에서 robot_main 단일 항목을 로드하고 RobotDefinition을 생성한다.
CONFIRMED — 현재 Runtime의 기본 Robot은 robot_main catalog entry를 사용한다.
INFERENCE — map_01의 Robot Position Point는 현재 "어떤 Robot을 생성할지"보다 "기본 Robot이 사용할 위치"를 제공하는 구조에 가깝다.
INFERENCE — Map Editor에서 Valkyrie를 선택하려면 Map 데이터뿐 아니라 Runtime의 Robot Definition 선택 경로도 함께 확장해야 한다.
## 19. Phase 0 판정
STATUS — HOLD
현재까지 확인된 경로:
map_01 → gameplay_points.robot_position_point → game_controller.apply_map_spatial_data() → ROBOT_SPOTS[position]
동시에 Runtime Robot Definition은 별도의 robot_main catalog entry에서 로드된다.
따라서 단순히 Map Editor UI에 robot_id를 추가하는 것만으로는 Valkyrie 교체가 완성되지 않는다.
필요한 최소 설계 변경은:
Map robot_id → Runtime RobotDefinition 선택 → 해당 Robot의 Visual/Weapon/Combat Definition 구성
이다.
여기서 "Robot Position Point마다 Robot을 지정한다"는 의미를 Canon으로 확정할지, 또는 별도의 Robot Spawn/Unit 배치 데이터로 분리할지는 Master 결정이 필요하다.
이 결정 전에는 코드 수정으로 진행하지 않는다.
