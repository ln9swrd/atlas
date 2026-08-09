# P1_KAI_SEED_VERIFY — 2026-08-09

## Canon rule (existing SoR)

| Source | Rule |
|--------|------|
| `state/KAI_HABIT_FIXED.md` | **H1** = 통신 끝 **「콜.」** · 사용 구간 **EP1–7** |
| `docs/09_STORY_S1.md` | 카이 습관 → `KAI_HABIT_FIXED` |
| `state/VERTICAL_SLICE_EP1_6_8.md` | EP1 카이 비트 = H1「콜.」 |

**No new dialogue invented.** Conflict resolved by aligning outliers to H1.

## Was wrong (EP1 treated as 「내리지 마.」)

| File | Change |
|------|--------|
| `state/EP1_EP8_SCENE_SCRIPT.md` | 카이 비트 · CUT01 · 검증표 → 「콜.」 |
| `docs/01_CHARACTER.md` | EP1 애착 비트 · EP1 대사 초안 → H1「콜.」 |
| `design/conti/EP01_CONTI.md` | P03 · 검증 → 「콜.」 |
| `state/ANIME_PASS1_10CUTS.md` | 컷1 → 「콜.」 |
| `design/anime/PASS1_BOARD.md` | 컷1 → 「콜.」 |
| `state/CONTI_CROSS_CHECK_2026-08-06.md` | EP1 카이 비트 재검증 |

## Intentionally unchanged

| Item | Reason |
|------|--------|
| `novel/EP01_*` · `novel/ep04.md` | 본문 집필 금지 범위 · 후속 소설 정합 별도 |
| EP5「내리지 않으려는 힘」· 리아「…안 내려.」 | 카이 시드 아님 |
| H3「끝나면 내려.」 | EP8 고정 · 시드와 별개 |
| VERTICAL_SLICE · KAI_HABIT | 이미 H1 정합 |
| SoR idle/M5/ORD/Playtest Open 충돌 | 이번 PR 비범위 |
| P2 · P3 · M5 · ORD | 비범위 |

## Payoff chain (EP1→EP9)

```
EP1 H1「콜.」 시드 → EP2–7 습관 → EP8 H3「끝나면 내려.」
  → EP9 빈 주파수「콜.」메아리 (잔상 회수)
```

## Expected residual search

- **Active EP1 Kai seed 「내리지 마」 in design/state/docs (excl. novel history):** should be **0** after merge  
- 「콜.」 as H1: present in SoR + EP1 scripts

## Status

**P1 docs alignment done** · CI → Master approve → merge → SHA record
