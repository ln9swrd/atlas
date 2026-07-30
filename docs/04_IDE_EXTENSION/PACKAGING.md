# Extension packaging hygiene

Issue #2 · branch `impl/atlas-extension`

## Rules

| Artifact | Track in Git? |
|----------|----------------|
| `src/**` | Yes |
| `package.json` / `package-lock.json` / `tsconfig.json` | Yes |
| `out/**` (compile output) | Optional; prefer CI/local compile |
| `node_modules/**` | **Never** |
| `*.vsix` | **Never** (release artifact only) |

Root `.gitignore` already lists `node_modules/` and `*.vsix`.

## One-time untrack (if still in index)

```bash
git checkout impl/atlas-extension
git rm -r --cached projects/atlas-extension/node_modules
git rm --cached projects/atlas-extension/*.vsix 2>/dev/null || true
git commit -m "chore(extension): stop tracking node_modules and vsix"
git push
```

## Build VSIX locally (not committed)

```bash
cd projects/atlas-extension
npm install
npm run compile
npx @vscode/vsce package
# produces atlas-vscode-extension-0.1.0.vsix — install via "Install from VSIX…"
```

## Boundary

- Orchestrator helper: `tools/atlas_qwen_orchestrator.py` (repo tool, not npm dep)
- Extension must not become the system of record; Git `state/` remains canonical
