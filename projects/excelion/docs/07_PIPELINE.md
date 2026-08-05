# 07_PIPELINE — 제작 파이프라인

## 목표
파라미터 기반 캐릭터 생성기 → 게임 적용

## 흐름
```
Blender Script / ParaModel
  → 기본 메쉬 생성
  → 파라미터 수정
  → 디테일
  → 리깅
  → 애니메이션
  → Unreal 적용
```

## 관련 프로젝트
| 프로젝트 | 역할 |
|----------|------|
| projects/excelion | 게임 제품·디자인 문서 (Atlas 하위) |
| excelion-forge | Blender/Unreal 제작 파이프라인 |
| projects/paramodel | 파라메트릭 메카 스키마·애드온 |

## 향후
- 캐릭터 생성기
- 애니메이션 자동화
- 적 생성 자동화
- Blender ↔ Unreal 연동

## 원칙
AI는 반복 작업을 대신한다. 게임이 재미있게 만드는 주체는 개발자.
