# Atlas Platform Core Plan

> Status: Active  
> Date: 2026-07-31  
> Scope: **Atlas DevOS platform only** — individual product projects excluded until ACTIVE_TARGET reopens  
> Evidence base: `state/*`, `docs/DECISIONS.md`, `tools/*`, min-scope + P2 Done

---

## 0. One-line purpose

> Atlas is the **system that builds the products** (D02).  
> Min-scope (M1–M7) **Complete**. P2 hardening **Done**. Product work on hold until Master reopens ACTIVE_TARGET.

---

## 1. Current platform state (evidence)

| Item | Status | Evidence |
|------|--------|----------|
| MIN_SCOPE | **Complete** | `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md` |
| M1–M7 | **Done** | `state/TASK_MAP.md` |
| F1 domain_policy single source | **Done** | `tools/domain_policy.py` |
| F2 path escape / outside-WS deny | **Done** | `tools/check_domain_policy.py` |
| F4 runner assert_path_allowed | **Done** | `tools/atlas_runner.py` |
| F3 D24–D26 path hygiene | **Done** | D24 N/A; D25 OK; D26 policy lock (2026-07-31) |
| P2-1…P2-5 | **Done** | TASK_MAP |
| ACTIVE_TARGET | platform P2 | `state/CURRENT_STATE.md` |
| SERA as project | **Deprecated (D19)** | Cloud mode only |
| atlas-extension | **Deprecated (D22)** | do not revive |

---

## 2. Platform architecture (core only)

### 2.1 Fixed layers

| Layer | Role | Location |
|-------|------|----------|
| **Knowledge** | Docs, Decisions, ADRs | `docs/` |
| **State (SoR)** | Current work, maps | `state/` |
| **Tools** | Runner, domain policy, inventory | `tools/` |
| **Runtime kernel** | Contract, memory, event, decision, taskbroker | `core/`, `atlas-runtime/` |
| **Agents rules** | Evidence-First, domain split | `AGENTS.md`, `docs/05_AGENTS/` |
| **Black / Archive** | No auto-load | `archive/`, `obsidian/`, `node_modules/`, `.git/` |

### 2.2 Role split (D21)

| Actor | Owns |
|-------|------|
| **Master** | Goals, approval, Done, simple shell, merge |
| **Cline** | Local agent loop, multi-file edits, Evidence into state |
| **Cloud AI (Sera)** | Design, review, Decision drafts only |

### 2.3 Domain isolation (D17, D23)

- Active target from `state/CURRENT_STATE.md` only.
- VERIFY / tool paths: active `projects/<name>/` **or** Atlas system paths.
- BLACK: archive, obsidian, node_modules, .git — no auto context injection.
- Implementation: `tools/domain_policy.py` + runner/orchestrator (P2-1 Done).

### 2.4 Git as Source of Record

- Progress and decisions live in `state/` + `docs/DECISIONS.md`, not chat.
- Daily loop: `docs/06_OPERATIONS/DAILY_LOOP.md`.

---

## 3. Platform plan — phases

### Phase P0 — Stabilize

| ID | Task | Status |
|----|------|--------|
| P0-1 | Keep F1/F2/F4 green | **Done** |
| P0-2 | Do not reopen product ACTIVE_TARGET without Master | **Active rule** |
| P0-3 | Do not revive atlas-extension / SERA project | **Active rule** |

### Phase P1 — Path hygiene (F3)

| ID | Decision | Result |
|----|----------|--------|
| P1-1 | D24 Kraken | **N/A** — no code under `projects/kraken/` or `tools/kraken/` to move |
| P1-2 | D25 Sprint knowledge | **OK** — no Open SPRINT-009–029 in TASK_MAP |
| P1-3 | D26 Forge paths | **Policy Done** — canonical `excelion-forge`; `projects/forge/` legacy only; optional local `git mv` to archive later |

### Phase P2 — Platform hardening

| ID | Status |
|----|--------|
| P2-1 D23 VERIFY | **Done** |
| P2-3 CONTEXT_INDEX | **Done** |
| P2-4 DAILY_LOOP | **Done** |
| P2-5 Decision log | **Done** |

### Phase P3 — Runtime evolution

Align `core/` / `atlas-runtime/` without product coupling — when Master schedules.

### Phase P4 — Product reopen gate

Only when Master sets ACTIVE_TARGET to explicit product path.

---

## 4. Explicit non-goals

- Product feature work while ACTIVE_TARGET = platform
- Reviving atlas-extension or SERA-as-project
- Camera / real-world vision
- Chat as SoR

---

## 5. Success criteria

1. [x] Min-scope M1–M7 complete  
2. [x] F1/F2/F4 domain isolation operational  
3. [x] F3 path hygiene assessed/locked  
4. [x] P2 hardening Done  
5. [ ] Product work only after ACTIVE_TARGET change  

---

## 6. Immediate next

| Action | Who |
|--------|-----|
| idle or P3 schedule | Master |
| Optional: `git mv projects/forge archive/...` | Master local |

---

## 7. References

- `state/CURRENT_STATE.md` · `state/TASK_MAP.md` · `state/PROJECT_MAP.md`
- `docs/DECISIONS.md` · `docs/06_OPERATIONS/DAILY_LOOP.md` · `docs/06_OPERATIONS/DECISION_PROCESS.md`
- `tools/domain_policy.py` · `AGENTS.md`
