# CURRENT_STATE

ACTIVE_TARGET: **platform P3**  
D28 repo-split defaults: **Confirmed**  
S0 plan + S2 path list: **Done**  
S1 tag: **Master local** (API cannot create annotated tag)

## Next (one thing)

```bash
cd /mnt/d/Atlas
git pull origin main
git tag -a pre-split-atlas -m "D28 pre-split baseline"
git push origin pre-split-atlas
# optional size Evidence:
du -sh projects/excelion projects/excelion-forge 2>/dev/null
```

Then S3 (create empty product repos) when Master schedules.

## Do not

- filter-repo / force-push without tag + backup  
- product feature work on platform target
