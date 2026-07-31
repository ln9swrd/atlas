# CURRENT_STATE

ACTIVE_TARGET: 마스터 **L-9 untrack** (remote 설정 후 L-8)  
STATUS: Script needs GIT_REMOTE — origin 없음 확인됨. node_modules still tracked. npm 없음 on this host.  
MASTER_BATCH: `scripts/master_l8_l10.sh` (remote auto-detect / GIT_REMOTE=)

## Next (마스터)

```bash
git remote -v
# pull latest script from github if needed, then:
export GIT_REMOTE=github   # if that is the remote name
bash scripts/master_l8_l10.sh status
bash scripts/master_l8_l10.sh l9      # untrack works even if push fails
# or l8-l9 after remote works
```

If no remote at all:

```bash
git remote add github https://github.com/ln9swrd/atlas.git
git fetch github
export GIT_REMOTE=github
bash scripts/master_l8_l10.sh l8-l9
```

l10-npm: skip until Node installed.

## Do not

- Commit node_modules
- Mark L-8/L-9 Done without Evidence hash
