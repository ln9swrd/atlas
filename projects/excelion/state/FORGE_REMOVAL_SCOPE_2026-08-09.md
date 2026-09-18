# FORGE_REMOVAL_SCOPE — 2026-08-09

> Audit only · **no delete · no code change**  
> Inputs: Excelion tree search · `ln9swrd/excelion-forge` inventory · `MESHY_BLENDER_PIPELINE_SPEC` · prior DEPRECATION survey  
> MESHY_BLENDER_PIPELINE_SPEC TBD items remain **TBD** (not closed here)

---

## 1. Executive summary

| Question | Answer |
|----------|--------|
| Does `projects/excelion/` contain Forge **code**? | **No** |
| Does it depend on Forge at build/CI runtime? | **No** (docs + backlog text only) |
| Can Meshy→Blender→FBX→UE replace the *role*? | **Yes for intent** · G1–G7 still TBD |
| Safe immediate action | Docs reword + backlog role rename inside Excelion |
| Unsafe now | Delete `ln9swrd/excelion-forge` · Atlas platform refs without policy PR |

---

## 2. Excelion internal reference inventory

### 2.1 Code / CI / env / scripts

| Class | Result |
|-------|--------|
| Python/JS under `projects/excelion/` | **0** Forge imports / paths |
| CI workflows scoped to Excelion | **0** Forge jobs found in-tree |
| Environment variables | **0** in Excelion docs (ENV plan text only) |
| Executable scripts calling forge | **0** |

### 2.2 Documents & config (path = `projects/excelion/`)

| Path | Kind |
|------|------|
| `README.md` | Active pipeline pointer `ln9swrd/excelion-forge` HOLD |
| `PROJECT_CHARTER.md` | HOLD list |
| `ENVIRONMENT_PLAN.md` | Forge/Unreal HOLD note |
| `docs/07_PIPELINE.md` | Sister project table |
| `docs/DOC_MAP.md` | Sister link |
| `docs/PROJECT_SUMMARY.md` | Pipeline HOLD |
| `state/CURRENT_STATE.md` | Hold line |
| `state/CONTEXT_INDEX.md` | External table |
| `state/DESIGN_TASK_MAP.md` | HOLD list |
| `state/PLAYTEST_SCOPE_2026-08-06.md` | Hold method |
| `state/BALANCE_PLAN_2026-08-06.md` | Out-of-scope note |
| `design/MECHA_STATUS.md` | HOLD legend |
| `backlog.json` | status HOLD · note · `assignee_role: "Forge + …"` |
| Survey/spec already added | `FORGE_DEPRECATION_SURVEY_*` · `MESHY_BLENDER_PIPELINE_SPEC` |

**Classification of these paths:** not binary assets — **edit/reword candidates** on a future removal PR, not filesystem delete of product content.

---

## 3. External repo audit — `ln9swrd/excelion-forge`

HEAD observed: `dbb83a7…` · README: Blender add-on for Excelion 3D action pipeline.

### Top-level layout

| Path | Nature |
|------|--------|
| `excelion_forge/` | Python package (adapters, core, operators, plugins, runtime, ui, utils, properties) |
| `scripts/` | `build_addon.py`, dependency graph tools, `scripts/blender/` |
| `blender/` | `assets/`, `reference/`, `scripts/` |
| `docs/` | Large design + pipeline set (incl. `15_ASSET_PIPELINE`, `20_ADDON_BUILD_GUIDE`, UE architecture, SPEC) |
| `state/` | Forge CURRENT_STATE / TASK_MAP |
| `tests/`, `src/`, `typestubs/` | Test/support |
| `pyproject.toml`, `uv.lock` | Packaging |
| `.github/` | CI for Forge |
| Aider/agent caches | Tooling noise |

### Preserve candidates (do not destroy without copy)

| Target | Reason |
|--------|--------|
| `docs/15_ASSET_PIPELINE.md` · `20_ADDON_BUILD_GUIDE.md` · `13_UNREAL_ARCHITECTURE.md` · `SPEC.md` | Pipeline knowledge transferable to Meshy/Blender/UE |
| `docs/01_*`–game design siblings | May **overlap/conflict** with Excelion SoR — **read-only compare** before any merge |
| `blender/assets` · `blender/reference` | Possible original meshes/refs |
| Any `.blend` / FBX if present under blender paths | Originals |
| Rig validation ideas in `excelion_forge/core` · operators | Optional future Blender tooling reference |

### Discard / stop-as-primary candidates (after archive)

| Target | Reason |
|--------|--------|
| Active development of `excelion_forge` add-on as **Excelion primary path** | Replaced by Meshy→Blender contract |
| Forge CI as gate for Excelion product | No Excelion CI coupling today |
| Local path scripts (e.g. absolute `D:\Excelion\…excelion-forge\…`) | Machine-specific |
| Aider history / caches | Non-product |

### TBD (external)

| Item | Need |
|------|------|
| Full file list under `blender/assets` (binary inventory) | Size/type listing before archive |
| Whether any asset is **only** copy of Excelion-canon mesh | Compare to `projects/excelion/assets` |
| GitHub Archive vs delete | Master policy |

**This audit does not delete the external repo.**

---

## 4. Role vs new pipeline

| Former Forge role | Meshy→Blender→FBX→UE | Gap |
|-------------------|----------------------|-----|
| Mesh generation assist | Meshy + Blender cleanup | OK intent |
| Blender add-on operators | Manual Blender until new add-on | **TBD** tooling |
| Rig validation package | Human + future checks | **TBD** G3 bone table |
| Asset pipeline docs | Keep knowledge · new SoR = MESHY_BLENDER_PIPELINE_SPEC | OK |
| UE handoff | FBX contract §7–8 | **TBD** G4 export preset |
| ParaModel coupling | HOLD · out of this removal | TBD separate |

Pipeline Spec **G1–G7 remain TBD** — not closed in this document.

---

## 5. Classification table (required)

| 분류 | 대상 | 근거 | 처리 |
|------|------|------|------|
| **DELETE** | Excelion 문서에서 *활성 주 경로*로 가리키는 Forge 문구 | Meshy/Blender 계약으로 대체 가능 | 향후 제거 PR에서 **문구 치환/삭제** (파일 자체 유지) |
| **DELETE** | `backlog.json` 의 `assignee_role: "Forge + …"` / forge 중단 노트 중 *활성 역할* 의미 | 역할 폐기 | 역할 문자열 재명명 (예: Blender/Meshy) |
| **DELETE** | (외부, 별도 승인) Forge를 Excelion **필수 의존**으로 두는 운영 가정 | 런타임 의존 없음 | 레포 Archive 후보 — **이번 PR 비범위** |
| **KEEP** | `projects/excelion/**` 스토리·디자인·밸런스·플레이테스트 문서 | 제품 SoR | 보존 · 이번 작업 미수정 |
| **KEEP** | `MESHY_BLENDER_PIPELINE_SPEC.md` · DEPRECATION survey | 대체 계약 | 보존 · TBD 유지 |
| **KEEP** | excelion-forge `docs/*` pipeline/addon 가이드 (외부) | 재사용 지식 | 삭제 전 보존/아카이브 |
| **KEEP** | excelion-forge `blender/assets` · `reference` (외부) | 원본 가능 | 인벤토리 후 보존 |
| **KEEP** | Atlas `archive/projects-forge-legacy/**` | 역사 기록 | 보존 |
| **TBD** | Pipeline Spec G1–G7 (버전·본표·FBX 프리셋·root motion·fps…) | 계약 미확정 | **유지 TBD** · 임의 확정 금지 |
| **TBD** | excelion-forge Python add-on 재사용 여부 | 대체 도구 미구현 | 추가 검증 후 폐기/이식 |
| **TBD** | Atlas 루트 `tools/domain_policy.py` 등 `excelion-forge` product id | 플랫폼 정책 | **Excelion 제거 PR 밖** · 별도 플랫폼 PR |
| **TBD** | `docs/GLOSSARY` · `state/PROJECT_MAP` · `projects/README` Forge 표기 | Atlas 전역 | 플랫폼 일괄 정리 시 |
| **TBD** | Forge `docs/01–10` 게임 설정 vs Excelion TEXT-LOCK 충돌 여부 | 이중 SoR 위험 | 읽기 전용 대조 후 폐기 또는 무시 |

---

## 6. Exact file list for **future** Forge-removal PR (Excelion tree only)

**Mode:** edit text · **not** delete these files · **no** story/design/playtest content changes beyond Forge pointer lines.

### Must-touch (pointer / HOLD / role)

1. `projects/excelion/README.md`  
2. `projects/excelion/PROJECT_CHARTER.md`  
3. `projects/excelion/ENVIRONMENT_PLAN.md`  
4. `projects/excelion/docs/07_PIPELINE.md`  
5. `projects/excelion/docs/DOC_MAP.md`  
6. `projects/excelion/docs/PROJECT_SUMMARY.md`  
7. `projects/excelion/state/CURRENT_STATE.md`  
8. `projects/excelion/state/CONTEXT_INDEX.md`  
9. `projects/excelion/state/DESIGN_TASK_MAP.md`  
10. `projects/excelion/backlog.json`  

### Optional touch (historical “Forge” word only — low priority)

11. `projects/excelion/state/PLAYTEST_SCOPE_2026-08-06.md`  
12. `projects/excelion/state/BALANCE_PLAN_2026-08-06.md`  
13. `projects/excelion/design/MECHA_STATUS.md`  

### Explicitly **out** of Excelion removal PR

- Any path outside `projects/excelion/`  
- Deletion of `ln9swrd/excelion-forge` repository  
- `MESHY_BLENDER_PIPELINE_SPEC` TBD fields  
- Playtest improvement items (Kai seed, EP8 UI, etc.)  
- Mecha/story TEXT-LOCK  

### Suggested rewrite target (when PR opens)

```
Pipeline primary: Meshy → Blender → FBX → UE
(see state/MESHY_BLENDER_PIPELINE_SPEC.md)
excelion-forge: DEPRECATION CANDIDATE / archived (non-primary)
```

---

## 7. Recommended sequence (unchanged policy)

1. Merge this scope audit  
2. Optional: binary inventory export from excelion-forge `blender/`  
3. Excelion **docs-only** removal PR (list §6)  
4. Separate: Archive `ln9swrd/excelion-forge` on GitHub  
5. Separate: Atlas platform pointer cleanup  
6. Only after G1–G7: practical Meshy/Blender work  

---

## 8. Non-actions (this deliverable)

- No Forge file/repo delete  
- No MESHY_BLENDER_PIPELINE_SPEC TBD fill-in  
- No story / design / playtest edits  
- No UE / Meshy / Blender implementation  

**Status:** Removal scope **decision-ready** for Excelion docs PR · external repo = Archive-after-preserve.
