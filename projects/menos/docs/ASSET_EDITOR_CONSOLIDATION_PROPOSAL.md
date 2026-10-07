## ASSET EDITOR / MAP ASSET CATALOG — CONSOLIDATION AND RESPONSIBILITY REQUIREMENTS (2026-10-07)

### Purpose
Image Editor와 Asset Catalog Editor는 기능 중복을 줄이고 하나의 Asset Editor 체계로 통합하는 방향을 권고한다.

### Responsibility
Asset Editor는 이미지 및 Map 배치 리소스의 Authoring/Management를 담당한다. Map Editor는 Map Asset을 선택하여 실제 Map에 배치한다. Robot/Unit/Tower/Building Gameplay Definition은 각 전용 Editor가 소유한다.

### Resource Hierarchy
Source Image → Visual Asset → Map Asset → Map Placement

Source Image는 원본, Visual Asset은 시각 리소스, Map Asset은 Map에서 배치 가능한 리소스 정의이다.

### Image 기능
Source 등록, Crop/Flip/Rotate/Trim, Background/Alpha 처리, Region, Sprite Sheet, Frame, Anchor, Visual Asset, Preview, Validation을 통합 Asset Editor에서 유지한다.

### Map Asset 기능
Tile/Object, Group, Display Name, Asset ID, Visual Asset Reference, Footprint, Layer, Grid Snap, Rotation/Flip 정책, Occupancy/Placement Rule을 통합 Asset Editor에서 관리한다.

### Data Separation
Image/Visual Asset에는 Source, Region, Frame/Grid, Anchor, Variant/Mask 등 시각 리소스 정보를 둔다. Map Asset에는 Kind, Group, Visual Asset Reference, Footprint, Layer, Placement Rule, Snap Rule, Occupancy Rule을 둔다.

### Map Editor Contract
Map Editor는 이미지 원본이나 파일 경로를 직접 관리하지 않고 Map Asset ID를 참조하여 배치 결과를 Map 데이터로 저장한다.

### Gameplay Boundary
Asset Editor는 Robot/Unit/Tower/Building의 Gameplay Definition을 중복 정의하지 않는다. Damage, Runtime Function 등은 각 전용 Editor의 책임이다.

### Identity / Reuse
Visual Asset ID와 Map Asset ID를 분리한다. 하나의 Visual Asset은 여러 Map Asset에서 재사용할 수 있어야 하며 Map별 배치 규칙은 Map Asset이 소유한다.

### Reference Safety
Visual Asset 또는 Map Asset 변경/삭제 전 사용처를 검사한다. Map Asset 삭제로 기존 Map 배치 데이터가 깨지지 않도록 보호한다. Visual Asset 교체와 Map Asset 의미 변경을 구분한다.

### UI Structure
하나의 Asset Editor 안에서 Source/Images, Visual Assets, Map Assets, Usage/References, Validation 영역을 제공하는 방향을 권고한다. 탭/모드/Split View 등 구현 방식은 후속 설계에서 결정한다.

### Migration
기존 두 Editor의 데이터를 통합 Asset Editor가 읽을 수 있는 Migration 경로를 마련하고 기존 참조를 임의로 변경하지 않는다.

### Production Gate
SQLite Save → Reload → Reference Verify를 Asset Authoring Gate로 사용한다.

### Validation
Missing Source, Missing Visual Asset, Missing Map Asset, Duplicate ID, Broken Reference, Invalid Region, Invalid Frame/Grid, Invalid Footprint, Invalid Placement Rule, Unused Resource, Runtime-incompatible Resource를 통합 검증한다.

### Priority
P0: Editor 책임 통합, Visual Asset/Map Asset 분리, Reference Integrity, Save→Reload→Verify, Map Asset ID 참조.
P1: 통합 UI, Usage/Impact Inspector, Validation Panel, Safe Replace/Delete Protection, Migration, Batch Management.
P2: Version/Snapshot, Advanced Variant/Mask, Atlas Packing, External Change Detection, Asset Recovery.

### Judgment
현재 Image Editor와 Asset Catalog Editor를 각각 확장하기보다 Asset Editor 하나로 통합하고 Source → Visual Asset → Map Asset → Map의 책임 경계를 명확히 하는 방향이 적절하다.

Status: PROPOSAL / CODE VERIFIED / EDITOR VERIFIED / BUILD VERIFIED / PIE VERIFIED UNVERIFIED
No Runtime code change performed.
