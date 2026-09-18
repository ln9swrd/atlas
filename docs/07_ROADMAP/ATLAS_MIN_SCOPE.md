# Atlas 최소 구현 범위 (Min Scope)

Status: **Complete (2026-07-31)** · surface note D30 (2026-08-04)  
Owner: 마스터  
Related: D15(**superseded**), D17, D21–D26, **D30**, rebuild plan §8

---

## 1. 한 줄

> Atlas DevOS **최소 루프(M1–M7) 달성**. 제품 프로젝트는 기본 **보류**.

---

## 2. 헌장 3요구 → 최소 구현

| # | 헌장 | 최소 구현 (at min complete) | 현재 (D30) | 하지 않음 |
|---|------|------------------------------|------------|-----------|
| 1 | 작업면 | Cline + Ollama (D15); extension 폐기 (D22) | **Cline 미사용**; Git state + Master + Cloud | custom extension |
| 2 | Git SoR | `state/*` 루프 + DAILY_LOOP | 동일 | 채팅 SoR |
| 3 | Perception | 저장소 파일 수준 | 동일 | 카메라/비전 |

---

## 3. M-* 결과

| ID | 항목 | Status |
|----|------|--------|
| M1 | state / CONTEXT / TASK | **Done** |
| M2 | AGENTS Evidence-First | **Done** |
| M3 | Cline + Ollama (당시 primary) | **Done** (historical); surface later D30 |
| M4 | DAILY_LOOP 실운용 | **Done** |
| M5 | G6 → D23–D26 | **Done** |
| M6 | tools inventory + smoke | **Done** |
| M7 | blacklist ↔ tools | **Done** |

---

## 4. 성공 기준

1. [x] README → state → TASK_MAP으로 현재 파악  
2. [x] Agent가 AGENTS + state로 세션 가능 (당시 Cline; 현재 Cloud/Master)  
3. [x] Done = Evidence (D01)  
4. [x] 활성 작업이 Atlas M-* 였음  

---

## 5. Post-min (선택 큐)

제품 재개 전 Atlas 쪽만 — **대부분 Done (F1–F4, P0–P3)**. 현재 ACTIVE_TARGET = **idle**.

| ID | 항목 | Note |
|----|------|------|
| F1–F4 | domain policy 등 | Done |
| P0+ | 제품 재개 | **HOLD** (Master) |

---

## Refs

`state/CURRENT_STATE.md` · `tools/DOMAIN_BLACKLIST.md` · `docs/DECISIONS.md` (D30)
