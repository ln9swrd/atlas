# Novel to Gameplay Readiness — Excelion

> 2026-08-10  
> 소설 원문 미수정 · 추출·분류만 수행  
> P0 LOCK 변경 없음

**판정: READY WITH CONDITIONS**

---

## 1. 기준 Commit

- 점검 시점 main 기준 (회사 prep closed / First Build WO 포함)
- P0: VS 보스 = **세스** · UE 5.4.x · Win64 · 60 FPS · In-place+CM · Anim 30 · GAS 제외
- 스토리 EP5 몬투 유지 (중보스) · VS와 분리

---

## 2. Character → Game

| 캐릭터 | 서사 역할 | 게임 역할 | Actor 필요 |
|--------|-----------|-----------|------------|
| **리아** | 주인공 · BRAVE 파일럿 | 플레이어 조작 대상 (기체 경유) | PlayerMecha (BRAVE) |
| **카이** | 동료 · 통신 · EP8 희생 | 통신/컷신 · 직접 조작 없음 | 컷신/UI 음성 위주 |
| **세스** | EP6 계단 · 가치관 충돌 | VS 보스 기체 | BossMecha |
| **네메시스** | S1 최종 보스 | 후반 보스 (VS 외) | BossMecha (후속) |
| **유나·레이** | 합류 · 최소 비트 | 컷신/대화 | 비조작 |
| **몬투** | EP5 중보스 | 스토리 전투 (VS 아님) | Enemy/Boss (후속) |

구분:
- **조작 Actor:** BRAVE(리아), 적 메카, 보스 메카
- **서사 전용:** 인간형 파일럿 모델은 1차 불필요. 통신·컷신으로 충분
- 인간 Character 컨트롤러로 전투하지 않음. 전투 = 메카

연결 상태: **양호**. 소설 인물과 게임 Actor 매핑이 명확.

---

## 3. Combat → Gameplay

| 요소 | 분류 | 비고 |
|------|------|------|
| 이동·대시 | A 실제 플레이 | In-place + CM |
| 근접 공격 (블레이드) | A | |
| 원거리 (캐논) | A | 1차 후 확장 가능 |
| 피격·HP | A | Damage Component |
| 회피 | A | |
| 가드 | A 또는 F | 1차 최소에 없어도 됨 |
| S-Core · 필살 | A | S-Core Component |
| Heat | A (2차) | Energy 확장 |
| ORD-Grunt AI | B AI 전투 | 단순 추적·공격 |
| 세스 Phase·씰 | C 보스전 | VS · P0 |
| 네메시스 중력 | C (후반) | VS 외 |
| 보스 텔레그래프 | C / E | |
| 카메라 연출 | E 연출 | 수치 P2 |
| 클라이맥스 연출 | D/E | 컷신·시퀀스 |
| QTE | — | 핵심 루프에 **필수 아님** |

소설 전투 표현(크기·부위·파일럿 감정)은 연출/서사. 시스템 수치·패턴은 `design/combat` · `BOSS_STATS` · `BOSS_WEAPON_SKILLS`가 구현 원천.

Unreal 설계와 **충돌 없음**. GAS 없이도 Component로 대응 가능.

---

## 4. Episode → Gameplay

초반·VS 연결 구간 분류 (요약):

| EP | 주요 태그 | 비고 |
|----|-----------|------|
| **01** | TUTORIAL · GAMEPLAY · DIALOGUE · COMBAT | 탑승 선택 · GRUNT · 첫 필살 · 카이 씨앗 |
| 02–04 | GAMEPLAY · DIALOGUE · COMBAT | 성장·애착 |
| **05** | COMBAT · BOSS(몬투) · DIALOGUE | 스토리 중보스 · **VS 아님** |
| **06** | **BOSS(세스)** · GAMEPLAY · CUTSCENE | VS 핵심 |
| 07 | GAMEPLAY · DIALOGUE | |
| **08** | GAMEPLAY · CUTSCENE · DIALOGUE | 거점 방어 + 스토리 상실 분리 |
| 09+ | 혼합 | VS 이후 |

Vertical Slice 삼각 = **EP1 · EP6 · EP8** (`state/VERTICAL_SLICE_EP1_6_8.md`).

소설 본문(ep06 등)과 VS 설계 문서가 **동일 보스·톤**을 가리킴.

---

## 5. Vertical Slice 연결

| VS 요소 | 소설·설계 연결 |
|---------|----------------|
| BRAVE | MECHA_BIBLE · CHARACTER_BIBLE · EP01 탑승 |
| ORD-Grunt | EP1 침입자 · VS EP1 적 |
| 보스 세스 | EP6 본문 · CHARACTER_BIBLE · SETH 스펙 · P0 LOCK |
| 전투 지역 1 | EP1 탈출/저지 · EP6 전선 · EP8 거점 (맵 테마 TBD) |
| 전투 목적 | EP1 생존·저지 · EP6 격파 · EP8 거점 사수 |
| 종료 조건 | VS 문서 클리어/실패 표와 정합 |
| 이후 연결 | EP6 후 네메시스 원경 · EP8 상실 → EP9+ |

서사상 필요하나 게임 설계에 빠진 **P0급 구멍 없음**.  
맵 구체 테마·카메라 수치는 기존처럼 TBD/P2.

---

## 6. Novel → Game Data (추출만 · 신규 값 없음)

**Character (게임 관련)**  
- 리아: 플레이 가능 · BRAVE 파일럿 · 16세 등 서사 필드  
- 카이: 비조작 · 통신 습관 H1–H3  
- 세스: 보스 · “해야 해서 처리” · 격파 가능  

**Mecha**  
- BRAVE: 리아 · ~25m · 근접 고속 · 공명/필살  
- 세스기: Elite · ~30m · 차단·씰  
- ORD 양산: Grunt 계열  

**Boss**  
- 세스: Phase 2 · HP 480 (design/state) · VS  
- 몬투: EP5 · VS 아님  
- 네메시스: 최종 · VS 아님  

**Scene (VS)**  
- EP1: 탑승 · 첫 전투 · 카이 비트  
- EP6: 1:1 · 「…보고, 끝.」 · 네메시스 원경 1컷  
- EP8: 거점 + 과부하·희생 (게임 클리어 ≠ 스토리 상실 복구)  

문서에 없는 구체 수치 → **TBD** (기존 설계 문서 참조).

---

## 7. Unreal 연결

| 소설/게임 개념 | Unreal |
|----------------|--------|
| 리아+BRAVE | APlayerMecha / BaseMecha |
| ORD-Grunt | AEnemyMecha |
| 세스 | ABossMecha |
| 공격·피격 | Combat + Damage Component |
| S-Core | USCoreComponent |
| 보스 Phase | Boss 쪽 최소 상태 머신 (1차 이후) |
| 통신·카이 | UI/오디오/레벨 시퀀스 (1차 최소) |
| 장면 | Level · (후) Level Sequence |

과도한 Component 분리 **불필요**. 기존 Readiness 구조로 충분.

---

## 8. 문서 충돌

| 검사 | 결과 |
|------|------|
| VS 보스 세스 vs 소설 EP6 | **일치** |
| 몬투 EP5 vs VS | **의도적 분리** · 충돌 아님 |
| COMBAT_SYSTEM_BIBLE vs Unreal Combat | 표현 vs 시스템 · 충돌 없음 |
| MECHA_BIBLE vs MECHA_DATA_SCHEMA | 정합 · 스키마가 구현 SSOT |
| P0 LOCK | **우선 유지** · 소설로 변경하지 않음 |

소설 CHARACTER_BIBLE의 「EP6 권장 보스」는 이미 세스. P0와 동일.

---

## 9. P0

**없음**

구현 전 반드시 고쳐야 할 소설↔게임↔Unreal 충돌 없음.

---

## 10. P1

- 없음 (보스·Data SSOT는 기정리)
- UE 5.4 패치 확정만 개발 PC 작업 (기존 P1)

소설 쪽 추가 P1 요구 사항으로 막지 않음.

---

## 11. P2

- EP 전체 장면의 완전한 GAMEPLAY/CUTSCENE 태깅 표
- 맵 테마 확정
- 컷신·통신 UI 파이프라인
- 네메시스·몬투 등 VS 외 보스 구현 스케줄
- 소설 묘사 ↔ 애니/VFX 디테일 매핑

---

## 12. 최종 판정

**READY WITH CONDITIONS**

조건 = 기존 Unreal 조건과 동일:
1. 개발 PC에서 UE 5.4.x 패치 LOCK
2. First Build WO 범위만 구현
3. P0 LOCK 변경 금지

소설→게임 연결은 VS·1차 골격에 **충분**하다.

---

## 13. 다음 작업

1. 개발 PC: `state/WORK_ORDER_UNREAL_FIRST_BUILD.md` 실행
2. 소설 원문 추가 수정 **불필요** (현 단계)
3. VS 확장 시 EP1/6/8 설계 문서 + 소설 비트를 참조

회사 측 추가 소설 분석 문서 양산은 비권장. 구현 피드백 후 필요 시만.
