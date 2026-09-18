# PRODUCT_PRIORITY_REVIEW — 2026-08-09

> Priority only · **no implementation** · no story/setting/code change in this PR  
> Sources: CURRENT_STATE · TASK_MAP · MILESTONES · DESIGN_TASK_MAP · PLAYTEST_RESULT · Forge verify · Pipeline Spec

---

## 1. CURRENT ACTIVE / HOLD / DONE

| Bucket | Items |
|--------|--------|
| **DONE** | M0–M4 · B0–B6 · play design 6 steps · playtest scope · PHASE12_TUNING · EP matrix · Forge active-path deprecation (#50) · Pipeline Spec (docs) · Playtest result doc |
| **ACTIVE (claimed, conflicting)** | MILESTONES: **M5** visualization · DESIGN: ORD-GRUNT silhouette **Next** · CURRENT_STATE: **idle** |
| **OPEN / incomplete** | TASK_MAP: 1차 플레이테스트 실행 still **Open** (result doc exists → status lag) · Playtest **P1–P3** unfixed |
| **HOLD** | UE 실기 · Visualization **images/PNG** · ParaModel · M6 · excelion-forge (DEPRECATION) · Pipeline Spec G1–G7 TBD |

**SoR conflict (report only):** idle vs M5 Active vs ORD-GRUNT Next vs Playtest Open — not resolved in this review; recommend resolving **after** the single selected task lands.

---

## 2. Playtest improvements P1–P3

| ID | Item | Status | Risk if deferred |
|----|------|--------|------------------|
| **P1** | EP1 Kai seed unify: VERTICAL_SLICE/KAI_HABIT `「콜.」` vs EP1 script `「내리지 마.」` | **Open** | EP8 payoff hollow · canon dual source |
| **P2** | EP8 result UI: Mission clear ≠ Story loss | **Open** | Player misread (needs UI/proto later; can draft **copy/spec only** now) |
| **P3** | SETH_BATTLE Ashur residual → Nemesis | **Open** | Doc drift vs EPISODE_MATRIX / 09_STORY |
| P4 | Thin EP1 Heat teaching | Low · optional | — |
| P5 | Proto timing validate | After tools HOLD lift | — |

---

## 3. M5 / ORD-GRUNT / playtest execution

| Track | Stated state | Practical gate |
|-------|--------------|----------------|
| **M5** | Active in MILESTONES · THREEVIEW notes `ORDER` text reboot / image HOLD | PNG/image **HOLD** · CURRENT_STATE also Hold Visualization |
| **ORD-GRUNT** | DESIGN Next = silhouette **3 concepts (text)** | Text-only possible · does not fix canon |
| **1차 플레이테스트** | TASK Open · **RESULT doc exists** | Execution done as document/tabletop · follow-ups = P1–P3 |

---

## 4. Pipeline after Forge deprecation

| Check | Status |
|-------|--------|
| Active path | **Meshy → Blender → FBX → UE** (README · 07_PIPELINE · CURRENT_STATE · DESIGN note) |
| ACTIVE Forge path | **0** (verify doc) |
| Spec TBD G1–G7 | **Maintained** · not blocking text canon fixes |
| Blocks P1/P3? | **No** |
| Blocks M5 PNG? | Yes (image HOLD + Spec TBD) |

---

## 5. Comparison: P1–P3 vs M5 / ORD-GRUNT

| Criterion | P1 Kai seed | P3 Ashur scrub | P2 EP8 UI copy | ORD-GRUNT text 3안 | M5 image/threeview |
|-----------|--------------|----------------|----------------|--------------------|--------------------|
| Canon integrity | **High** | High | Medium (UX) | Low | Low |
| EP8 emotional dependency | **Direct** | Indirect | Direct UX | None | None |
| Needs Meshy/UE/image | No | No | No (spec only) | No | **Yes / HOLD** |
| Scope creep risk | Low (3 files) | Low | Medium (UI invent) | Medium (design expansion) | High |
| Unblocks later work | Seed LOCK for slice | Combat doc align | Proto UI | ORDER reboot | Art production |

**Objective rank for next single task:** P1 > P3 > P2(spec) > ORD-GRUNT text > M5 image.

---

## 6. Recommended work **1**

### **P1 — EP1 Kai seed line unification (docs only)**

**What:** Choose **one** EP1 seed line and mirror it in:

- `state/VERTICAL_SLICE_EP1_6_8.md`
- `state/EP1_EP8_SCENE_SCRIPT.md` (and related EP1 cuts if any)
- `state/KAI_HABIT_FIXED.md` (H1 definition)

**Default proposal for Master (not applied here):** keep **H1「콜.」** as global habit seed; set EP1 script to the same **or** explicitly document EP1 unique line + H1 first appearance EP6 — **Master picks one rule** in the implementation PR.

**Why first**

1. Documented **canon inconsistency** (playtest High)  
2. EP8 sacrifice quality depends on a **single** memorable seed  
3. No Forge/Meshy/UE/image · pure text alignment  
4. Smaller and more verifiable than ORD-GRUNT design expansion or M5 art  
5. M5/ORD remain valuable but do not fix story-system contradiction

---

## 7. Next-rank (HOLD until P1 PR done)

| Order | Item | Class |
|-------|------|-------|
| 2 | **P3** Ashur→Nemesis string scrub in SETH_BATTLE (+ related notes) | Docs |
| 3 | **P2** EP8 Mission vs Story result **copy/spec** (no UI code) | Docs |
| 4 | ORD-GRUNT silhouette **text** 3 concepts | Design |
| 5 | SoR status unify (TASK playtest→Done · CURRENT vs M5) | Ops |
| 6 | M5 / images | **HOLD** until Master lifts Visualization |
| 7 | Pipeline Spec G1–G7 / Meshy practical | **HOLD** |
| 8 | UE / M6 | **HOLD** |

---

## 8. Implementation forbidden (this phase & until Master approves the 1 task)

- Novel full prose rewrite  
- Mecha TEXT-LOCK redesign  
- Meshy / Blender add-on / UE code  
- Image / threeview PNG generation  
- Pipeline Spec TBD fill-in  
- excelion-forge delete/archive  
- Simultaneous multi-track PRs (P1+P3+ORD together)

---

## 9. Gate

```
Master approve recommended #1 (P1)
  → single docs PR
  → CI → approve → merge → SHA record
  → then P3 or SoR cleanup as next
```

**Status:** Priority review complete · implementation **not** started.
