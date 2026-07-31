# Role Split — Human · Cline · Cloud (Sera)

Status: **Active**  
Date: 2026-07-31  
Related: D01, D15, D19 · `docs/07_ROADMAP/CLOUD_AI_VSCODE_EXEC_PLAN.md`

---

## Summary

| Actor | Does | Does not |
|-------|------|----------|
| **Human (Master)** | Goals, approval, Done judgment, **simple commands & shell scripts**, local env | Need to write all design/code alone |
| **Cline** | Local agent loop, multi-step tools, file edits via agent, F5-assisted flows | Decide strategy alone; Done without Evidence |
| **Cloud AI (Sera)** | Design, analysis, review, doc/Decision **drafts** | Local git/npm/F5; mark Done; invent Evidence |

Legacy name **SERA** = Cloud mode only — **not a project** (D19).

---

## Human — expanded capability (2026-07-31)

Human **can execute**:

- Simple one-off **shell commands**
- Short **shell scripts** (copy-paste blocks)
- Basic **git** sequences when given explicit steps (fetch, checkout, rm --cached, commit, push)
- Confirm pass/fail after running a checklist command

Human **still owns**:

- Final **Done** / merge / tag approval
- ACTIVE_TARGET and mode (`cline` | `cloud` | `both`)
- Decision log confirmation

This means **L-8 / L-9** (rebase + packaging untrack) may be run by **Human** without Cline, if the machine has git and the repo clone.

**L-10 F5** still needs VS Code Extension Host + Ollama on a suitable machine (often home/dev PC). Human may run `npm install` / `npm run compile` where Node is available; F5 UI checks remain environment-dependent.

---

## Cline

- Primary when full agent loop is available (home/dev)
- Preferred for multi-file edits, iterative debug, orchestrator smoke via agent
- Writes Evidence into `state/` when finishing a unit

Not required for every single git one-liner if Human runs the scripted steps.

---

## Cloud AI (Sera)

- Design / review / checklists / Decision **drafts**
- Output must be Git-ready (md, patch proposal, issue comment text)
- Never claims local CLI Evidence it did not produce

---

## Work assignment heuristic

| Task type | Who |
|-----------|-----|
| One known command / short script | **Human** (or Cline if already in session) |
| Multi-step agent coding / debug | **Cline** |
| Architecture, review, draft docs | **Sera** |
| Done / merge / Decision final | **Human** |
| F5 Extension Host + Ollama UI | Machine with VS Code + model (**Human** or **Cline** assisted) |

---

## L-8…L-10 mapping

| ID | Preferred executor | Notes |
|----|--------------------|-------|
| L-8 rebase | **Human** shell OK | Or Cline |
| L-9 untrack + push | **Human** shell OK | Or Cline |
| L-10 npm/compile | **Human** if Node available | |
| L-10 F5 checklist | Dev PC (Human/Cline) | Company may block |
| PR merge + tag | **Human** after Evidence | |

Checklist: `docs/06_OPERATIONS/L8_L10_CLOUD_REVIEW.md`
