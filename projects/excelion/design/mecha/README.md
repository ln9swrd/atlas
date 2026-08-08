# mecha/ — 기체 제작 단위 (중심)

> 삼면도·모델링 SoR는 **여기만**. 스펙 원본은 `../enemy/` · `../brave/`.

## 목록

| 폴더 | 기체 | 스펙 | 상태 |
|------|------|------|------|
| `brave/` | BRAVE-001 | `brave/FRAME_SPEC` | DESCRIPTION · threeview |
| `excelion/` | EP13 전개 | `brave/EXCELION_SPEC` | DESCRIPTION |
| `seth/` | 세스기 | `enemy/SETH_MECHA_SPEC` | DESCRIPTION |
| `creil/` | 크레일기 | `enemy/CREIL_MECHA_SPEC` | **DESCRIPTION 신설** |
| `aegis/` | 아이기스기 | `enemy/AEGIS_MECHA_SPEC` | **DESCRIPTION 신설** |
| `nemesis/` | 네메시스기 | `enemy/NEMESIS_MECHA_SPEC` | **DESCRIPTION 신설** |
| `ord-grunt/` | ORD 잡 | `enemy/ORD_SPEC` | DESCRIPTION |
| `ord-heavy/` | ORD 중 | 동 | DESCRIPTION |
| `ord-gun/` | ORD 원거리 | 동 | DESCRIPTION |
| `ord-mid/` | ORD-MID | 동 | DESCRIPTION |
| `threeview/` | 공통 스킬 | `threeview/SKILL.md` | — |

**폐기:** `ashur/` (2026-08-07).

## 규칙

```
mecha/<unit>/
  DESCRIPTION.md   ← 그릴 때 1차
  threeview/       ← 결과
```

- 충돌 시 **스펙 원본(enemy/brave) 우선** · DESCRIPTION은 작업 지시 요약
- 컨셉 PNG 풀: `../brave/` · `../nemesis/` (참고만 · LOCK 아님)
- 데크레: 독립 기체 폴더 없음 (네메시스 연출)

## 삼면도 큐

`../THREEVIEW_CURRENT.md` — CURRENT 1개씩.
