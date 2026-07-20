# EXCELION FORGE SPEC

> Product : Excelion Forge
> Python Package : excelion_forge
> Status : Active
> Version : v0.2
> Last Updated : 2026-07-03

---

# 문서의 목적

이 문서는 Excelion Forge의 검증 기능 범위를 정의한다.

기능을 추가하기 전에 해당 검사가 왜 필요한지 먼저 확인한다.

---

# v0.1 범위

| 항목 | 상태 | 목적 |
| --- | --- | --- |
| Rig Validation | 구현됨 | 선택한 Armature가 기본 제작 조건을 만족하는지 확인한다. |
| Target Type Check | 구현됨 | Armature가 아닌 대상을 잘못 검증하지 않도록 막는다. |
| Armature Data Check | 구현됨 | 손상되거나 비어 있는 Armature data block을 탐지한다. |
| Bone Count Check | 구현됨 | Bone이 없는 Armature를 탐지한다. |
| Single Root Bone Check | 구현됨 | Unreal용 Skeleton의 기본 계층 안정성을 확인한다. |
| Transform Check | 구현됨 | Export 전 Armature object transform 적용 여부를 확인한다. |
| Bone Name Check | 구현됨 | 비어 있거나 중복된 Bone 이름을 탐지한다. |
| Rule Manager | 구현됨 | 등록된 검증 Rule을 순차 실행하고 결과를 수집한다. |

---

# Sprint 2 Object Validation

목적

Asset Export 이전에 선택 대상과 Armature 계층의 가장 기본적인 실패를 빠르게 탐지한다.

구현 규칙

| Rule | Code | 기대 동작 |
| --- | --- | --- |
| TargetIsArmatureRule | TARGET_MISSING | 선택 대상이 없으면 한 번만 보고한다. |
| TargetIsArmatureRule | TARGET_NOT_ARMATURE | 선택 대상이 Armature가 아니면 한 번만 보고한다. |
| EmptyArmatureRule | ARMATURE_DATA_MISSING | Armature data block이 없을 때만 보고한다. |
| ArmatureHasBonesRule | ARMATURE_HAS_NO_BONES | Bone이 없는 Armature만 보고한다. |
| SingleRootBoneRule | ROOT_BONE_MISSING | Bone은 있지만 root bone이 없을 때만 보고한다. |
| SingleRootBoneRule | MULTIPLE_ROOT_BONES | root bone이 둘 이상일 때만 보고한다. |
| ArmatureTransformRule | ARMATURE_TRANSFORM_NOT_APPLIED | location, rotation, scale 중 기본값이 아닌 값이 있으면 보고한다. |
| BoneNameRule | BONE_NAME_EMPTY | 이름이 비어 있는 Bone을 보고한다. |
| BoneNameRule | DUPLICATE_BONE_NAME | 중복된 Bone 이름을 보고한다. |

전제 조건

* 각 규칙은 하나의 class로 유지한다.
* 각 규칙 class는 `excelion_forge/core/rules/object/` 아래 개별 파일에 둔다.
* core 모듈은 Blender UI와 독립적으로 유지한다.
* 선행 조건이 유효하지 않으면 이후 규칙은 조용히 건너뛴다.
* 같은 원인에 대해 중복 finding을 만들지 않는다.
* Operator는 실행 context 유효성만 확인하고, target 판단은 core에 위임한다.
* RuleManager는 등록된 Rule을 순차 실행한다.
* RigValidator와 validate_armature_object는 하위 호환 API로 유지한다.

---

# Manual Blender UI Test Cases

| Case | 준비 | 실행 | 기대 결과 |
| --- | --- | --- | --- |
| No Target | 선택된 object가 없도록 한다. | Excelion > Validate Active Rig | TARGET_MISSING 1건 |
| Mesh Target | Cube 같은 Mesh object를 선택한다. | Excelion > Validate Active Rig | TARGET_NOT_ARMATURE 1건 |
| No Bone Armature | Bone이 없는 Armature를 선택한다. | Excelion > Validate Active Rig | ARMATURE_HAS_NO_BONES 1건 |
| Valid Armature | root bone이 하나 있는 Armature를 선택한다. | Excelion > Validate Active Rig | validation 통과 |
| Multiple Roots | parent가 없는 bone을 둘 이상 만든다. | Excelion > Validate Active Rig | MULTIPLE_ROOT_BONES 1건 |

---

# Unit Test Cases

Blender 없이 `tests/test_object_validation_rules.py`에서 fake object로 검증한다.

실행

```bash
python -m unittest discover -s tests
```

검증 범위

* DEFAULT_RULES 실행 순서
* No Target 중복 finding 방지
* Mesh Target 중복 finding 방지
* Missing Armature Data 중복 finding 방지
* No Bone Armature 중복 finding 방지
* Valid Armature 통과
* Multiple Root Bone 단일 finding
* Missing Root Bone 단일 finding

---

# Manual Blender Python Console Test Cases

일반 Blender UI에서 만들기 어려운 손상 데이터는 Blender Python Console에서 core를 직접 호출해 확인한다.

```python
from types import SimpleNamespace
from excelion_forge.core import RigValidator

target = SimpleNamespace(type="ARMATURE", name="BrokenRig", data=None)
report = RigValidator().validate(target)
print([issue.code for issue in report.issues])
```

기대 결과

```text
['ARMATURE_DATA_MISSING']
```

```python
from types import SimpleNamespace
from excelion_forge.core import RigValidator

bone = SimpleNamespace(name="LoopBone", parent=object())
target = SimpleNamespace(
    type="ARMATURE",
    name="NoRootRig",
    data=SimpleNamespace(bones=[bone]),
)
report = RigValidator().validate(target)
print([issue.code for issue in report.issues])
```

기대 결과

```text
['ROOT_BONE_MISSING']
```

---

# 이후 후보

| 항목 | 상태 |
| --- | --- |
| Bone Naming | 예정 |
| Hierarchy | 예정 |
| Transform Freeze | 예정 |
| Scale Check | 예정 |
| Twist Bone Check | 예정 |
| IK Bone Check | 예정 |
| Weight Check | 예정 |

---

# 통합 테스트 계획

## 목적

단위 테스트로 검증할 수 없는 Blender 런타임 동작을 회귀 `.blend` 샘플로 검증한다.

## 테스트 자산

`tests/blend_samples/` 에 5개의 `.blend` 파일을 포함한다.

| 파일명 | 예상 이슈 코드 |
|--------|----------|
| `valid_rig.blend` | 없음 |
| `invalid_transform.blend` | `ARMATURE_TRANSFORM_NOT_APPLIED` |
| `invalid_duplicate_bone.blend` | `MULTIPLE_ROOT_BONES` |
| `invalid_empty_bone.blend` | `BONE_NAME_EMPTY` |
| `invalid_multi_issue.blend` | `MULTIPLE_ROOT_BONES` + `ARMATURE_TRANSFORM_NOT_APPLIED` |

> Blender 5.x API는 중복 본 이름 생성을 허용하지 않습니다 (`DUPLICATE_BONE_NAME`은 단위 테스트에서 검증).

## 샘플 생성 방법

```bash
blender --background --python tests/blend_samples/generate_samples.py
```

## 통합 테스트 실행 방법

```bash
# 단일 .blend 파일 대상
blender --background tests/blend_samples/valid_rig.blend \
        --python tests/integration/test_blender_validation.py

# 전체 샘플 일괄 실행 (Blender headless)
python tests/integration/run_all.py
```

`run_all.py`는 샘플 `.blend` 파일이 없으면 `generate_samples.py`를 자동 호출한다.

## CI 연동 전략

1. Blender headless 바이너리를 CI 환경에 설치 (GitHub Actions, Docker 등)
2. `generate_samples.py` 로 샘플 생성 (또는 `run_all.py`가 자동 생성)
3. `python tests/integration/run_all.py` 로 5개 샘플을 순차 실행
4. 반환 코드 0 → 통과, 1 → 실패로 CI 상태 결정

## 제약사항

- `tests/integration/test_blender_validation.py`는 일반 pytest/unittest 환경에서는
  `bpy` 미발견으로 자동 skip 된다.
- `.blend` 파일은 Blender 5.x 포맷이어야 한다.
- 통합 테스트는 단위 테스트를 대체하지 않는다 — 핵심 로직은 항상 단위 테스트가 우선이다.
