# 050 Exelion Forge 권장구조 및 파이프라인

## 결론: 하이브리드 아키텍처
- 단순 Blender 애드온만 → 한계 (DB, AI, 버전관리, 대량생성 등 괴물화)
- 완전 독립 앱 → 초기 난이도 과다 (3D 조작은 Blender가 최강)
- **권장: Forge Core Engine + Blender Add-on (Worker)**

## 구조
```
SERA AI
  ↓
Forge Core Engine (프로젝트 관리, AI 명령, 데이터, 검증, Export)
  ↓
Blender Bridge
  ↓
Blender Add-on (Mesh/Rig/Material/Animation 실행)
```

- Forge = 뇌 (Pipeline OS)
- Blender = 손발 (실행 에이전트)

## 개발 순서
- **Phase 1**: Blender Add-on 중심 (Rig Validator, Asset Scanner, Exporter, Basic Pipeline)
- **Phase 2**: 외부 Core 추가 (core / database / pipeline / blender_bridge / addon)
- **Phase 3**: SERA 연결 (SERA → Forge API → Blender Agent)

## 목표 형태
SERA가 조종할 수 있는 Blender 제작 Agent부터 시작.
장기적으로 AI 시대의 게임 제작 Pipeline OS.
