# Atlas Platform Core Plan

> Status: Active  
> Date: 2026-07-31  
> Scope: **Atlas DevOS platform only** — individual product projects (excelion, excelion-forge, printguard, coin-s, etc.) **excluded**  
> Evidence base: `state/*`, `docs/DECISIONS.md`, `docs/ARCHITECTURE.md`, `tools/*`, min-scope complete

---

## 0. One-line purpose

> Atlas is the **system that builds the products** (D02).  
> Min-scope (M1–M7) is **Complete**. Platform hardening and optional path moves next; product work stays on hold until Master reopens ACTIVE_TARGET.

---

## 1. Current platform state (evidence)

| Item | Status | Evidence |
|------|--------|----------|
| MIN_SCOPE | **Complete** | `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md` |
| M1–M7 | **Done** | `state/TASK_MAP.md` |
| F1 domain_policy single source | **Done** | `tools/domain_policy.py` |
| F2 path escape / outside-WS deny | **Done** | `tools/check_domain_policy.py` |
| F4 runner assert_path_allowed | **Done** | `tools/atlas_runner.py` (SHA 87d476e+) |
| F3 D24–D26 path moves | **Pending** | optional |
| ACTIVE_TARGET | idle / F3 optional | `state/CURRENT_STATE.md` |
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
| **Runtime kernel** | Contract, memory, event, decision, taskbroker (existing code) | `core/`, `atlas-runtime/` |
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
- VERIFY / tool paths: active `projects/<name>/` **or** Atlas system paths (`state/`, `tools/`, allowed core).
- BLACK: archive, obsidian, node_modules, .git — no auto context injection.
- Implementation: `tools/domain_policy.py` + runner hooks (F1/F2/F4 Done).

### 2.4 Git as Source of Record

- Progress and decisions live in `state/` + `docs/DECISIONS.md`, not chat.
- Daily loop: read state → work → update state → commit (see `docs/06_OPERATIONS/DAILY_LOOP.md`).

---

## 3. Platform plan — phases

### Phase P0 — Stabilize (now)

**Goal:** Keep min-scope intact; no product work.

| ID | Task | Owner | Acceptance |
|----|------|-------|------------|
| P0-1 | Keep F1/F2/F4 green | Cline / Master | `python3 tools/check_domain_policy.py` PASS |
| P0-2 | Do not reopen product ACTIVE_TARGET | Master | CURRENT_STATE remains idle/F3 |
| P0-3 | Do not revive atlas-extension / SERA project | All | D19, D22 |

### Phase P1 — Optional path hygiene (F3)

**Goal:** Align paths with D24–D26 when Master schedules time. **Not blocking.**

| ID | Decision | Action | Notes |
|----|----------|--------|-------|
| P1-1 | D24 Kraken | Prefer `tools/kraken/` if any code exists; never `projects/kraken/` | Name = layer, not product |
| P1-2 | D25 Sprint knowledge | Past SPRINT-009~029 stay archive only | No Open tasks |
| P1-3 | D26 Forge phase paths | Product Forge = `projects/excelion-forge/` only; legacy `projects/forge/` / nested stubs → archive or delete later | **Product work still deferred** |

Acceptance: path moves documented + Evidence in state; no breakage of domain_policy / runner.

### Phase P2 — Platform hardening (post-F3 or parallel)

**Goal:** Strengthen DevOS loop without product features.

| ID | Task | Priority | Notes |
|----|------|----------|-------|
| P2-1 | D23 full VERIFY CWD jail | Medium | Orchestrator / Cline tool side; partial today |
| P2-2 | tools inventory keep current | Low | M6 Done; refresh on tool add |
| P2-3 | CONTEXT_INDEX slim | Medium | Token budget; active target only |
| P2-4 | DAILY_LOOP real use | High | Master/Cline habit |
| P2-5 | Decision log discipline | High | Drafts → Master confirm → DECISIONS.md |

### Phase P3 — Runtime evolution (v1.3 → v2.0 direction)

**Goal:** Align existing `core/` / `atlas-runtime/` with documented roadmap **without** product coupling.

| Horizon | Focus | Source |
|---------|-------|--------|
| Near | Execution runtime: daily ops, task executor clarity | `docs/ROADMAP.md` v1.3 |
| Mid | Event bus / SDK, memory mapping, events log | ROADMAP Phase 1 |
| Later | Model-agnostic AI gateway, sandboxed app host | ROADMAP Phase 2–3 |

Rules:

- No feature work that assumes excelion/printguard as driver until Master sets ACTIVE_TARGET.
- Prefer Evidence-First unit tests under `tests/` / `core/tests/`.
- Knowledge stays in Git docs; session runtime may be disposable (D03).

### Phase P4 — Product reopen gate

**Only when Master decides:**

1. CURRENT_STATE ACTIVE_TARGET = explicit product path (e.g. excelion-forge).
2. Domain policy still enforces BLACK + active target.
3. Min-scope invariants remain (Evidence-First, state SoR, ROLE_SPLIT).

Until then: **platform only**.

---

## 4. Explicit non-goals (platform plan)

- Implementing or expanding product projects (excelion, forge product pipeline, printguard, coin-s).
- Reviving atlas-extension or SERA-as-project.
- Camera / real-world vision (Perception NON_GOALS).
- Treating chat as SoR.
- Coding on archive/obsidian as live sources.

---

## 5. Success criteria (platform)

1. [x] Min-scope M1–M7 complete  
2. [x] F1/F2/F4 domain isolation operational  
3. [ ] F3 path moves done or explicitly deferred by Master  
4. [ ] P2 hardening items tracked in TASK_MAP with Evidence  
5. [ ] Product work only after ACTIVE_TARGET change + gate above  

---

## 6. Immediate next actions

| Order | Action | Who |
|-------|--------|-----|
| 1 | Confirm this plan in Git (this file) | Master |
| 2 | Choose: **idle** or schedule **F3** | Master |
| 3 | If F3: small commits, Evidence in state | Cline + Master |
| 4 | Else: keep P0; optional P2-1 / P2-3 | as capacity |

---

## 7. References

- `state/CURRENT_STATE.md` · `state/TASK_MAP.md` · `state/PROJECT_MAP.md`
- `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md`
- `docs/DECISIONS.md` (D01–D26)
- `docs/05_AGENTS/ROLE_SPLIT.md`
- `docs/ARCHITECTURE.md`
- `docs/ROADMAP.md`
- `tools/domain_policy.py` · `tools/INVENTORY.md` · `tools/DOMAIN_BLACKLIST.md`
- `AGENTS.md`

---

*End of platform plan. Product project plans live under `projects/<id>/` and are out of scope here.*
