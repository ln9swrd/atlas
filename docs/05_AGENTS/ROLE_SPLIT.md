# Role Split — 마스터 · Local Agent · Cloud (Sera)

Status: **Active** (updated 2026-08-04)  
Date: 2026-07-31 · D30 update 2026-08-04  
Related: D01, D15(**superseded**), D19, D21, **D30** · `docs/DECISIONS.md`

---

## Summary

| Actor | Does | Does not |
|-------|------|----------|
| **마스터 (Master)** | Goals, approval, Done judgment, **simple commands & shell scripts**, local env | Need to write all design/code alone |
| **Local agent** (optional) | Multi-step tools, file edits when Master enables a surface | Decide strategy alone; Done without Evidence; **not required** (D30) |
| **Cloud AI (Sera / Grok 등)** | Design, analysis, review, doc/Decision **drafts**, Git-ready edits via API | Invent Evidence; mark Done without Master |

Legacy name **SERA** = Cloud mode only — **not a project** (D19).  
호칭: 최종 권한자 = **마스터** (D21).

**D30 (2026-08-04):** Cline surface **미사용**. Primary = Git `state/` + Master + Cloud/agent as assigned. Cline 재도입 금지(명시 지시 전).

---

## 마스터 — capability

마스터 **can execute**:

- Simple one-off **shell commands**
- Short **shell scripts** (copy-paste blocks)
- Basic **git** sequences when given explicit steps
- Confirm pass/fail after checklist commands

마스터 **owns**:

- Final **Done** / merge / tag
- ACTIVE_TARGET and mode (`cloud` | `local-agent` | `both` — `cline` mode retired under D30)
- Decision log confirmation (G6 drafts → final)

**L-8 / L-9** may be run by 마스터 without a local agent.  
**L-10 F5** needs VS Code + Ollama on a suitable machine (optional; not required for platform idle).

---

## Local agent (optional — not primary)

- Historical primary was Cline + Ollama (D15) — **superseded by D30**
- If Master re-enables a local agent later: multi-file edits, iterative debug, Evidence into `state/`
- Not required for every git one-liner if 마스터 or Cloud API runs steps

---

## Cloud AI (Sera / Grok 등)

- Design / review / checklists / Decision **drafts**
- Git-ready output (create/update files, commits when authorized)
- Never claims local CLI Evidence it did not produce

---

## Heuristic

| Task type | Who |
|-----------|-----|
| One known command / short script | **마스터** |
| Multi-step coding / debug | Local agent **if enabled**, else Cloud + Master |
| Architecture, review, draft docs | **Cloud AI** |
| Done / merge / Decision final | **마스터** |
| F5 + Ollama UI | Dev PC (optional) |

## L-8…L-10

| ID | Preferred | Notes |
|----|-----------|-------|
| L-8 | **마스터** shell OK | |
| L-9 | **마스터** shell OK | |
| L-10 npm | 마스터 if Node | |
| L-10 F5 | Dev PC (optional) | |
| PR merge | **마스터** after Evidence | |

Checklist: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`  
G6 drafts: `docs/06_OPERATIONS/G6_DECISION_DRAFTS.md`
