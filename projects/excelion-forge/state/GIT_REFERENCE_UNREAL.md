# Git Reference — Forge · Unreal

조사일: 2026-07-30 (chat → state)

## 결론 한 줄

깃에서 Forge·Unreal 참고 본체는 **문서 + 얇은 스텁**이고, `.uproject` / `Content/` UE 게임 레포는 없다.

## 1. 정식 참고 (문서 중심) — atlas/projects/excelion-forge/

| 문서 | 내용 |
|------|------|
| `docs/13_UNREAL_ARCHITECTURE.md` | Content 구조, C++/BP 역할, Component 설계 (Draft) |
| `docs/15_ASSET_PIPELINE.md` | Blender → FBX → Unreal Import 규칙 |
| `docs/ROADMAP.md` | FBX Export 등은 예정 (v0.3+) |
| `AGENTS.md` | `unreal/` 폴더는 아직 없다고 명시 |

→ Forge의 Unreal 관련 Git 진실은 파이프라인·아키텍처 문서이지, UE 플러그인/게임 코드가 아님.

## 2. 게임 쪽 문서 — atlas/projects/excelion/

- README에 엔진 = Unreal 명시
- Charter / backlog 수준
- Unreal 프로젝트 트리 없음 (Git에 `.uproject` 검색 결과 없음)

→ “게임은 UE로 만든다”는 의도 문서만 있음. 실제 UE 작업은 DEV_HOME(집 PC) 전제 (`ENVIRONMENTS.md`).

## 3. Atlas 공통 규칙 (Forge 전용이 아님)

| 경로 | 성격 |
|------|------|
| `docs/PLAYBOOKS/Unreal.md` | 짧은 실무 노트 |
| `core/rules/`, `core/checklists/` | 네이밍·Import 체크리스트 |
| `core/connectors/unreal_connector.py` | 이벤트 발행 스텁 |
| `core/tools/` 언급 `ue_validation.py` 등 | 도구 레이어 (레거시/부분 구현) |

→ DevOS 쪽 규칙·자동화 스케치. excelion-forge 애드온 본체와는 분리.

## 4. 참고하면 안 되는 / 약한 것

| 경로 | 이유 |
|------|------|
| `projects/forge/adapters/unreal_adapter.py` | 시뮬레이션만 (실제 unreal 모듈 미사용, D20 비제품) |
| `ln9swrd/excelion-forge` 단독 레포 | Blender/Python 중심, 별도 UE 게임 레포 아님 |
| 다른 user:ln9swrd Unreal 레포 | 검색상 없음 |

## 5. Blender 조사와 비교

| | Blender | Unreal |
|--|---------|--------|
| 코드 | `excelion_forge/` 애드온 실코드 | 거의 없음 |
| 테스트 | unit + blend 샘플 | 없음 |
| 문서 | SPEC·빌드·회귀 충실 | 아키텍처·파이프라인 Draft |
| 별도 레포 | excelion-forge (Python) | 없음 |
| 실행 환경 | DEV_WORK 가능 | DEV_HOME (집) |

## 실무 권장 읽기 순서 (Git만)

1. `projects/excelion-forge/docs/15_ASSET_PIPELINE.md` — Export/Import 계약
2. `projects/excelion-forge/docs/13_UNREAL_ARCHITECTURE.md` — 게임 쪽 목표 구조
3. `docs/PLAYBOOKS/Unreal.md` + `core/checklists` — 공통 체크

실제 UE 프로젝트는 깃 밖(집 PC)에 있을 가능성 큼 → 있으면 경로만 `excelion/state`에 기록하는 편이 맞음.

## 한 줄

Unreal용으로 깃에서 참고할 “프로젝트”는 excelion-forge의 Unreal/파이프라인 문서 + excelion 게임 의도 문서이고, **UE 본체 프로젝트는 깃에 없다**.
