# Excelion Forge — Regression Blend Samples

이 디렉토리는 Excelion Forge 회귀 테스트용 `.blend` 파일을 포함합니다.

## 파일 생성 방법

```bash
blender --background --python tests/blend_samples/generate_samples.py
```

Blender 실행 경로가 PATH에 없는 경우:

```powershell
# Windows PowerShell 예시
& "C:\Program Files\Blender Foundation\Blender 5.x\blender.exe" `
    --background `
    --python tests/blend_samples/generate_samples.py
```

## 샘플 명세

| 파일명 | 아마추어 구성 | 예상 이슈 코드 |
|--------|------------|-------------|
| `valid_rig.blend` | Root → Spine → Chest, 트랜스폼 적용됨 | 없음 (0 issues) |
| `invalid_transform.blend` | Root 1개, `location=(1,0,0)` 미적용 | `ARMATURE_TRANSFORM_NOT_APPLIED` |
| `invalid_duplicate_bone.blend` | parent 없는 root bone 2개 | `MULTIPLE_ROOT_BONES` |
| `invalid_empty_bone.blend` | 공백 이름 본 1개 포함 | `BONE_NAME_EMPTY` |
| `invalid_multi_issue.blend` | root bone 2개 + 미적용 트랜스폼 | `MULTIPLE_ROOT_BONES`, `ARMATURE_TRANSFORM_NOT_APPLIED` |

> **Blender 5.x 제약**: API가 중복 본 이름 생성 시 자동으로 `.001` 접미사를 붙입니다.
> `DUPLICATE_BONE_NAME` 검증은 단위 테스트(`tests/test_rules.py`)에서 fake object로 커버합니다.

## 주의사항

- `.blend` 파일은 Blender 5.x 이상에서 생성해야 합니다.
- 생성된 `.blend` 파일은 Git에 커밋하거나 로컬 테스트 자산으로 유지할 수 있습니다.
- 통합 테스트에서는 이 파일들을 `blender --background <blend>` 로 불러와 사용합니다.

## 관련 파일

- `tests/integration/test_blender_validation.py` — headless 통합 테스트
- `docs/SPEC.md` — 통합 테스트 섹션
