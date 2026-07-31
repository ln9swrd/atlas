# Role Split — 마스터 · Cline · Cloud (Sera)

Status: **Active**  
Date: 2026-07-31  
Related: D01, D15, D19, D21 · `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`

---

## Summary

| Actor | Does | Does not |
|-------|------|----------|
| **마스터 (Master)** | Goals, approval, Done judgment, **simple commands & shell scripts**, local env | Need to write all design/code alone |
| **Cline** | Local agent loop, multi-step tools, file edits via agent, F5-assisted flows | Decide strategy alone; Done without Evidence |
| **Cloud AI (Sera)** | Design, analysis, review, doc/Decision **drafts** | Local git/npm/F5; mark Done; invent Evidence |

Legacy name **SERA** = Cloud mode only — **not a project** (D19).  
호칭: 최종 권한자 = **마스터** (D21).

---

## 마스터 — capability

마스터 **can execute**:

- Simple one-off **shell commands**
- Short **shell scripts** (copy-paste blocks)
- Basic **git** sequences when given explicit steps
- Confirm pass/fail after checklist commands

마스터 **owns**:

- Final **Done** / merge / tag
- ACTIVE_TARGET and mode (`cline` | `cloud` | `both`)
- Decision log confirmation (G6 drafts → final)

**L-8 / L-9** may be run by 마스터 without Cline.  
**L-10 F5** needs VS Code + Ollama on a suitable machine.

---

## Cline

- Primary when full agent loop is available
- Multi-file edits, iterative debug, orchestrator smoke
- Evidence into `state/` when finishing a unit

Not required for every git one-liner if 마스터 runs scripted steps.

---

## Cloud AI (Sera)

- Design / review / checklists / Decision **drafts**
- Git-ready output only
- Never claims local CLI Evidence it did not produce

---

## Heuristic

| Task type | Who |
|-----------|-----|
| One known command / short script | **마스터** (or Cline) |
| Multi-step agent coding / debug | **Cline** |
| Architecture, review, draft docs | **Sera** |
| Done / merge / Decision final | **마스터** |
| F5 + Ollama UI | Dev PC (마스터 or Cline assisted) |

## L-8…L-10

| ID | Preferred | Notes |
|----|-----------|-------|
| L-8 | **마스터** shell OK | |
| L-9 | **마스터** shell OK | |
| L-10 npm | 마스터 if Node | |
| L-10 F5 | Dev PC | |
| PR merge | **마스터** after Evidence | |

Checklist: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`  
G6 drafts: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md`
