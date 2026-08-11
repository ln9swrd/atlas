# projects-unregistered (archived 2026-08-11)

Former R5 HOLD-unregistered paths under `projects/`.

| Project | Note |
|---------|------|
| `3GUpbit/` | Local toga/Upbit experiment |
| `aws-mcp/` | Vendored AWS MCP (upstream: RafalWilinski/aws-mcp) |
| `blender-mcp-main/` | Vendored BlenderMCP |
| `blender-open-mcp/` | Vendored Ollama Blender MCP |

## Why archived

- Atlas tools/tests/CI reference: **0**
- Not Excelion / DevOS SoR
- POLICY_HOLD_SURVEY + P2_R5_POLICY_REVIEW → Master option **ARCHIVE**

## Tree content

Project file trees were removed from `projects/` in the same cleanup series.
Full blobs remain in **git history** (pre-delete commits). Restore:

```bash
git checkout <pre-archive-sha> -- projects/<name>
git mv projects/<name> archive/projects-unregistered/<name>
```

Or copy from history into a standalone external repo.

Do not re-activate under `projects/` without PROJECT_MAP update and Master approval.
