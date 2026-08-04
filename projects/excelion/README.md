# projects/excelion (atlas residual)

> **Product SoR is NOT here.**  
> Canonical: **https://github.com/ln9swrd/excelion** (D28)  
> Status: **HOLD** (Master 2026-08-04) — dual-write forbidden.

This tree is a **residual design asset stash** left after repo split.  
Do not treat it as the live game project. Do not expand product docs/code here.

---

## Canonical (use these)

| What | Where |
|------|--------|
| Game design docs | `ln9swrd/excelion` → `docs/00_VISION` … `07_PIPELINE` |
| Play design / state | `ln9swrd/excelion` → `state/` |
| Charter / backlog | `ln9swrd/excelion` → root + `backlog.json` |
| Forge pipeline | `ln9swrd/excelion-forge` |

---

## What remains in atlas

```
projects/excelion/
  README.md          ← this file
  design/
    brave/           ← BRAVE mecha concept images (PNG/JPG)
    nemesis/         ← Nemesis concept images
```

### design/brave/

Concept / sheet images (ChatGPT · Gemini · local).  
Referenced historically from excelion play design; **not** authoritative numbers.

### design/nemesis/

Enemy / rival concept image(s).

---

## Rules

1. **No dual-write** of product sources into mono (D28 / PROJECT_MAP).  
2. New game docs → `ln9swrd/excelion` only.  
3. New pipeline tools → `ln9swrd/excelion-forge` only.  
4. ACTIVE_TARGET product re-open is Master-only; until then **HOLD**.  
5. Large binaries: prefer LFS / external when moving; see `docs/06_OPERATIONS/BINARY_ASSET_POLICY.md`.

---

## Optional later (Master)

| Option | Note |
|--------|------|
| Keep as design reference only | Current default |
| Move images into excelion repo | Cleaner product clone |
| Archive under `archive/excelion-design/` | If mono should drop product paths entirely |
