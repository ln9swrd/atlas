# design/ — Excelion 비주얼·에셋 SoR

> 한 줄: **스펙(문서)** 과 **제작 단위(폴더)** 를 나눈다. 삼면도 자동화는 제작 단위만 순회한다.

**디자인 품질 기준:** [`DESIGN_QUALITY.md`](DESIGN_QUALITY.md) — **반다이 로봇혼 / 센티넬 수준** (LOCK).

## 폴더 지도

| 경로 | 역할 | 비고 |
|------|------|------|
| **character/** | 인물 제작 단위 + 공유 실루엣 스펙 | `DESCRIPTION.md` → `threeview/` |
| **mecha/** | 기체 제작 단위 | 동일 |
| **env/** | 맵·키트 제작 단위 | `props/` |
| **weapon/** | 무기·하드포인트 제작 단위 | `threeview/` |
| **effect/** | 광기·연출 스펙 (텍스트) | 메쉬보다 연출 규칙 |
| **ui/** | UI 최소 스펙 | 2D 우선 |
| **conti/** | 에피소드 콘티 | 스토리보드 |
| **anime/** | 애니 패스 보드 | |
| **brave/** | BRAVE **컨셉 이미지 풀** | 제작 SoR ≠ 여기 → `mecha/brave` |
| **enemy/** | 적 기체 **스펙 원본** (TEXT-LOCK) | 제작 단위 → `mecha/*` |
| **nemesis/** | **네메시스** 최종보스 컨셉 이미지 풀 | 스펙 → `enemy/NEMESIS_MECHA_SPEC.md` |
| **THREEVIEW_CURRENT.md** | 삼면도 자동화 큐 (1개씩) | |
| **DESIGN_QUALITY.md** | 품질 바 (로봇혼·센티넬) | **LOCK** |

## 제작 단위 규칙 (공통)

```
<category>/<unit>/
  DESCRIPTION.md    ← 1차 레퍼런스 (자동화·모델링)
  threeview/        ← 삼면도·결과물 (env는 props/)
  README.md         ← 선택, 한 줄 요약
```

- 스펙 원본이 다른 곳에 있어도, **그릴 때 읽는 파일은 DESCRIPTION.md**.
- 컨셉 PNG/JPG는 참고 풀일 뿐 TEXT-LOCK을 덮어쓰지 않음.
- 모든 삼면도·제작 레퍼런스는 `DESIGN_QUALITY.md` 품질 바를 충족해야 한다.

## 스펙 ↔ 제작 연결

| 스펙 (읽기) | 제작 폴더 |
|-------------|----------|
| `character/CAST_SILHOUETTE.md`, `BOSS_CAST.md` | `character/<name>/` |
| `brave/FRAME_SPEC.md`, `EXCELION_SPEC.md` | `mecha/brave`, `mecha/excelion` |
| `enemy/ORD_SPEC.md`, `SETH_MECHA_SPEC.md`, `NEMESIS_MECHA_SPEC.md` | `mecha/ord-*`, `seth` |
| `env/MAP_MOOD.md` | `env/earth-*`, `lunar`, `gate` |
| `effect/MADNESS_VISUAL.md` | 연출 (필요 시 effect 하위 확장) |
| `ui/UI_MIN.md` | UI (3D 비우선) |

**폐기:** 아슈르 최종보스·`mecha/ashur`·`character/ashur`·ashur 무기 — 2026-08-07 삭제. 최종보스 = **네메시스**.

## 삼면도 큐

`THREEVIEW_CURRENT.md` → 하루 1폴더 · QUEUE 순회.

순서: character → mecha → env → weapon

## 정리 원칙

1. **새 작업은 character / mecha / env / weapon 아래에만** 둔다.
2. `brave/`, `nemesis/` 이미지는 삭제하지 않고 **컨셉 풀**로 유지.
3. `enemy/*.md` 스펙은 유지 (TEXT-LOCK 원본). 중복 서술 금지 시 DESCRIPTION만 갱신.
4. conti / anime / effect / ui 는 에셋 파이프라인과 분리.
5. 품질 미달(저밀도·러프·카툰화) 결과물은 제작 레퍼런스로 채택하지 않는다.
