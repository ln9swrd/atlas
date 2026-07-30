# Git Reference — Pipeline (Blender ↔ Unreal / Asset)

조사일: 2026-07-30 (chat → state)

목적: Forge 스펙과 1:1이 아니어도 **파이프라인 구현 시 나중에 참고**할 공개 저장소 목록.
복제 대상이 아님. Export 설정·축·스케일·소켓·에러 체크·네이밍 관행만 흡수.

관련: `GIT_REFERENCE_BLENDER.md`, `GIT_REFERENCE_UNREAL.md`, `docs/15_ASSET_PIPELINE.md`

---

## A. 우선 참고 (핵심)

| 저장소 | ★(대략) | 참고 용도 |
|--------|---------|-----------|
| [EpicGames/BlenderTools](https://github.com/EpicGames/BlenderTools) | 3.2k | Send to Unreal, UE↔Rigify. 공식에 가까운 워크플로·스켈레탈/애니메이션 전송 |
| [xavier150/Blender-For-UnrealEngine-Addons](https://github.com/xavier150/Blender-For-UnrealEngine-Addons) | 2.6k | Static/Skeletal/Anim/Socket/Collision 일괄 내보내기 + 에러 체커. FBX·UE 임포트 스크립트 |
| [mrven/Blender-Asset-Creation-Toolset](https://github.com/mrven/Blender-Asset-Creation-Toolset) (ACT) | 360+ | 배치 FBX/GLTF, 오리진, 리네임, UE/Unity 축 툴팁. 범용 게임 에셋 툴셋 |
| [anasrar/Blender-UE4-Workspace](https://github.com/anasrar/Blender-UE4-Workspace) | 170+ | Static/Skeletal 원클릭 UE 전송, LOD·소켓·콜리전 |

## B. Export / FBX 특화

| 저장소 | 참고 용도 |
|--------|-----------|
| [helluvamesh/GYAZ-Export-Tools](https://github.com/helluvamesh/GYAZ-Export-Tools) | Seamless Blender→UE FBX |
| [t-sumisaki/SKET](https://github.com/t-sumisaki/SKET) | SkeletalMesh 전용. Armature/Anim 스케일 보정, 본·메시 이름 충돌, Root 삽입 |
| [achoruzy/B2UE](https://github.com/achoruzy/B2UE) | 모델·소켓 준비 + UE 쪽 어셈블 스크립트 |
| [stricmp/xfbx](https://github.com/stricmp/xfbx) | UE Static Mesh 파이프라인(콜리전 네이밍 등) |
| [nikhil922/Blender-UE4-FBX-Export](https://github.com/nikhil922/Blender-UE4-FBX-Export) | 단순 배치 FBX |
| [sivert-io/fbx-action-exporter](https://github.com/sivert-io/fbx-action-exporter) | Action별 FBX 분리 내보내기 |

## C. 네이밍 · 검증 (파이프라인 전처리)

| 저장소 | 참고 용도 |
|--------|-----------|
| [jmossymoss/No-Dot-Names](https://github.com/jmossymoss/No-Dot-Names) | 스튜디오 네이밍 프리셋(UE/Unity), 검증·일괄 리네임 |
| Roblox Avatar Validation Tool (문서) | 본/조인트 체크 흐름 (플랫폼 전용, 패턴만) |
| [readyplayerme/blender-asset-validator](https://github.com/readyplayerme/blender-asset-validator) | Pyblish 검증 (개발 중단, 구조만 참고) |

## D. 기타 / 좁은 용도

| 저장소 | 참고 용도 |
|--------|-----------|
| [chinedufn/landon](https://github.com/chinedufn/landon) | 메시·아마추어 커스텀 파이프라인 export (Rust/CLI, 엔진 비종속) |
| DigiKrafting blender_addon_ue 등 | 원클릭 FBX + UE 플러그인 연동 스케치 |
| Unreal Pipeline Tools (Gumroad/BA 스레드) | 시네마틱·카메라·아마추어 배치, glTF 우회 스케일 이슈 |

---

## Forge에서 쓸 때 원칙

1. **지금 구현하지 않음** — 스펙(규칙 패키지 검증·회귀)과 겹치지 않는 한 코드 이식 금지.
2. **계약만 문서화** — 축·단위(0.01)·루트 본·소켓/UCX 네이밍·FBX 옵션은 `docs/15_ASSET_PIPELINE.md`에 고정할 때 위 도구들의 관행을 대조.
3. **우선순위** — Epic BlenderTools + BFUE 위키/릴리즈 노트 → SKET(스켈레탈 스케일) → ACT/NoDot(배치·네이밍).
4. **하지 말 것** — Send-to-Unreal 전체 재구현, 상용 파이프라인 툴 복제.

## 한 줄

파이프라인 공개 저장소는 **내보내기·축/스케일·소켓·에러 체크** 참고용으로 충분하고, Forge 본체 검증 엔진을 대체하지 않는다.
