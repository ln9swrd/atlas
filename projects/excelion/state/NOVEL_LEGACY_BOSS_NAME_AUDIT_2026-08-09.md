# NOVEL LEGACY BOSS-NAME AUDIT — 2026-08-09

> 목표: 구 보스 명칭 잔존을 찾고 **현재 정본과 정합**을 판정한다.
> **파일 수정 없음 · 이름 임의 통일 없음 · 캐논 변경 없음 · 소설 본문 수정 없음**

**상태: 검색·판정만**

---

## 0. 정본 명칭 (대조 기준)

| 정본 | 영문 | 주 EP | 출처 |
|------|------|-------|------|
| **네메시스** | Nemesis | 9 · 23–24 | `NOVEL_CANON` · `BOSS_EP_MAP` |
| **세크** | Sekh | 15 | `BOSS_EP_MAP` · `NAMES_SILHOUETTE_FIXED` · **구 크레일** |
| **와제** | Wadjet | 21 | 동일 · **구 아이기스** |
| **몬투** | Montu | 5 | 동일 · 구 ORD-MID |
| **아누비스** | Anubis | 7 | 동일 · 구 아누 |
| 세스 · 호르 · 네크 · 토트 · 소벡 · 암밋 | — | 맵 따름 | `BOSS_EP_MAP` |

**폐기:** Ashur / 아슈르 = 최종보스 아님 (`NOVEL_CANON` · P3).

개명 리다이렉트 파일 예:
- `CREIL_MECHA_SPEC.md` → 세크
- `AEGIS_MECHA_SPEC.md` → 와제

---

## 1. 판정 정의

| 판정 | 의미 |
|------|------|
| **CANON_CONFIRMED** | 정본 명칭이 활성 문맥에서 올바르게 쓰임 |
| **LEGACY_TEXT** | 구 명칭이 **활성 서술/본문/수치표**에 남아 정본과 불일치 |
| **HISTORICAL_REFERENCE** | 폐기·개명·P3 이력·「구 ○○」명시 · 정본을 대체하지 않음 |
| **AMBIGUOUS** | 역할은 맞으나 표기만 혼재 · 추가 확인 필요 |
| **TBD** | 미검색 구간 또는 범위 밖 |

---

## 2. 구명 → 정본 매핑

| 구 명칭 | 정본 | 비고 |
|---------|------|------|
| 크레일 / CREIL / Creil | **세크** | EP15 |
| 아이기스 / AEGIS / Aegis | **와제** | EP21 |
| 아슈르 / Ashur / ASHUR | **네메시스** (최종) | 설정 폐기 |
| 아누 (단독 약칭) | **아누비스** | EP7 실행자 |
| ORD-MID / MID(보스) | **몬투** | EP5 |

---

## 3. 발생 요약 (검색 2026-08-09)

### 3.1 크레일 / CREIL

| 구역 | 대표 경로 | 문맥 | 판정 |
|------|-----------|------|------|
| **소설 본문** | `novel/ep14.md` · `ep15.md` · `ep16.md` | 보스·잔해·반응 **본문 고유명** | **LEGACY_TEXT** |
| 시놉·구조 | `EP14_24_SYNOPSIS` · `EP13_18_ENHANCEMENT` · `EP14_24_STRUCTURE_ANALYSIS` | EP15 목표·예고에 크레일 | **LEGACY_TEXT** |
| 플롯(신) | `EP14_24_PLOT.md` | **세크** + 「구 크레일」 | **HISTORICAL_REFERENCE** (+ 정본 병기) |
| 밸런스 | `BALANCE_ENEMY_MULT` · `BALANCE_SOR` · `BOSS_STATS_*` · `BOSS_WEAPON_SKILLS` · `BALANCE_EP_TARGETS` | 행 라벨 크레일 | **LEGACY_TEXT** |
| 전술·분석 | `ORD_REMNANT_TACTICS` · `ELITE_BT_COMPARE` · `MECHA_BIBLE` · `NEMESIS_DEEP_ANALYSIS` | ELITE 층 표기 | **LEGACY_TEXT** |
| 스펙 리다이렉트 | `CREIL_MECHA_SPEC` · `SEKH_MECHA_SPEC` · `NAMES_SILHOUETTE_FIXED` | 개명 명시 | **HISTORICAL_REFERENCE** |
| 루트 | `projects/excelion/README.md` · `PROJECT_MEMORY` | ELITE=크레일 요약 | **LEGACY_TEXT** |

### 3.2 아이기스 / AEGIS

| 구역 | 대표 경로 | 문맥 | 판정 |
|------|-----------|------|------|
| **소설 본문** | `novel/ep18.md` · `ep19.md` · `ep21.md` | 반응·예고·격파 본문 | **LEGACY_TEXT** |
| 시놉 | `EP14_24_SYNOPSIS` · `EP19_SYNOPSIS` · `EP21_SYNOPSIS` · `EP19_24_ENHANCEMENT` | 목표 보스명 | **LEGACY_TEXT** |
| 플롯(신) | `EP14_24_PLOT` | **와제** + 「구 아이기스」 | **HISTORICAL_REFERENCE** |
| 밸런스·스테이지 | `BALANCE_*` · `STAGE_MAP_SAMPLE` · `BOSS_WEAPON_SKILLS` | 행/맵 라벨 | **LEGACY_TEXT** |
| 스펙 | `AEGIS_MECHA_SPEC` · `WADJET_MECHA_SPEC` · `NAMES_*` | 개명 | **HISTORICAL_REFERENCE** |
| 루트 README | ELITE/방패 표 | 아이기스 EP21 | **LEGACY_TEXT** |

### 3.3 아슈르 / Ashur

| 구역 | 대표 경로 | 문맥 | 판정 |
|------|-----------|------|------|
| 캐논 | `NOVEL_CANON` | **폐기** 명시 | **HISTORICAL_REFERENCE** |
| P3 검증 | `P3_NEMESIS_CANON_VERIFY` · `PASS1_BOARD` · `SETH_BATTLE_FIXED` 헤더 | 잔존 제거 기록 | **HISTORICAL_REFERENCE** |
| **콘티 (활성 대사·목표)** | `design/conti/EP04`~`EP13` 다수 · `EP09_CONTI` 등 | 목표/대사 주어가 **아슈르** | **LEGACY_TEXT** |
| 구 비전·전투 | `docs/00_VISION` · `02_COMBAT` | 돌파(아슈르)·혈투 | **LEGACY_TEXT** |
| 프로토 JSON | `prototype/.../boss_ashur.json` | id만 ashur · displayName NEMESIS | **HISTORICAL_REFERENCE** (id 레거시) |
| 금지·정리 문서 | CLEANUP · COMBAT_SYSTEM_BIBLE · engine README | 사용 금지 | **HISTORICAL_REFERENCE** |
| FACTION/TIMELINE 분석 | `novel/FACTION_ANALYSIS` · `TIMELINE_ANALYSIS` | Ashur 세력 서술 | **AMBIGUOUS** (분석 미갱신 가능) |

### 3.4 정본 측 (대조)

| 문서 | 표기 | 판정 |
|------|------|------|
| `BOSS_EP_MAP` · `05_ENEMY` · `NAMES_SILHOUETTE_FIXED` | 세크·와제·네메시스·몬투… | **CANON_CONFIRMED** |
| `NOVEL_CANON` | 세크(구 크레일)·와제(구 아이기스)·Ashur 폐기 | **CANON_CONFIRMED** |
| `docs/09_STORY_S1` | 네메시스·몬투·세스 (크레일/아이기스 EP 절 없음) | **CANON_CONFIRMED** (해당 구간) |
| `ep13.md` · `ep24.md` 등 | 네메시스 | **CANON_CONFIRMED** |

---

## 4. 캐논 충돌 여부

| ID | 내용 | 심각도 |
|----|------|--------|
| **LBN-01** | **소설 본문** EP14–16 **크레일** vs 정본 **세크** | **고** (본문 우선 규칙 vs 보스맵) |
| **LBN-02** | **소설 본문** EP18–21 **아이기스** vs 정본 **와제** | **고** |
| **LBN-03** | 밸런스/스킬 SoR 표가 크레일·아이기스 라벨 유지 | **중** (수치 동일 역할 · 명칭만) |
| **LBN-04** | `design/conti/EP0x` 아슈르 활성 표기 vs 네메시스 LOCK | **중** (애니/콘티 트랙 · 본문 ep는 네메시스) |
| **LBN-05** | 루트 README · PROJECT_MEMORY 요약 구명 | **저** |

**정본이 폐기/개명을 선언한 뒤에도 본문·다수 운영 문서가 구명을 활성 사용** → 단순 이력만이 아님.

`EP14_24_PLOT`만 신명+구명 병기로 앞서 있음. 시놉·본문·밸런스는 미동기화.

---

## 5. 종합 판정

| 구명 | 주 판정 |
|------|---------|
| 크레일 | **LEGACY_TEXT** (본문·밸런스·시놉) / 스펙·PLOT는 HISTORICAL |
| 아이기스 | **LEGACY_TEXT** (본문·시놉·밸런스) / 스펙·PLOT는 HISTORICAL |
| 아슈르/Ashur | **HISTORICAL_REFERENCE** (폐기 명시) + 콘티·구 docs **LEGACY_TEXT** |
| 세크·와제·네메시스·몬투 (맵·캐논) | **CANON_CONFIRMED** |

**AMBIGUOUS:** FACTION/TIMELINE 등 분석 문서의 Ashur 세력 서술 — 세계관 재서면 필요 여부는 TBD.

**TBD:** `EPISODE_MATRIX` 전 셀 전수 · EP01 다중 본문 내 ASHUR 잔존 여부(구 감사 C-07 이후) 재스캔.

---

## 6. 권고 (실행 아님)

1. **본문 개명**은 Master 승인 전용 별도 PR · 본 감사에서 수정하지 않음.
2. 우선순위 후보: `ep14`–`ep16`·`ep18`–`ep21` 고유명 → 세크/와제 (대사·체크표 포함).
3. 병행 후보: `EP14_24_SYNOPSIS` · `BALANCE_ENEMY_MULT` 등 라벨을 정본에 맞춤 (수치는 유지).
4. 콘티 EP04–13 아슈르 → 네메시스는 **애니 트랙** 별도 게이트.
5. 「구 크레일」「구 아이기스」병기는 스펙·이력에 **유지 가능** (HISTORICAL).

---

## 7. 비범위

- C-01 EP1 대사 (별도 이슈)
- EP01 다중 경로
- 「한 뿌리」회수
- ORD 설계 · 코드 · 이미지 · Meshy · UE · M5

---

## 8. 다음 게이트

```text
검색·판정 PR
  → Master: 수정 범위(본문 / 밸런스 / 콘티 / README) 지정
  → 지정 범위만 별도 PR
승인 전 merge 금지 · 자동 개명 금지
```

```
CURRENT: 구 보스명 잔존 맵핑 완료 (수정 0)
HIGH: 본문 크레일·아이기스 (LBN-01 · LBN-02)
CANON MAP: 세크·와제·네메시스 LOCK 유지
```
