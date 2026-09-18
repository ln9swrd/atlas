# 07_PIPELINE — 제작 파이프라인

## 목표
파라미터·에셋 기반 메카를 게임에 적용한다.

## 활성 흐름
```
Meshy AI
  → 3D 모델 (mesh)
  → Blender (cleanup · rig · pose · motion)
  → FBX export
  → Unreal import
```

계약 문서: `state/MESHY_BLENDER_PIPELINE_SPEC.md`  
(미확정 항목 G1–G7은 **TBD** · 임의 확정 금지)

## 관련 프로젝트
| 프로젝트 | 역할 |
|----------|------|
| projects/excelion | 게임 제품·디자인 문서 (Atlas 하위) |
| ln9swrd/excelion-forge | **DEPRECATION CANDIDATE** · 구 Blender 애드온/파이프라인 (자산 보존) |
| projects/paramodel | 파라메트릭 메카 스키마·애드온 (**HOLD**) |

## 향후
- Meshy/Blender 실작업 (Spec TBD 해소 후)
- 애니메이션·적 생성 자동화
- Blender ↔ Unreal 연동 검증

## 원칙
AI는 반복 작업을 대신한다. 게임이 재미있게 만드는 주체는 개발자.
