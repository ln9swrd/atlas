# MECHA_MASTER_LIST

> Updated: 2026-08-10 · **SUPER_ROBOT_DESIGN_LANGUAGE** 상위 적용  
> 헤카톤·콜로서스 반영 · **몬투** 스토리명  
> 스토리 등장 연결: `docs/MECHA_STORY_APPEARANCE_REGISTER.md`

**전 기체 1차 분류: SUPER ROBOT.** 이름·EP·역할은 본 표 유지.  
**메카 SSOT = 본 문서.** 소설 등장은 Appearance Register에서 관리.

## 요약

| 분류 | 수 |
|------|----|
| 주인공 | 2 (BRAVE · EXCELION) |
| 이름 확정 보스 | 12 슬롯 |
| 양산 ORD | 3 |
| UNCONFIRMED | 3 |

**재등장:** 크레일 1회만. 네메시스만 다페이즈.

---

## 보스 로스터 (S1)

| # | ID | 스토리명 | 설계코드 | EP | 폴더 | Gameplay Role | Asset Priority | 상태 |
|---|-----|----------|----------|-----|------|---------------|----------------|------|
| 1 | HEKATON | **몬투** | 헤카톤 | 5 | hekaton / ord-mid | BOSS | B | 확정 |
| 2 | COLOSSUS | **세스** | 콜로서스 | 6 | colossus / seth | BOSS (**VS**) | A | 확정 |
| 3 | ARGOS | 아누비스 | 아르고스 | 7 | argos | BOSS | A | 확정 |
| 4 | NEMESIS-A | 네메시스 (1차) | 네메시스 | 9 | nemesis | BOSS | S | 확정 |
| 5 | EREBOS | 호르 등 | 에레보스 | 11/12 | erebos | BOSS | A | 확정 |
| 6 | KERBEROS | — | 케르베로스 | 13 | kerberos | BOSS | A | 확정 |
| 7 | CREIL | **세크** | 크레일 | 15 | creil | BOSS | A | 확정 · 1회만 |
| 8 | PHOBOS | — | 포보스 | 16/17 | phobos | BOSS | A | 확정 |
| 9 | ADRASTE | — | 아드라스테 | 19 | adraste | BOSS | A | 확정 |
| 10 | DEIMOS | 소벡 계 | 데이모스 | 20 | deimos | BOSS | A | 확정 |
| 11 | AEGIS | **와제** | 아이기스 | 21 | aegis | BOSS | A | 확정 |
| 12 | NEMESIS-B/F | 네메시스 (판정·최종) | 네메시스 | 23–24 | nemesis | BOSS | S | 확정 |

**BRAVE / EXCELION = 주인공. 보스 아님.**  
스토리 전용 이름(네크·토트·암밋 등): `BOSS_EP_MAP` · Appearance Register 참조. 신규 ID 창작하지 않음.

### 개명 이력

| 구 | 신 (설계) | 스토리 |
|----|-----------|--------|
| 미드 / ORD-MID | 헤카톤 | **몬투** |
| 세스 / SETH | 콜로서스 | 세스 (유지) |
| 오라클 | 아르고스 | 아누비스 |
| 보이드 | 에레보스 | 호르 등 |
| 레이스 | 케르베로스 | — |
| 카일 | 포보스 | — |
| 크레일 | 크레일 | **세크** |
| 아이기스 | 아이기스 | **와제** |

---

## EXISTING (기체 폴더)

| ID | First EP | Appearance (요약) | Design Status | FINAL | Priority | Gameplay Role |
|----|----------|-------------------|---------------|-------|----------|---------------|
| BRAVE | EP01 | 01–24 | FRAME+DESC | BRAVE_FINAL_SPEC | S | PLAYABLE |
| EXCELION | EP11/13 | 11–24 | SPEC+DESC | EXCELION_FINAL_SPEC | S | PLAYABLE |
| NEMESIS | EP04 | 이름/원경/09/23–24 | SPEC+DESC | NEMESIS_FINAL_SPEC | S | BOSS |
| **COLOSSUS** | EP06 | 06 only | DESC + 구 SETH_FINAL 이관 | 구 SETH_FINAL_SPEC | A | BOSS (VS) |
| CREIL | EP15 | 15 only | SPEC+DESC | CREIL_FINAL_SPEC | A | BOSS |
| AEGIS | EP21 | 21 | SPEC+DESC | AEGIS_FINAL_SPEC | A | BOSS |
| **HEKATON (몬투)** | EP05 | 05 | DESC | 구 ORD-MID | B | BOSS |
| ARGOS | EP07 | 07 | DESC | — | A | BOSS |
| EREBOS | EP11/12 | 10–11 · 18 | DESC | — | A | BOSS |
| KERBEROS | EP13 | 13 전후 | DESC | — | A | BOSS |
| PHOBOS | EP16/17 | 16–17 | DESC | — | A | BOSS |
| ADRASTE | EP19 | 19 전후 | DESC | — | A | BOSS |
| DEIMOS | EP20 | 20 | DESC | — | A | BOSS |
| ORD-GRUNT | EP01 | 01+ · VS | DESC | ORD_FINAL | A | ENEMY |
| ORD-GUN | EP01+ | 다수 | DESC | ORD_FINAL | B | ENEMY |
| ORD-HEAVY | EP01+ | 다수 · EP8 | DESC | ORD_FINAL | B | ENEMY |

---

## 상태

```
CURRENT: SUPER ROBOT FIRST · Story Appearance Register 연결
NEXT: 잔여 스토리명(네크/토트/암밋) ↔ 슬롯 표기 P2
DONE: 로스터 · 몬투 · VS=세스 · 등장 EP 요약
```
