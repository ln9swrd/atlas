# 051 Exelion Forge 프로젝트 통합정리

## 정의
EXCELION Forge = 완성된 게임/단순 3D 생성기가 아닌 **EXCELION 게임 개발용 Blender 기반 제작·검증 시스템 (Development Pipeline)**.

## 목표
캐릭터 생성 → 리깅 → 애니메이션 준비 → 구조 검증 → 게임 데이터 생성 자동화.

## 현재 위치
초기 단계. Blender Add-on, Rig 검증, 파이프라인 자동화, AI 연동 구조, 문서 기반 개발.

## 핵심 기능
- **Rig Validation** (Active Rig 검사, 구조/오류 검출) — 현재 핵심 안정화 대상
- Character Pipeline (생성 → Bone → Weight → Export → Validation)
- AI Runtime (작업 수행, Evidence 기록, Zero Hallucination)

## 개발 원칙
Document First / Evidence Based / Zero Hallucination / Runtime 상태 관리 / 재현 가능

## 방향 변경
초기: Forge 내부에서 SERA 개발 → **현재: SERA 우선 개발 후 SERA로 Forge 개발**

## 우선순위
1. SERA 플랫폼 개발·안정화
2. Forge 개발 재개
3. Character Pipeline 구축
4. EXCELION 제작 자동화

## 장기 비전
캐릭터·리깅·애니메이션·검증·데이터·AI 지원을 하나의 플랫폼에서 제공하는 통합 제작 시스템.
