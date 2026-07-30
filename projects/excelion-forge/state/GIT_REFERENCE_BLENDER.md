# Git Reference — Forge · Blender

조사일: 2026-07-30 (chat → state)

## 결론

Forge·Blender 참고 대상은 사실상 **하나**다.

## 1. 정식 참고 (D20)

`ln9swrd/atlas` → `projects/excelion-forge/`

| 구분 | 경로 | 용도 |
|------|------|------|
| 애드온 코드 | `excelion_forge/` | core rules, operators, UI, blender adapter |
| 빌드 | `scripts/build_addon.py` | 애드온 zip 패키징 |
| Blender 스크립트 | `scripts/blender/`, `blender/scripts/` | 로컬 bpy 스크립트 |
| 에셋/샘플 | `blender/assets/`, `tests/blend_samples/` | .blend·회귀 샘플 |
| 문서 | `docs/SPEC.md`, `15_ASSET_PIPELINE.md`, `20_ADDON_BUILD_GUIDE.md`, `BLENDER_SELF_HOSTED_RUNNER.md`, `31_REGRESSION_SUITE.md` | 검증 범위·파이프라인·CI |
| 상태 | `state/` | Cline/cloud 공통 Next |

Blender 없이 돌릴 단위 테스트 + headless Blender 통합 테스트 문서가 여기 있다.

## 2. 별도 GitHub 레포

`ln9swrd/excelion-forge` (private)

- 구조가 atlas 안의 `projects/excelion-forge`와 거의 동일 (`blender/`, `excelion_forge/`, `docs/`, `tests/`…)
- 업데이트: 2026-07-08 전후
- 관계: 과거 단독 레포로 보이며, 지금은 atlas 하위가 운영 기준(D20).
- 둘 중 어디가 최신인지는 로컬에서 `git log` 비교 필요. 작업 시 **한 곳만 기준**으로 둔다.

## 3. 참고하면 안 되는 것

| 경로 | 이유 |
|------|------|
| `projects/forge/` | App-host 실험(D20), 제품 Blender 애드온 아님 |
| `projects/excelion/projects/exelion_forge/` | README 스텁 |
| 다른 user:ln9swrd 공개 레포 | Blender/Forge 관련 추가 레포 없음 (검색 기준 excelion-forge 1개) |

## 4. Git에서 바로 볼 때 추천 순서

1. `projects/excelion-forge/state/CURRENT_STATE.md`
2. `docs/SPEC.md` (rig validation 범위)
3. `docs/20_ADDON_BUILD_GUIDE.md` + `excelion_forge/`
4. `docs/15_ASSET_PIPELINE.md` (Blender→Unreal 규칙)
5. `tests/` + `docs/31_REGRESSION_SUITE.md` (증거/회귀)

## 한 줄

깃에서 Forge·Blender 참고 프로젝트는 **atlas/projects/excelion-forge**가 본체이고, 형제 레포 `ln9swrd/excelion-forge`는 동기화 여부만 확인하면 된다.
