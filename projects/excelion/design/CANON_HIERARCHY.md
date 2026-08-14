# Canon Hierarchy — Excelion Design SoR

> 2026-08-14 · Master 승인
> 출처: DESIGN_REORGANIZATION_PLAN + Master 지시

**상태: LOCK**

---

## 1. 계층 (위 → 아래 우선)

```text
DESIGN_QUALITY.md
        ↓
SUPER_ROBOT_DESIGN_LANGUAGE.md
        ↓
SUPER_ROBOT_MODERN.md
        ↓
개별 진영 / 메카 디자인 규칙
        ↓
개별 MECHA FINAL_SPEC
        ↓
DESCRIPTION / Unreal 구현
```

### 해석

| 문서 | 역할 |
|------|------|
| **DESIGN_QUALITY.md** | 전체 품질 상한 (로봇혼 / 센티넬 피니시) |
| **SUPER_ROBOT_DESIGN_LANGUAGE.md** | Excelion 전체 정체성 (SUPER ROBOT FIRST · 곡선 · 영웅 조형) |
| **SUPER_ROBOT_MODERN.md** | 위 정체성을 현대적 조형으로 구현하는 구체적 방법 (중밀도 패널 · 근골) |
| 개별 진영/메카 규칙 | ORDER_DESIGN_LANGUAGE, FRAME_SPEC, enemy/*_SPEC 등 |
| 개별 MECHA FINAL_SPEC | 기체별 제작 요약 스펙 |
| DESCRIPTION / Unreal | 실제 제작 지시 및 엔진 구현 |

충돌 시 **상위 문서 우선**.

---

## 2. FSS 위치

FSS 관련 문서는 **Reference** 로만 취급한다.

- `FSS_STYLE_REF.md`
- `FSS_DESIGN_LANGUAGE.md`
- `FSS_WEAPON_DESIGN.md`

TEXT-LOCK · FINAL_SPEC · DESCRIPTION을 덮어쓰지 않는다.
Excelion 최종 정체성은 Super Robot이다.

---

## 3. 스펙 vs 제작 (이중 구조 유지)

| 역할 | 위치 |
|------|------|
| 스펙 원본 (TEXT-LOCK) | `enemy/` · `brave/FRAME_SPEC` · `brave/EXCELION_SPEC` |
| 제작 단위 | `mecha/` (DESCRIPTION + FINAL_SPEC + threeview) |

의도적 이중 구조. 합치지 않는다.

---

## 4. 구현자 기준

Unreal / 프로토타입 작업 시 우선 참조 순서:

1. 본 문서 (계층)
2. DESIGN_QUALITY · SUPER_ROBOT_DESIGN_LANGUAGE · SUPER_ROBOT_MODERN
3. 해당 기체 TEXT-LOCK 스펙 (`enemy/` 또는 `brave/`)
4. `mecha/*/FINAL_SPEC` · `DESCRIPTION`
5. `design/combat/` (전투 루프·패턴)

---

## 5. 관련

- `DESIGN_REORGANIZATION_PLAN.md` — 1차 감사 결과
- `README.md` — 폴더 지도

**이 계층이 변경되려면 Master 재승인이 필요하다.**
