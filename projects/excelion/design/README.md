# design/ — Excelion 비주얼·에셋 SoR

> **스펙(문서)** 과 **제작 단위(폴더)** 를 나눈다. 삼면도는 제작 단위만 순회.

**품질:** [`DESIGN_QUALITY.md`](DESIGN_QUALITY.md) — 반다이 로봇혼 / 센티넬 (LOCK).

## 폴더 지도

| 경로 | 역할 |
|------|------|
| **mecha/** | **기체 제작 중심** · DESCRIPTION + threeview |
| **character/** | 인물 제작 단위 |
| **enemy/** | 적 기체 **스펙 원본** (TEXT-LOCK) · 제작은 mecha |
| **brave/** | BRAVE **컨셉 이미지 풀** (제작 SoR ≠ 여기 → mecha/brave) |
| **nemesis/** | 네메시스 **컨셉 이미지 풀** (제작 → mecha/nemesis) |
| **env/** · **weapon/** | 맵·무기 제작 단위 |
| **effect/** · **ui/** · **conti/** · **anime/** | 연출·UI·콘티·애니 |
| **THREEVIEW_CURRENT.md** | 삼면도 큐 (1개씩) |

## 기체 스펙 ↔ 제작

| 스펙 | 제작 |
|------|------|
| `brave/FRAME_SPEC` · `EXCELION_SPEC` | `mecha/brave` · `mecha/excelion` |
| `enemy/ORD_SPEC` | `mecha/ord-*` |
| `enemy/SETH_MECHA_SPEC` | `mecha/seth` |
| `enemy/CREIL_MECHA_SPEC` | `mecha/creil` |
| `enemy/AEGIS_MECHA_SPEC` | `mecha/aegis` |
| `enemy/NEMESIS_MECHA_SPEC` | `mecha/nemesis` |

## 규칙

1. **새 기체 작업은 mecha/ 아래에만**
2. enemy/*.md = 스펙 유지 · DESCRIPTION만 작업 지시
3. brave/ · nemesis/ 루트 이미지는 컨셉 풀 유지 (삭제 금지)
4. 품질 미달 결과물은 레퍼런스 채택 금지
5. 폐기: ashur 전 경로 (2026-08-07)

## 삼면도 큐

`THREEVIEW_CURRENT.md` · character → mecha → env → weapon
