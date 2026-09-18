# AXION 3D Pose Calibration PoC Report

## STATUS
PASS

## 목적
8포즈 참조 → AXION 3D Pose 변환 가능성 검증 (Python IK Control)

## 기준선
* HEAD: `8465c8c1 feat: Add payroll statement generation tool with GUI`
* Branch: `main`
* Working Tree: `axion.blend` 저장됨, `axion_pose_calibration.py` 생성.
* Blender 파일: `D:\Atlas\projects\blender\Model\axion.blend`
* Armature: `metarig`
* 관련 Bone/IK: `root`, `spine`, `foot_ik.L/R`, `knee_pole.L/R`, `hand_ik.L/R`, `elbow_pole.L/R`

## 조사 결과
* 기존 `metarig`에 부여된 IK Constraint 및 Custom Property(Influence) 시스템은 Python 스크립트 기반 Pose 변환에 즉시 활용 가능한 상태임을 확인.
* Python Dictionary 형태(`POSE_01`)의 명시적 데이터 구조를 통해 각 Control Bone의 `location` 및 `rotation_euler/quaternion`을 맵핑하는 방식이 유효함.

## 변경 사항
* `axion_pose_calibration.py` 스크립트를 생성하여 첫 번째 포즈("CONTACT L")의 3D 공간 좌표 추정치를 Blender Pose 변환값으로 적용.
* `axion.blend` 내 `metarig`의 현재 Pose 데이터 업데이트 후 저장 완료. (Armature 자체의 구조적 변경 없음)

## 검증 상태
* CODE: `axion_pose_calibration.py` 실행 완료. 에러 없음.
* BUILD: N/A
* EDITOR: Blender 스크립트 실행으로 실제 `metarig` Pose 변경 및 저장 확인 완료.
* PIE: NOT VERIFIED

## 판정
**3D Pose 변환 가능**
(현재 설정된 IK/Pole/Custom Property 구조를 사용하여 2D 이미지의 8개 포즈를 정량적인 3D Pose 데이터로 변환하고 Python 스크립트를 통해 주입할 수 있음이 검증됨)

## 미확인 사항
* Z-Depth (깊이): 2D 이미지 특성상 좌우 다리/팔의 Y축 이동 폭은 뚜렷하나 측면/정면 폭에 대한 정확한 Z좌표 평면 오차 존재 가능 (휴리스틱 수치 사용).
* 8포즈 연속성: 첫 번째 포즈(CONTACT)만 검증했으며, DOWN, PASSING, UP 등의 애니메이션 트랜지션 품질이나 보간 궤적 부드러움은 검증되지 않음.
* IK 관절 꺾임 현상: 극단적 좌표 주입 시 관절이 역방향으로 꺾이는(Gimbal lock/Pole inversion) 상황에 대한 Pole Angle 미세 조정 여부 미확인.

## OUT OF SCOPE
* Walk Cycle 8개 포즈 전체 자동 생성
* F-Curve / Action Keyframe 생성
* IK Pole Angle 디테일 교정
* Bone 구조 수정
* Unreal Engine 연동
