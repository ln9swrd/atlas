# Excelion Forge 회귀 테스트 샘플(Regression Suite) 명세서

이 문서는 Excelion Forge 리그 검증기(Rig Validator)의 안정성을 지속적으로 모니터링하기 위해 구축된 5가지 핵심 회귀 테스트용 `.blend` 샘플 파일의 내부 아마추어(Armature) 구성 구조 및 기대 테스트 결과를 상술합니다.

---

## 1. 회귀 테스트 에셋 일괄 개요

모든 샘플 에셋들은 `tests/blend_samples/` 폴더 내에 배치되어 있으며, `generate_samples.py` 스크립트를 통해 Blender 런타임 상에서 순수 파이썬 API로 생성됩니다. 이 구조는 바이너리 파일이 Git 저장소 내에서 꼬이거나 유실되는 문제를 방지합니다.

| 파일명 | 아마추어 대상 이름 | 타겟 검출 규칙 (Expected Rules) | 예상 에러 개수 |
| :--- | :--- | :--- | :---: |
| `valid_rig.blend` | `Armature_Valid` | (검출 없음 - 패스) | 0 |
| `invalid_transform.blend` | `Armature_BadTransform` | `ARMATURE_TRANSFORM_NOT_APPLIED` | 1 |
| `invalid_duplicate_bone.blend` | `Armature_DupBone` | `MULTIPLE_ROOT_BONES` | 1 |
| `invalid_empty_bone.blend` | `Armature_EmptyBone` | `BONE_NAME_EMPTY` | 1 |
| `invalid_multi_issue.blend` | `Armature_MultiIssue` | `MULTIPLE_ROOT_BONES`, `ARMATURE_TRANSFORM_NOT_APPLIED` | 2 |

---

## 2. 각 샘플별 상세 설계 규격

### 2.1. `valid_rig.blend` (정상 뼈대 모델)
* **생성 목적**: 오류가 없는 완벽하게 리셋된 아마추어 데이터에 대해 검증기가 정상 작동(0 Issue 패스)을 수행하는지 확인합니다.
* **아마추어 구성**:
  - 부모-자식 관계가 명확한 본 트리: `Root` → `Spine` → `Chest`
  - 트랜스폼 상태: 오브젝트의 Location, Rotation이 모두 초기화(`(0,0,0)`)되고 Scale이 `1.0`인 상태로 완벽히 적용(Apply)됨.
* **예상 결과**: 검증 세션이 이슈를 보고하지 않고 녹색 패스 신호를 반환해야 합니다.

### 2.2. `invalid_transform.blend` (트랜스폼 미적용 오류)
* **생성 목적**: Blender에서 리깅 작업 시 흔히 발생하는 "오브젝트 모드 트랜스폼 미적용" 실수를 정상 검출해 내는지 검증합니다.
* **아마추어 구성**:
  - 단일 본(`Root`)을 가진 아마추어.
  - 오브젝트의 트랜스폼 상태가 `location=(1.0, 0.0, 0.0)` 및 `scale=(2.0, 2.0, 2.0)` 상태로, 델타 값이 적용되지 않고 떠 있는 상태.
* **예상 결과**: `ARMATURE_TRANSFORM_NOT_APPLIED` 오류(Severity: WARNING) 코드가 정확히 1개 검출되어야 합니다.

### 2.3. `invalid_duplicate_bone.blend` (다중 루트 본 오류)
* **생성 목적**: Unreal Engine 등 외부 엔진 익스포트 시 치명적 오류를 야기하는 "최상위 루트 본이 2개 이상 존재하는 경우"를 탐지합니다.
* **아마추어 구성**:
  - 부모(parent) 관계가 설정되지 않아 각각 최상위 루트로 작동하는 `Root_A` 와 `Root_B` 본이 공존함.
* **예상 결과**: 최상위 루트 본이 1개가 아니므로 `MULTIPLE_ROOT_BONES` 오류(Severity: ERROR) 코드가 정확히 1개 검출되어야 합니다.
* *참고 (Blender 5.x API 제약)*: Blender는 네이밍 중복을 허용하지 않아 자동으로 `.001` 접미사를 붙이므로, 실제 중복 이름 탐지 검증(`DUPLICATE_BONE_NAME`)은 테스트 유닛에서 가상 구조를 모킹하여 수행하고, 본 샘플에서는 다중 루트 위주로 검증을 대체합니다.

### 2.4. `invalid_empty_bone.blend` (공백 이름 본 오류)
* **생성 목적**: 리깅 작업 중 실수나 버그로 인해 이름이 비어 있는 본이 레이아웃에 삽입되었을 때 이를 탐지합니다.
* **아마추어 구성**:
  - 하나의 본의 이름이 공백(`"   "`) 문자로만 구성되어 레이아웃에 잡혀 있음.
* **예상 결과**: 공백 이름을 검출하여 `BONE_NAME_EMPTY` 오류(Severity: ERROR) 코드가 1개 검출되어야 합니다.

### 2.5. `invalid_multi_issue.blend` (복합 예외 모델)
* **생성 목적**: 한 리그 안에 다중 루트 본 및 트랜스폼 미적용 예외가 동시에 혼재되어 있을 때, 누락 없이 멀티플 검출을 수행하는지 확인합니다.
* **아마추어 구성**:
  - 트랜스폼 미적용 상태 (`location=(1.0, 0.0, 0.0)`)
  - 부모 관계가 묶이지 않은 2개의 최상위 루트 본 구조.
* **예상 결과**: `MULTIPLE_ROOT_BONES`와 `ARMATURE_TRANSFORM_NOT_APPLIED` 코드가 모두 누락 없이 검출되어 총 2개의 이슈가 기록되어야 합니다.

---

## 3. 회귀 테스트의 지속적 검증 절차 (CI/CD 연동)

1. 로컬 또는 CI 가상 환경에 Blender 설치 완료 후, `tests/blend_samples/generate_samples.py`를 실행하여 `.blend` 파일을 새로 갱신하여 빌드합니다.
2. `tests/integration/run_all.py` 스크립트를 기동하여 5개 샘플에 대해 순차적인 Headless 테스트 검증을 완수합니다.
3. 이 회귀 테스트 과정은 GitHub Actions의 `tests.yml` 워크플로우에 통합되어, 커밋이 Push될 때마다 자동으로 수행 및 보고됩니다.
