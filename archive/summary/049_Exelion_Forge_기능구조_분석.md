# 049 Exelion Forge 기능구조 분석

## 정의
Forge = 단순 3D 에셋 생성기가 아닌 **AI + Blender + 검증 시스템을 결합한 게임 개발 제작 엔진**.

## 6계층 기능 구조
1. **Asset Pipeline** — 모델 생성/수정/관리 (Asset Registry + Blender Bridge)
2. **Rig & Animation Pipeline** — 리깅/애니메이션/검증 (Rig Validation, Animation Library)
3. **Game Data Pipeline** — 캐릭터 데이터/스킬/밸런스 (Character Blueprint, Skill Editor)
4. **Validation System** — 오류 탐지/품질 검사 (Model/Rig/Game Data 검증)
5. **AI Agent Interface** — SERA 연동 (Forge API: create_asset, validate_rig, export 등)
6. **Build & Export Pipeline** — 게임 엔진 전달 (FBX → Unity/Unreal)

## 우선순위
- **Phase 1 (필수)**: Asset Registry + Blender Bridge + Validation System
- **Phase 2**: Rig Pipeline + Animation Library + Character Blueprint
- **Phase 3**: AI Generation + SERA Integration + Skill Generator

## 킬러 기능
캐릭터 제작 → 리깅 → 검증 → 게임 데이터 생성까지 자동 연결하는 파이프라인.
(단순 AI 모델 생성기가 아닌 **게임 제작 전체 흐름 자동화 AI 제작 OS**)

## 구현 메모
- Asset Registry: Python + SQLite/JSON metadata
- Blender Bridge: bpy + subprocess
- Validation: Polygon/Texture/Bone/Weight/Constraint 검사 → Report
