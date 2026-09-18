# Excelion Hunyuan3D-2.1 Topology Assistant

## Project Purpose

Excelion 메카/부품 제작을 위한 개인용 보조 툴.

Blender 를 메인 제작 환경으로 유지하면서,
Hunyuan3D-2.1 을 최대한 활용하여 Blender 에서 후수정하기 좋은
Clean Quad Base Mesh 를 준비하는 것을 목적으로 한다.

## Role

- Blender: MAIN / Single Source of Truth
- This Project: SUPPORT TOOL
- Hunyuan3D-2.1: PRIMARY 3D generation engine
- Antigravity: IMPLEMENTATION AGENT

## Primary Goal

최종 목표는 자동으로 완성된 모델이 아니다.

Hunyuan3D-2.1 에서 생성된 형상을 기반으로
Blender 에서 사람이 수정하기 좋은 Quad 중심의 Clean Base Topology 를 얻는 것이다.

우선순위:

1. Shape preservation
2. Quad-dominant topology
3. Clean polygon distribution
4. Editable edge flow
5. Minimum unnecessary triangles
6. Minimum unnecessary ngons
7. Minimal non-manifold / degenerate geometry

Quad 100% 자체를 절대적인 품질 기준으로 사용하지 않는다.

## Core Pipeline

Reference Images
→ Hunyuan3D-2.1
→ Generated Mesh
→ Topology Processing
→ Clean Quad Base Mesh
→ Blender
→ Manual Final Topology

## Reference

기본 reference:

- Front
- Back
- Left
- Right
- Top
- Bottom

추가 reference:

- Front 3/4
- Back 3/4
- Detail
- Part-specific reference

이미지 수가 많을수록 무조건 결과가 좋아진다고 가정하지 않는다.
Reference 간 형상 일관성을 중요하게 취급한다.

## Work Unit

Excelion
└── Mecha
    └── Part
        ├── Reference
        ├── Generated
        └── Quad Base

전체 메카를 한 번에 처리하기보다 메카/부품 단위 작업을 기본으로 한다.

## Hunyuan First

자체 3D 생성 알고리즘을 개발하지 않는다.

자체 Retopology 알고리즘을 처음부터 개발하지 않는다.

먼저 Hunyuan3D-2.1 이 제공하는 기능을 최대한 활용한다.

Hunyun 자체 기능으로 해결되지 않는 경우에만 외부 topology/retopology backend 를 조사한다.

외부 backend 를 사용하는 경우 교체 가능한 구조를 우선한다.

## Blender Boundary

이 프로젝트는 Blender 를 대체하지 않는다.

다음은 Blender 의 책임이다.

- Final modeling
- Final topology editing
- UV
- Rigging
- Animation
- Final Asset authoring

이 프로젝트의 출력은 Blender 작업용 Base Mesh 다.

## Quality Check

후보 지표:

- Vertex count
- Face count
- Quad count
- Triangle count
- Ngon count
- Non-manifold
- Degenerate faces
- Connected components

추가 지표는 구현 전에 검토한다.

## Initial Scope

초기 범위:

- Project 관리
- Mecha 관리
- Part 관리
- Reference 관리
- Hunyuan3D-2.1 실행
- Generated Mesh 관리
- Topology 처리
- Topology quality check
- Blender 용 Base Mesh export

## Out of Scope

초기 단계에서는 다음을 구현하지 않는다.

- 자체 AI 모델
- 자체 3D 생성 알고리즘
- 자체 Retopology 알고리즘
- Blender 대체 기능
- UV
- PBR / Texture
- Rigging
- Animation
- LOD
- Game Engine integration
- STL/3MF 전용 기능
- 대규모 Asset Management
- 불필요한 리팩터링

## Implementation

실제 구현은 Antigravity 가 담당한다.

구현 전에 실제 Hunyuan3D-2.1 의 설치 상태, API, Shape/Mesh pipeline 및 topology 관련 기능을 조사한다.

확인되지 않은 기능은 구현 가정으로 사용하지 않는다.

## Verification

다음 상태를 구분한다.

- CODE VERIFIED
- BUILD VERIFIED
- HUNYUAN VERIFIED
- BLENDER VERIFIED
- NOT VERIFIED

실제 Blender 에서 확인하지 않은 결과를 BLENDER VERIFIED 로 표시하지 않는다.

## Development Principle

작게 조사
→ 결과 확인
→ Master 승인
→ 최소 구현
→ Diff 확인
→ Build
→ Blender 검증
→ 결과 판정

### STATUS

- 디렉터리 생성: ✅ 완료
- README.md 생성: ✅ 완료
- 기존 파일 수정: ⛔ 없음

### 기준선

- projects/excelion/ (기존): 수정 없음

### 변경 사항

- `projects/excelion-hunyuan-topology-assistant/README.md` 추가 생성

### Diff

(새 디렉터리 생성, README.md 추가)


### 검증 상태

- 디렉터리 생성: ✅ 완료
- README.md 생성: ✅ 완료
- 기존 파일 수정: ⛔ 없음

### 미확인 사항

- shell 명령 실행 문제 (권장하지 않음)

### OUT OF SCOPE

- 코드 구현
- Hunyuan 설치/실행
- Commit/Push
