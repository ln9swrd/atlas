# BRAVE FRAME_SPEC — D1

> 2026-08-06 · Design D1 · SoR 후보  
> 근거: `docs/06_MECHA.md` · `state/NAMES_SILHOUETTE_FIXED.md` · `design/brave/` 컨셉

**상태:** Draft → 잠금 전 검증용. 참조 이미지 선정 후 Lock.

---

## 한 줄

S1 전 구간 **동일 형태** · 25m humanoid · 단순·여성형·Imperial 여백 · 성장은 S-Core·광기 연출만 · **EP13만** 엑셀리온 전개.

---

## 고정 파라미터

| 항목 | 값 |
|------|-----|
| id | brave-001 |
| name | BRAVE / Brave |
| codename | EX-BRAVE-001 |
| 키 | **25 m** |
| archetype | humanoid |
| mass (concept) | 48.5 |
| 색 primary | `#C0C8D0` |
| 색 secondary | `#2A3A4A` |
| 색 accent | `#E8A020` |
| style | modern_super · organic_mechanical · simple · retro |

---

## 실루엣 규칙

| 축 | 규칙 |
|----|------|
| 전체 | 단순 · 여성형 실루엣 · 장식 최소 (초기형) |
| 머리 | 과무장·뿔 금지 · 조종석 식별 가능 |
| 몸통 | Imperial 여백 · 곡선+직선 절제 |
| 팔·다리 | 기동 읽힘 우선 · 과한 아머 판 금지 |
| 배면 | backpack / skirt / thruster **슬롯 비활성**(초기형) |
| 무기 | 기본 내장·단순 · 별도 거대 무장으로 실루엣 파괴 금지 |

식별: 실루엣만으로 ORD 양산기·세스기·아슈르기와 구분.

---

## 슬롯 (ParaModel / 제작)

| 슬롯 | S1 초기 |
|------|---------|
| head, torso_u/l, arm_l/r, leg_l/r | **활성** |
| backpack, skirt, weapon, thruster | **비활성** |

성장 = 형태 추가가 아니라 **S-Core·광기 빛/균열 연출**.

---

## 엑셀리온 (EP13만) — 예고

| 항목 | 규칙 |
|------|------|
| 관계 | BRAVE **완전 전개** · 별 기체 아님 |
| 변화 | 실루엣 **확장 1단계** (날개·광윤·선 밀도) · **동일 골격** |
| 금지 | 완전 다른 로봇으로 교체 |

상세 스펙은 **D2**.

---

## 참조 이미지 (`design/brave/`)

| 역할 | 파일 (작업명) | 비고 |
|------|----------------|------|
| **주 시트 후보** | `브레이브 메카 디자인 시트.png` | 다각도·디자인 시트 |
| 컨셉 풀 | ChatGPT Image · Gemini_Generated_* · KXpmZ.jpg · nUJB3.jpg | 선정·폐기 표시 예정 |

**Lock 시:** 주 시트 1 + 전면/측면 각 1을 `REF_FRONT` / `REF_SIDE` / `REF_SHEET`로 지정.

---

## 금지

- S1 중반 형태 변경 (장식 증가로 성장 표현 금지 — 연출만)
- 성인 히로인형 과무장·과장 실루엣
- 세스/아슈르와 동일 실루엣 키
- 색 팔레트 임의 변경 (accent 제외 연출용 한시 가능)

---

## 검증 체크

| # | 체크 |
|---|------|
| 1 | 25m · 색 3종 · 슬롯 표와 일치 |
| 2 | 실루엣만으로 적기와 구분 |
| 3 | EP1–12 동일 프레임 가정 가능 |
| 4 | EP13 전개 = 1단계 확장만 |

---

## D1 남은 작업

1. 주 시트·전면·측면 **REF 파일명 확정** (기존 이미지 중 선정)
2. 필요 시 1장만 추가 생성 (없으면 기존으로 Lock)
3. 본 문서 Status → **Lock** · DESIGN_TASK_MAP D1=Done

사용자 확인 후 Lock.
