# Rebuild archived atlas-vscode-extension

This directory is a historical archive. `node_modules/` was removed to reduce repository size.

## Restore dependencies

```bash
cd archive/projects-atlas-extension-legacy
npm install
```

## Build (if needed)

```bash
npm run compile
# or
npx tsc
```

## Notes

- Original `package.json` and `package-lock.json` are preserved.
- Do not commit regenerated `node_modules/` back into the repository.
