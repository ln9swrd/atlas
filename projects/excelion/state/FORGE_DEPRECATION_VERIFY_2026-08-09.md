# FORGE_DEPRECATION_VERIFY — 2026-08-09

> Verification only · no implementation · no external repo change  
> Main HEAD at verify time: **`1c664f55`** (merge PR **#50**)

---

## Verdict

| Check | Result |
|-------|--------|
| **ACTIVE FORGE REFERENCE** | **0** |
| Active production path consistent | **Yes** — Meshy → Blender → FBX → UE |
| Code / CI / env Forge dependency (Excelion) | **0** |
| External `ln9swrd/excelion-forge` | **Preserved** (not deleted / not archived) |
| `MESHY_BLENDER_PIPELINE_SPEC` TBD (G1–G7) | **Unchanged** |
| Forge deprecation work (Excelion active path) | **COMPLETE** |

---

## 1. Method

- PR #50 merged into main (`1c664f55`)
- Spot-check canonical files on main: `README.md`, `docs/07_PIPELINE.md`, `backlog.json`
- Code search / prior audits: no Excelion runtime import, CI job, or env var binding to Forge
- Remaining string hits classified below (allow / remove / TBD)

---

## 2. Active path consistency

| File | Active pipeline wording |
|------|-------------------------|
| `README.md` | **Meshy AI → Blender → FBX → UE** · Snapshot 파이프라인 동일 |
| `docs/07_PIPELINE.md` | 활성 흐름 = Meshy → mesh → Blender → FBX → Unreal |
| `PROJECT_CHARTER.md` | Active production path = Meshy… (from #50) |
| `ENVIRONMENT_PLAN.md` | Active: Meshy… |
| `docs/PROJECT_SUMMARY.md` | 활성 Meshy… |
| `state/CURRENT_STATE.md` | Pipeline Active: Meshy… |
| `backlog.json` | `Active pipeline = Meshy→Blender→FBX→UE` · roles Blender/UE only |

**Inconsistency found:** none on active path.

---

## 3. Classification of remaining Forge strings

### 허용 (역사 / DEPRECATION / 보존)

| Location | Nature |
|----------|--------|
| `README.md` | `excelion-forge` = **DEPRECATION CANDIDATE** · 비활성 · 보존 · 삭제 금지 |
| `docs/07_PIPELINE.md` | related 표: DEPRECATION CANDIDATE · 자산 보존 |
| `docs/DOC_MAP.md` | Legacy pipeline row · 비활성 |
| `state/CONTEXT_INDEX.md` | External DEPRECATION · Forbidden: 재활성 금지 |
| `state/CURRENT_STATE.md` / `DESIGN_TASK_MAP.md` | deprecation note |
| `PROJECT_CHARTER.md` · `ENVIRONMENT_PLAN.md` · `PROJECT_SUMMARY.md` | non-primary wording |
| `backlog.json` note | “구 forge 경로 폐기 후보” (historical) |
| `state/FORGE_DEPRECATION_SURVEY_*.md` | audit record |
| `state/FORGE_REMOVAL_SCOPE_*.md` | scope record |
| `state/MESHY_BLENDER_PIPELINE_SPEC.md` | premise: forge = DEPRECATION CANDIDATE |
| External repo `ln9swrd/excelion-forge` | assets/docs/addon **preserved** |

### 제거 (활성 경로·역할) — post-#50

| Expected | Status |
|----------|--------|
| Pipeline primary = `excelion-forge` | **Gone** |
| `assignee_role: "Forge*"` | **Gone** (Blender / UE) |
| HOLD list treating Forge as active workstream parallel to production | **Gone** from must-touch set |

**ACTIVE FORGE REFERENCE count: 0**

### TBD (Pipeline Spec only — not filled)

| ID | Item | Status |
|----|------|--------|
| G1–G7 | Blender/UE version · bone table · FBX preset · root motion · fps · skin/anim split | **TBD maintained** |
| Spec body | No change in this verify PR | OK |

---

## 4. Code / CI / env re-check

| Class | Result |
|-------|--------|
| Excelion Python/JS importing forge | **None** |
| Excelion CI workflow step on forge | **None** |
| Excelion env vars for forge | **None** |
| backlog executable coupling | **None** (JSON roles only) |

Atlas-wide `tools/domain_policy.py` product id `excelion-forge` remains platform concern · **outside Excelion active-path deprecation** · optional later platform PR.

---

## 5. External assets

| Action | Status |
|--------|--------|
| Delete `ln9swrd/excelion-forge` | **Not done** (forbidden) |
| GitHub Archive | **Not done** (forbidden this phase) |
| Preservation stance | **Confirmed** in Excelion docs |

---

## 6. Additional actions?

| Item | Needed now? |
|------|-------------|
| Further Excelion doc scrub of DEPRECATION strings | **No** (allowed residual) |
| Fill Pipeline Spec TBD | **No** until Master chooses implementation |
| External repo archive | **Optional later** · Master |
| Atlas platform pointer cleanup | **Optional later** · not Excelion product block |
| Resume Excelion product priority | **Yes** — deprecation complete |

---

## 7. Closure

```
ACTIVE FORGE REFERENCE = 0
ACTIVE PATH = Meshy → Blender → FBX → UE
EXTERNAL FORGE ASSETS = PRESERVED
PIPELINE SPEC TBD = MAINTAINED
FORGE DEPRECATION (Excelion active path) = COMPLETE
```

Next workstream: Excelion product priorities (playtest follow-ups, design queue, etc.) — not Forge.
