# Forge DEPRECATION Survey — 2026-08-09

> Scope: `projects/excelion/` only · **no deletion** · no Meshy/Blender/UE implementation  
> Status target: `ln9swrd/excelion-forge` **HOLD → DEPRECATION CANDIDATE** (decision-ready)

---

## 1. Conclusion (decision-ready)

| Decision | Recommendation |
|----------|----------------|
| excelion-forge repo | **DEPRECATION CANDIDATE** — do not resume as primary pipeline |
| Immediate delete | **Forbidden** this phase |
| In-tree Excelion code dependency on Forge | **None found** (docs/status/backlog references only) |
| Replacement direction | Meshy AI → 3D model → Blender (rig/pose/motion) → Export → UE |

---

## 2. Reference inventory (Excelion tree)

Code search `forge path:projects/excelion` → **13 files** (all documentation / backlog).

| Path | Role of mention |
|------|-----------------|
| `README.md` | Pipeline = `ln9swrd/excelion-forge` (**HOLD**) |
| `PROJECT_CHARTER.md` | Visualization · Forge · ParaModel **HOLD** |
| `ENVIRONMENT_PLAN.md` | Forge / Unreal pipeline **HOLD** |
| `docs/07_PIPELINE.md` | Sister project: excelion-forge = Blender/Unreal pipeline |
| `docs/DOC_MAP.md` | Sister: excelion-forge (HOLD) |
| `docs/PROJECT_SUMMARY.md` | Forge / ParaModel / 시각화 = HOLD |
| `state/CURRENT_STATE.md` | Hold: Forge · UE · Visualization |
| `state/CONTEXT_INDEX.md` | External: excelion-forge = 파이프라인 |
| `state/DESIGN_TASK_MAP.md` | HOLD includes Forge |
| `state/PLAYTEST_SCOPE_*.md` | Forge / engine practical = Hold |
| `state/BALANCE_PLAN_*.md` | Out of scope: Forge |
| `design/MECHA_STATUS.md` | HOLD = image · modeling · Forge |
| `backlog.json` | status HOLD · note paramodel·forge 중단 · assignee_role "Forge + …" |

### Not found inside Excelion

- No `import` / build script / CI step pointing at excelion-forge
- No binary assets labeled as Forge outputs under `projects/excelion/` (assets tree is placeholders / design refs)
- No runtime coupling: product SoR is text + HTML prototype only

---

## 3. Preserve vs discard

### Preserve (knowledge / process)

| Item | Why |
|------|-----|
| Pipeline *intent* in `docs/07_PIPELINE.md` | Blender → rig → anim → UE flow still valid conceptually |
| ENVIRONMENT split (company vs home PC) | Still useful after tool change |
| TEXT-LOCK design docs (mecha / character / combat) | Independent of Forge |
| Any future audit of standalone `excelion-forge` repo: README, export conventions, FBX naming | Capture **before** archive |

### Discard / stop using (after Master approve)

| Item | Action (later PR) |
|------|-------------------|
| Primary path `ln9swrd/excelion-forge` | Mark DEPRECATION · Archive recommended |
| backlog roles "Forge + …" | Reassign to Blender/Meshy owner roles |
| Docs listing Forge as active sister | Rewrite to Meshy→Blender→UE |
| ParaModel as Forge-coupled track | Keep HOLD / separate decision |

### Unknown (requires optional external audit)

| Item | Note |
|------|------|
| Models / rigs already committed **inside** `excelion-forge` remote | Not in Excelion tree · audit that repo before delete |
| Local-only Forge outputs | Operator machine only · not verifiable here |

---

## 4. Replacement pipeline — document validation only

Proposed flow:

```
Meshy AI → 3D model → Blender Add-on → Rig / Pose / Motion → Export → UE
```

| Stage | Responsibility | Expected I/O (proposal) |
|-------|----------------|-------------------------|
| Meshy AI | Base mesh generation from concept/ref | In: concept / text / image · Out: mesh (OBJ/FBX/GLB) |
| Blender (+ add-on later) | Cleanup · scale · materials · **rig** · pose · motion | In: mesh · Out: rigged FBX/glTF |
| Rig ownership | **Blender** (human + add-on assist) | Skeleton convention TBD · match UE skeleton policy |
| Pose / Motion ownership | **Blender** (not Forge) | Action strips / NLA · export animation takes |
| Export | Blender export preset | **FBX** (primary for UE) · optional glTF for review |
| UE | Import · Animation Blueprint · gameplay | In: FBX · Out: playable asset in project |

### Does this replace Forge roles?

| Former Forge role | Replacement |
|-------------------|-------------|
| Mesh authoring automation | Meshy (generation) + Blender cleanup |
| Parametric / scripted mesh | Deferred (ParaModel HOLD) |
| Rig / pose / motion | Blender |
| UE handoff | FBX export → UE import |

**Gap (not implemented now):** exact unit scale, bone names, root motion policy, Meshy license/workflow, Blender add-on scope.

---

## 5. Recommended next order (after Master)

1. Optional: inventory `ln9swrd/excelion-forge` remote assets → preserve list
2. Docs PR: HOLD → DEPRECATION CANDIDATE wording · pipeline rewrite
3. Archive / freeze excelion-forge (no resume)
4. Only then: Meshy/Blender practical experiments (still no product settings change)

---

## 6. Explicit non-actions this PR

- No Forge deletion
- No UE / Meshy / Blender add-on code
- No image generation
- No mecha/character TEXT-LOCK changes
