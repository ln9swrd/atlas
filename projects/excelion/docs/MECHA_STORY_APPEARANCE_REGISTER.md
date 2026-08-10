# Mecha Story Appearance Register — Excelion

> 2026-08-10  
> 소설 원문 미수정 · 등장 추출·분류만  
> SSOT 기체 목록: `design/mecha/MECHA_MASTER_LIST.md`  
> 제작 관리: `docs/ASSET_REGISTER.md`

**원칙:** 스토리 등장 ≠ 신규 3D 필수. Gameplay Role + Asset Priority로 제작 판단.

---

## 1. 기준 Commit

- 점검 시점 main (Novel→Gameplay · First Build WO 이후)
- P0: VS 보스 = **세스 (COLOSSUS)** · 몬투 = EP5 중보스 (VS 아님)

---

## 2. 전체 메카 목록 (소설 ↔ 설계)

| MECHA ID | 스토리명 | 설계코드 | First EP | Appearance EPs | Faction | Gameplay Role | Asset Priority | Design Status | Registry |
|----------|----------|----------|----------|----------------|---------|---------------|----------------|---------------|----------|
| BRAVE | BRAVE | BRAVE | 01 | 01–24 | 인류/주인공 | PLAYABLE | **S** | FINAL | REGISTERED |
| EXCELION | 엑셀리온 | EXCELION | 11/13 | 11–24 | 주인공 진화 | PLAYABLE | **S** | FINAL | REGISTERED |
| ORD-GRUNT | ORD GRUNT | ORD-GRUNT | 01 | 01–03 · 08 · 다수 | ORD 양산 | ENEMY | **A** (VS) | DESC | REGISTERED |
| ORD-GUN | ORD GUN | ORD-GUN | 01+ | 다수 | ORD 양산 | ENEMY | B | DESC | REGISTERED |
| ORD-HEAVY | ORD HEAVY | ORD-HEAVY | 01+ | 다수 · EP8 | ORD 양산 | ENEMY | B | DESC | REGISTERED |
| HEKATON | **몬투** | 헤카톤 | 05 | 05 | ORD 중보스 | BOSS | B | DESC | REGISTERED |
| COLOSSUS | **세스** | 콜로서스 | 06 | 06 (07+ 재등장 없음) | ORD ELITE | BOSS (**VS**) | **A** | Spec 이관 | REGISTERED |
| ARGOS | **아누비스** | 아르고스 | 07 | 07 | ORD ELITE | BOSS | A | DESC | REGISTERED |
| NEMESIS | **네메시스** | 네메시스 | 04(이름) · 09 | 04 이름 · 06–13 원경 · **09 · 23–24 본체** | 최종 | BOSS | **S** | FINAL | REGISTERED |
| EREBOS | 호르 등 | 에레보스 | 10/11 | 10 · 11 · 18 | ORD | BOSS | A | DESC | REGISTERED |
| KERBEROS | (로스터) | 케르베로스 | 13 | 13 전후 | ORD | BOSS | A | DESC | REGISTERED |
| CREIL | **세크** | 크레일 | 15 | 15 (1회만) | ORD ELITE | BOSS | A | FINAL | REGISTERED |
| PHOBOS | (로스터) | 포보스 | 16/17 | 16–17 | ORD | BOSS | A | DESC | REGISTERED |
| ADRASTE | (로스터) | 아드라스테 | 19 | 19 전후 | ORD | BOSS | A | DESC | REGISTERED |
| DEIMOS | 소벡 계 | 데이모스 | 20 | 20 | ORD | BOSS | A | DESC | REGISTERED |
| AEGIS | **와제** | 아이기스 | 21 | 21 | 게이트 방패 | BOSS | A | FINAL | REGISTERED |

### BOSS_EP_MAP 스토리명 ↔ 설계 매핑

| 스토리명 | 주 EP | 설계 ID | 비고 |
|----------|-------|---------|------|
| 몬투 | 5 | HEKATON | 확정 |
| 세스 | 6 | COLOSSUS | VS LOCK |
| 아누비스 | 7 | ARGOS | |
| 호르 | 10 · 18 | EREBOS 계 | 설계코드 「호르 등」 |
| 네크 | 11 · 16 | (로스터 내 수호형) | MASTER에 네크 전용 행 없음 → 아래 참고 |
| 토트 | 14 | (로스터) | 이름만 BOSS_EP_MAP |
| 세크 | 15 | CREIL | 스토리명 세크 |
| 소벡 | 20 | DEIMOS 계 | |
| 와제 | 21 | AEGIS | |
| 암밋 | 22 | (로스터) | 내부 기능 수호 |
| 네메시스 | 9 · 23–24 | NEMESIS | |

**네크 / 토트 / 암밋:** 스토리·BOSS_EP_MAP에 이름 존재. MASTER_LIST는 12슬롯 설계코드 중심. 별도 폴더 미분리 시 **REGISTERED(슬롯 공유) 또는 DESIGN 보강**으로 관리 — 신규 설정 창작하지 않음. 상세 외형·스탯은 기존 스펙/DESC에 위임.

---

## 3. EP별 등장 메카 (요약)

| EP | 플레이어 | 적/양산 | 보스 | 비고 |
|----|----------|---------|------|------|
| 01 | BRAVE | ORD-GRUNT | — | VS |
| 02–03 | BRAVE | ORD | — | |
| 04 | BRAVE | 약 | 네메시스 **이름만** | |
| 05 | BRAVE | — | **몬투** | 중보스 |
| 06 | BRAVE | — | **세스** | **VS** |
| 07 | BRAVE | — | 아누비스 · 네메시스 원경 | |
| 08 | BRAVE | ORD 파도 | — | 보스 없음 |
| 09 | BRAVE | — | 네메시스 본체 | |
| 10–11 | BRAVE / 전조 EX | 호르·네크 | 네메시스 시선 | |
| 12 | BRAVE | — | — | 합류 |
| 13 | **EXCELION** | — | 네메시스 시선 | |
| 14 | EX | ORD | 토트 | |
| 15 | EX | — | **세크** | |
| 16–18 | EX | 네크 등 | — | |
| 19 | EX | — | — | 돌입 |
| 20 | EX | ORD | 소벡 | |
| 21 | EX | — | **와제** | |
| 22 | EX | — | 암밋 | |
| 23–24 | EX | — | **네메시스** | 최종 |

---

## 4. Design / Mecha 등록 상태

| 상태 | 기체 |
|------|------|
| **REGISTERED** | BRAVE · EXCELION · ORD-GRUNT/GUN/HEAVY · HEKATON · COLOSSUS · ARGOS · NEMESIS · EREBOS · KERBEROS · CREIL · PHOBOS · ADRASTE · DEIMOS · AEGIS |
| **DESIGN_REQUIRED (신규 창작 금지 · 슬롯만 정리)** | 네크·토트·암밋 등 스토리명과 설계코드 1:1 표 보강 (기존 로스터 안) |
| **REUSE** | ORD 파도 · 잔당 = ORD-* 재사용 |
| **BACKGROUND** | 원경 네메시스 실루엣 · 군중 ORD |
| **CUTSCENE_ONLY** | EP4 이름만 네메시스 · 일부 원경 컷 | |
| **UNKNOWN** | 없음 (식별 불명 기체 추출 없음) |

---

## 5. Design Required / 불일치

| 이슈 | 등급 | 조치 |
|------|------|------|
| 네크·토트·암밋 스토리명 ↔ MASTER 설계코드 행이 느슨함 | P2 | MASTER에 「스토리명」열 보강 또는 BOSS_EP_MAP 주석만 유지. **신규 기체 창작 금지** |
| EP05 행렬에 ORD-MID 표기 | P2 | 스토리명 몬투(HEKATON)와 동의어로 취급 |
| VS vs EP5 몬투 | — | **충돌 아님** (역할 분리) |

**P0 누락 기체 없음.** VS에 필요한 BRAVE · ORD-GRUNT · 세스 모두 REGISTERED.

---

## 6. Unreal Asset Priority

| 우선 | ID | 이유 |
|------|-----|------|
| **S** | BRAVE | 플레이어 · First Build |
| **A (VS)** | ORD-GRUNT · COLOSSUS(세스) | VS 적·보스 |
| **S** | NEMESIS · EXCELION | 본편 핵심 · VS 이후 |
| **A** | CREIL · AEGIS · ARGOS 등 | EP 보스 |
| **B** | HEKATON(몬투) · ORD-GUN/HEAVY | EP5 · 양산 변형 |
| 배경/원경 | 네메시스 실루엣 등 | 간략·재사용 |

Unreal ID 예 (기존 문서 관례):
- 메카: MASTER ID 그대로 (BRAVE, ORD-GRUNT, COLOSSUS …)
- ASSET_REGISTER와 동기화

---

## 7. P0 / P1 / P2

| 등급 | 내용 |
|------|------|
| **P0** | **없음** — VS·First Build 기체 등록 완료 |
| **P1** | 없음 |
| **P2** | 네크/토트/암밋 스토리명–설계코드 표 정리 · EP 전구간 양산 출현 횟수 세분화 · BACKGROUND LOD 정책 |

---

## 8. 연결 체인

```
novel/EPxx 등장
    → 본 Register (등장·역할)
    → MECHA_MASTER_LIST (SSOT ID·폴더)
    → ASSET_REGISTER (제작 상태·Unreal)
    → Unreal Content/Mecha
```

---

## 9. 다음 제작 우선순위 (권장)

1. BRAVE 플레이스홀더 (First Build)
2. ORD-GRUNT 플레이스홀더
3. 세스(COLOSSUS) 플레이스홀더 (VS)
4. 이후: 네메시스 · EXCELION · 몬투 · 기타 보스 순

상세 디자인·3D는 우선순위 순. 스토리 등장만으로 즉시 제작하지 않음.
