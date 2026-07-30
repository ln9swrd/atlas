# G6 Open Q Drafts (2026-07-30)

## 1. Issue #4 — VERIFY 범위
- VERIFY 대상 후보:  
  - `projects/excelion-forge/state/mission_design.md`  
  - `docs/07_COMBAT_SYSTEM.md`  
  - `core/decision/forge_phase_1.py`  
- 추천 MVP:  
  "Combat System 문서화 및 Phase 1 기능 검증"  
- 선택: **문서만**  
  - 구현 대신 문서 기반 검증으로 시간 절약  
  - 기존 `docs/07_COMBAT_SYSTEM.md` 완성도 높음  
- 근거:  
  `docs/07_COMBAT_SYSTEM.md` (line 123-145)  
  `core/decision/forge_phase_1.py` (line 8)  

Status: DRAFT — owner 확정 전

---

## 2. Issue #6 — SPRINT-009~029
| SPRINT | 경로 | 추정상태 |
|-------|------|---------|
| SPRINT-009 | `docs/024_Atlas_SPRINT-009_Self-Improvement_Engine.md` | 문서만 |
| SPRINT-015 | `docs/summary/015_Cline_병렬_툴콜_및_서브에이전트_최적설정_가이드.md` | 부분 |
| SPRINT-028 | `docs/summary/028_콘텐츠_자동생산_시스템_1단계.md` | 폐기후보 |

- 유지 후보:  
  - SPRINT-009: 문서 기반 검증 완료  
  - SPRINT-015: 부분 구현 (tool_call 최적화)  
- 폐기 후보:  
  - SPRINT-028: 자동생산 시스템 기획 중단  

Status: DRAFT — owner 확정 전

---

## 3. Issue #7 — Forge Phase 1→2
- Phase 1 완료 체크리스트:  
  1. `projects/excelion-forge/state/mission_design.md` 작성 완료 ✅  
  2. `docs/07_COMBAT_SYSTEM.md` 검증 완료 ✅  
  3. `core/decision/forge_phase_1.py` 승인 완료 ✅  
  4. `projects/excelion-forge/tools/atlas_runner.py` 초기 구현 ✅  
  5. `docs/12_PROJECT_STRUCTURE.md` 업데이트 ✅  
- D05 ROI Gate 연결:  
  `docs/09_GAME_LOOP.md` (line 45)  
- 기록 위치 제안:  
  `projects/excelion-forge/state/phase_1_completion.md`  
- D20 준수:  
  Canonical = `projects/excelion-forge/` only  

Status: DRAFT — owner 확정 전