# Atlas 최소 구현 범위 (Min Scope)

Status: **Active**  
Date: 2026-07-31  
Owner: 마스터  
Related: Charter (README), D15, D21, D22, rebuild plan §8

---

## 1. 한 줄

> **지금 집중 = Atlas DevOS가 혼자 돌아가는 최소 루프**  
> 개별 제품(`excelion-forge`, PrintGuard 등)은 **보류**.

---

## 2. 헌장 3요구 → 최소 구현 해석

| # | 헌장 | 최소 구현 (지금) | 하지 않음 |
|---|------|------------------|-----------|
| 1 | VS Code + 로컬 LLM 작업면 | **Cline + Ollama** (D15). 커스텀 extension **폐기(D22)** | atlas-extension, cloud-only IDE |
| 2 | Git = 상태·컨텍스트 | `state/*` 읽기→작업→갱신→commit 루프 유지 | 채팅을 SoR로 쓰기 |
| 3 | Code/Screen/Image, 카메라=0 | 문서 범위 고정. 코드는 **저장소 파일 읽기** 수준 | 비전/카메라 파이프라인 |

---

## 3. In scope (Atlas only)

| ID | 항목 | 상태 | 비고 |
|----|------|------|------|
| M1 | `state/` + `CONTEXT_INDEX` + `TASK_MAP` 운영 | **Done** | 세션마다 갱신 |
| M2 | `AGENTS.md` 도메인 분리 · Evidence-First | **Done** | Cline instructions |
| M3 | Cline + Ollama 로컬 루프 (L-1…L-7) | **Done** | |
| M4 | 일 세션 루프 문서 (`DAILY_LOOP`) | **Partial** | docs phase 문구 → 실운용에 맞게 보강 가능 |
| M5 | G6 정책 확정 (#4–#7) | **Draft** | 구현 전 **결정만** 가능 |
| M6 | `tools/` 중 **실제 쓰는** CLI만 점검 (runner/orchestrator) | **Pending** | 존재하는 것 목록 + 동작 1회 Evidence |
| M7 | Domain blacklist가 도구 경로에 반영됐는지 | **Pending** | archive/obsidian 비주입 |

---

## 4. Out of scope (지금)

- `projects/excelion-forge` T-1 실행·Blender 검증
- PrintGuard / Coin-S / excelion 제품 기능
- atlas-extension / PR #3
- `core/` · `atlas-runtime/` 대규모 재작성
- 카메라·비전·클라우드 강제 연동
- SERA 프로젝트 재개 (D19)

제품 작업은 Atlas 최소 루프가 **안정**된 뒤로 미룬다.

---

## 5. 성공 기준 (최소)

1. 클론 후 README → `state/CURRENT_STATE` → `TASK_MAP` 만으로 “지금 뭐 하는지” 파악 가능  
2. Cline 세션이 `AGENTS.md` + `state/` 만으로 시작·종료·commit 가능  
3. Done 주장은 CLI/파일 Evidence 없이 없음  
4. 활성 작업이 `projects/*` 제품이 아니라 **Atlas 시스템 태스크(M*)** 임  

---

## 6. 다음 한 가지 (권장 순서)

1. **M6** — `tools/` 목록 작성 + 마스터/Cline이 돌릴 수 있는 명령 1개 Evidence  
2. **M5** — G6 중 Atlas에 직접인 것만 승인 (특히 #4 VERIFY, #5 Kraken 경로 정책)  
3. **M4** — `DAILY_LOOP`를 “docs only”가 아닌 실 Cline 세션용으로 한 페이지 정리  

---

## 7. Refs

- `docs/07_ROADMAP/ATLAS_GIT_REBUILD_PLAN.md` §8 의도적 미룸  
- `docs/DECISIONS.md` D15 D19 D21 D22  
- `state/CURRENT_STATE.md` · `state/TASK_MAP.md`  
