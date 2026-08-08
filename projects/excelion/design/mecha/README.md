# mecha/ — 기체 제작 단위 (중심)

> 삼면도·모델링 SoR는 **여기만**. 스펙 원본은 `../enemy/` · `../brave/`.
>
> **Master List:** [MECHA_MASTER_LIST.md](MECHA_MASTER_LIST.md) (EP01~EP24 전수조사 기준)

## 목록

| 폴더 | 기체 | 스펙 | 상태 |
|------|------|------|------|
| `brave/` | BRAVE-001 | `brave/FRAME_SPEC` | DESCRIPTION · threeview |
| `excelion/` | EP13 전개 | `brave/EXCELION_SPEC` | DESCRIPTION |
| `seth/` | 세스기 | `enemy/SETH_MECHA_SPEC` | DESCRIPTION |
| `creil/` | 크레일기 | `enemy/CREIL_MECHA_SPEC` | DESCRIPTION |
| `aegis/` | 아이기스기 | `enemy/AEGIS_MECHA_SPEC` | DESCRIPTION |
| `nemesis/` | 네메시스기 | `enemy/NEMESIS_MECHA_SPEC` | DESCRIPTION |
| `ord-grunt/` | ORD 잡 | `enemy/ORD_SPEC` · **ORD_FINAL_SPEC** | DESCRIPTION |
| `ord-heavy/` | ORD 중 | 동 | DESCRIPTION |
| `ord-gun/` | ORD 원거리 | 동 | DESCRIPTION |
| `ord-mid/` | ORD-MID | 동 | DESCRIPTION |
| `threeview/` | 공통 스킬 | `threeview/SKILL.md` | — |

**FINAL_SPEC:** [ORD_FINAL_SPEC.md](ORD_FINAL_SPEC.md) — STEP 8 TEXT-LOCK (2026-08-08)

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

## 전수조사 상태 (2026-08-08)

- EP01~EP24 전수추출 완료
- MISSING 기체 없음
- UNCONFIRMED 3건 (지원기 · 내부 적 · 관측 실루엣)
- 다음: AEGIS 상세 설정집 우선 검토
