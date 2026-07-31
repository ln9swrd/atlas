# CURRENT_STATE

ACTIVE_TARGET: **M6** tools smoke Evidence  
MIN_SCOPE: `docs/07_ROADMAP/ATLAS_MIN_SCOPE.md`  
TOOLS: `tools/INVENTORY.md`

## M6 status

- Listing: Done (마스터 `ls tools/`)
- Inventory doc: Done
- `atlas_runner.py` merge conflict: **fixed** on main
- Smoke Evidence: **Pending** → run `bash tools/atlas_status.sh`

## Next one thing

```bash
git pull github main
bash tools/atlas_status.sh
```

출력 정상이면 Evidence를 TASK_MAP M6에 기록 (또는 이 채팅에 붙여 마스터 확인).

Then: M7 blacklist 정합 or M5 G6 정책.

## Do not

- 제품 프로젝트 우선
- extension 부활
- runner full audit를 M6 필수로 요구하지 않음
