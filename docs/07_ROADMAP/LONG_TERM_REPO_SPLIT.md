# Long-term Repo Split — Platform vs Product

Date: 2026-07-31  
Status: **Planning only** (no git filter-repo, no force-push, no submodule migration yet)  
Related: P3 inventory · PROJECT_MAP · D20 · ACTIVE_TARGET = platform

---

## 1. Why

| Pain | Effect |
|------|--------|
| Monorepo mixes DevOS + large product trees | Token/context noise; wrong-tree edits |
| Product assets/history inflate Atlas | Clone cost; binary policy pressure |
| ACTIVE_TARGET discipline is social, not structural | Accidental product work on platform target |

Split is **structural** isolation after policy isolation (domain_policy, HOLD tags) is already Done.

---

## 2. Target layout (proposal)

| Repo | Owns | Does not own |
|------|------|----------------|
| **`ln9swrd/atlas`** (keep) | `docs/`, `state/`, `tools/`, `atlas-runtime/`, platform `core/` (non-product), `AGENTS.md`, ops | Product game/content trees |
| **`ln9swrd/excelion`** (new or extract) | `projects/excelion` content | Atlas DevOS kernel |
| **`ln9swrd/excelion-forge`** (new or extract) | Canonical Forge (D20) | Platform daily loop |
| Optional later | `printguard`, `coin-s` | — |

`archive/` stays on atlas (or `atlas-archive` later). No auto-load either way.

---

## 3. What stays in atlas (platform min)

```
docs/  state/  tools/  atlas-runtime/
core/          # only platform-relevant (see core/README.md)
AGENTS.md  config/  scripts/  tests/ (platform)
```

**Move out (when executing):**

- `projects/excelion/`
- `projects/excelion-forge/`
- product-coupled under `core/` (optional later: tools blender/ue, forge, vision, connectors)

**Hold in place until product ACTIVE_TARGET:** printguard, coin-s (small / submodule).

---

## 4. Phases (do not skip)

| Phase | Action | Risk | Gate |
|-------|--------|------|------|
| **S0** | This plan + Master confirm | None | **You are here** |
| **S1** | Tag `pre-split-atlas` on main | None | Master |
| **S2** | Dry-run path list + size report (no rewrite) | None | Cline local |
| **S3** | Create empty product repos + README + LICENSE mirror | Low | Master |
| **S4** | `git subtree split` or copy-history extract (choose one) | Med | Master + backup |
| **S5** | atlas: remove product paths; link in PROJECT_MAP | Med | domain_policy still green |
| **S6** | CI / clone smoke both repos | Low | Evidence |

**Forbidden in S0–S2:** filter-branch on main, force-push, deleting product without tag.

---

## 5. Decision points (Master)

1. **One product repo or two?** (excelion + forge separate recommended per D20)  
2. **History:** full extract vs fresh import + archive pointer?  
3. **Product-coupled `core/`:** move with forge, or leave tagged HOLD in atlas?  
4. **When:** only after next product ACTIVE_TARGET push, or before?

Default recommendation:

- Two repos: `excelion`, `excelion-forge`  
- History extract for forge if `.blend`/pipeline commits matter; else fresh + pointer  
- Leave `core/` product paths HOLD in atlas until forge repo consumes them  
- Execute split **before** long product sprint (cleaner), not mid-sprint

---

## 6. Success criteria

- [ ] atlas clone without `projects/excelion*` still runs `check_domain_policy` + `check_atlas_runtime`  
- [ ] product repos have own `README` + optional `state/`  
- [ ] PROJECT_MAP / DECISIONS point to new URLs  
- [ ] No silent dual-write of product sources in both places

---

## 7. Non-goals (this plan)

- Implementing product features  
- Rewriting SDK  
- Moving `archive/` off atlas  
- Submodule automation scripts beyond a one-line clone note

---

## 8. Immediate next (after Master pick)

| Choice | Next doc/action |
|--------|------------------|
| Confirm defaults in §5 | S1 tag only |
| Change 1–4 | Edit this file, then S1 |
| Defer split | CURRENT_STATE → idle; plan remains |
