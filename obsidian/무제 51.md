이 프로젝트에서 게임 엑셀리온 포지와 관계된 부분을 md로 정리해줘

프로젝트 대화를 기준으로 **EXCELION Forge와 직접 관련된 내용만 추려** Markdown으로 정리하면 다음과 같습니다.

# EXCELION Forge 프로젝트 정리

> Version: Baseline 0.1  
> Status: Active  
> Last Updated: 2026-07-21

---

# 프로젝트 개요

EXCELION Forge는 완성된 게임이나 단순한 3D 모델 생성기가 아니다.

현재 목표는 **EXCELION 게임 개발을 위한 Blender 기반 제작 및 검증 시스템(Development Pipeline)** 을 구축하는 것이다.

Forge는 향후 캐릭터, 리깅, 애니메이션, 검증을 자동화하는 제작 플랫폼으로 발전한다.

---

# 현재 프로젝트 위치

현재 Forge는 초기 개발 단계이며 핵심은 다음과 같다.

- Blender Add-on 기반 제작 환경
- Rig 검증 시스템
- 제작 파이프라인 자동화
- AI Agent와 연동 가능한 구조
- 문서 기반 개발

아직 완전한 캐릭터 생성기나 게임 제작 툴은 아니다.

---

# 프로젝트 목표

Forge는 다음과 같은 제작 과정을 자동화하는 것을 목표로 한다.

1. 캐릭터 생성
2. 리깅
3. 애니메이션 준비
4. 구조 검증
5. EXCELION에서 사용할 데이터 생성

---

# 개발 방향

프로젝트의 방향은 다음과 같다.

- Blender를 중심으로 개발
- AI가 반복 작업 수행
- 사람이 최종 승인
- 모든 과정은 문서화
- 검증 가능한 시스템 구축

---

# 주요 기능

## Rig Validation

현재 가장 중요한 기능 중 하나이다.

대표 기능

- Active Rig 검사
- Rig 구조 확인
- 오류 검출
- 제작 기준 검증

---

## Character Pipeline

향후 목표

- 캐릭터 생성
- Bone 생성
- Weight 설정
- Export
- Validation

---

## AI Runtime

Forge 내부에는 AI Runtime 개념이 존재한다.

목적

- 작업 수행
- 증거(Evidence) 기록
- 문서 기반 보고
- Zero Hallucination 원칙 적용

---

# 개발 원칙

Forge 개발 시 다음 원칙을 유지한다.

- 문서 우선(Document First)
- 증거 기반 개발(Evidence Based)
- Zero Hallucination
- Runtime 상태 관리
- 모든 작업은 재현 가능해야 함

---

# 개발 구조

예상 구성

```
Forge
 ├── Blender Add-on
 ├── Core
 ├── Validation
 ├── Character Pipeline
 ├── Runtime
 ├── Documents
 └── AI Agent
```

---

# 확인된 문제

## Validate Active Rig

프로젝트에서 반복적으로 발생한 문제

증상

- Validate Active Rig 실행 시 Runtime Error 발생
- AI가 수정했다고 보고했지만 실제 해결되지 않음
- 동일 문제가 여러 차례 재발

이 기능은 현재 Forge의 핵심 안정화 대상이다.

---

# AI Agent 운영 방식

Forge는 AI Agent를 활용한 개발을 전제로 한다.

요구사항

- 허위 보고 금지
- 실행 결과와 증거 제시
- 문서 확인 후 작업
- 실제 수정 여부 검증
- Runtime 상태 기록

---

# 문서 중심 개발

Forge는 코드보다 문서를 우선한다.

확인된 문서 예

- README.md
- MISSION_DESIGN.md
- AGENT_GUIDE.md
- Execution 관련 문서
- Rules 문서

문서는 개발 기준이 되며 AI도 이를 우선적으로 참고해야 한다.

---

# 프로젝트 변경 사항

초기에는 Forge 내부에서 SERA를 개발하는 방향이었다.

현재는 방향이 변경되었다.

**SERA를 먼저 개발하고, 이후 SERA를 이용하여 Forge를 개발하는 구조​**로 전환되었다.

이 변경으로 Forge 개발은 일시적으로 후순위가 되었으며, SERA 완성 이후 Forge 개발을 가속화하는 전략을 채택하였다.

---

# 현재 우선순위

1. SERA 플랫폼 개발
2. SERA 안정화
3. Forge 개발 재개
4. Character Pipeline 구축
5. EXCELION 제작 자동화

---

# 장기 목표

Forge는 최종적으로 EXCELION 제작을 위한 통합 제작 시스템이 되는 것을 목표로 한다.

최종 비전은 다음 기능을 하나의 플랫폼에서 제공하는 것이다.

- 캐릭터 제작
- 리깅
- 애니메이션
- 검증
- 데이터 생성
- AI 기반 제작 지원
- EXCELION 게임 개발 자동화

이 문서는 **현재 프로젝트 대화에서 확인된 Forge 관련 내용만** 정리한 기준선(Baseline)입니다. 이후에는 이를 `FORGE_BASELINE.md`로 두고, 아키텍처·런타임·검증 시스템·캐릭터 파이프라인 등을 별도 문서로 분리하면 관리하기 훨씬 수월합니다.