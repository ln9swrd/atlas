# ORD-GRUNT Git Audit — 2026-08-12 (recheck)

> 조사 및 기록만. 설정/디자인/스토리 창작·수정 없음.
> Unreal 미실행. 이전 감사(HEAD 2b5c903) 이후 G1/G2 반영분 포함 재조사.

## 조사 기준

| 항목 | 값 |
|------|-----|
| HEAD | `577956da40ae8d9cc7cd0ab938e394cecd3e91b1` |
| 날짜 | 2026-08-12 |
| Branch | main |
| Working tree | CLEAN (원격 기준) |
| Open Excelion PR | 없음 |
| 직전 관련 커밋 | `577956da` docs(excelion): apply ORD-GRUNT G1/G2 SoR wording (DECISION C) (#106) |
| 이전 감사 커밋 | `30161132` docs(excelion): audit ORD-GRUNT documentation (#105) |

## 검색 범위

`projects/excelion/` 전체:

- design/ (mecha/ord-grunt, enemy/ORD_*, MECHA_STATUS, DESIGN_AUDIT, THREEVIEW_CURRENT …)
- state/ (CURRENT_STATE, TASK_MAP, DESIGN_TASK_MAP, ORD_GRUNT_* 시리즈, BALANCE_*)
- docs/ (ASSET_REGISTER, VERTICAL_SLICE, UNREAL_*, TECHNICAL_REQUIREMENTS …)
- novel/ (EPISODE_MATRIX, ORD_REMNANT_*, ep17)
- backlog.json · README · PROJECT_MEMORY · sprints/

키워드: ORD-GRUNT, ORD_GRUNT, GRUNT, EX-GRUNT, 관련 task/design 경로

---

## 현재 정의

| 항목 | Git 근거 | 내용 |
|------|----------|------|
| 역할 | ORD_SPEC · MECHA_STATUS · DESCRIPTION | 전 구간 **양산 잡** · 섬멸 대상 · “많이 나온다” · 수 압박 |
| 분류 | ORD_FINAL_SPEC · ORDER 진영 · DESCRIPTION | Order 양산 실행 단위 · SUPER ROBOT(적대 과장) · 성장 없음 |
| 관련 세력/메카 | ORD_SPEC · ORD_FINAL · MECHA | Order · 형제: HEAVY / GUN / MID · VS 주역 AXION(구 BRAVE) |
| 스토리 위치 | EPISODE_MATRIX · conti · novel · BALANCE | EP01+ · VS 후보 · 잔당 전술(GRUNT 주력) |

**Shape 문장 (ORD_FINAL / DESCRIPTION):** 떼로 덮치는 하층 투기 기계

**전투 루프:** 스폰 → 접근 → 압박 → 쉽게 파괴

---

## 디자인 정의

### 확인된 정의

| 항목 | 근거 |
|------|------|
| 실루엣 키워드 | 각 · 작음 · 양산 (ORD_SPEC) |
| SUPER ROBOT 조형 | 저중심 · 짧은 목 · 넓은 골반 · 떼로 읽히는 한 덩어리 (DESCRIPTION) |
| 3TONE 방향 | T1 산화철/황토 · T2 흙·암회 · T3 센서 적/냉점 (DESCRIPTION · ORD_FINAL) |
| 무장 | 내장 화기 또는 단순 블레이드 · 거대 실루엣 파괴 무기 없음 |
| 텍스트 실루엣 3안 | `ORD_GRUNT_SILHOUETTE_CONCEPTS_2026-08-09.md` — SWARM COLUMN / RAM FRAME / SCRAP HOUND |
| Shortlist | **SWARM COLUMN** = 1순위 (DETAIL · COMBAT_RULES · CONSISTENCY · DESIGN_GATE) |
| SWARM COLUMN 상세 | 낮고 압축 · 하체 질량 · 집단 압박 덩어리 |
| 삼면도 | STOP · 폴더 `mecha/ord-grunt/threeview` 존재하나 .gitkeep만 (THREEVIEW_CURRENT) |
| 이미지/M5 | HOLD |

### 미정 항목

| 항목 | 상태 |
|------|------|
| SWARM COLUMN **최종 LOCK** (단독 공식 채택) | Master 승인 전 미확정 (DESIGN_GATE · NEXT_STAGE_DECISION) |
| 흑실루엣·이미지 시각 고정 | 미착수 |
| 삼면도 · 토폴로지 | 미착수 |
| Meshy / Blender / FBX / UE 구현 | HOLD |
| 스테이지별 스폰 상한·웨이브 확정 | 미확정 (BALANCE 인용 수준) |
| 실기 밸런스 재측정 | 미착수 |

임의 보완하지 않음.

---

## 현재 작업 상태

| 레이어 | 상태 | 근거 |
|--------|------|------|
| 역할·전투·Loop 텍스트 | **Done / TEXT-LOCK 계열** | ORD_SPEC · ORD_FINAL · DESCRIPTION |
| 실루엣 텍스트 3안 | **Done** | ORD_GRUNT_SILHOUETTE_CONCEPTS · TASK_MAP |
| SWARM COLUMN 상세·전투규칙·정합 | **텍스트 패키지 내부 정합 완료** | DESIGN_GATE CONFLICT: 0 |
| 제품 SoR | **DECISION C = HOLD** | CURRENT_STATE · TASK_MAP · DESIGN_TASK_MAP (G1/G2 반영 후) |
| 시각화 / 삼면도 / 구현 | **HOLD** | DESIGN_GATE · M5 HOLD · DECISION C |
| Master 후속 결정 | **DECISION C (HOLD) 반영** | CURRENT_STATE · #106 |

**핵심:** 텍스트 실루엣 3안 및 shortlist 상세는 존재. SoR 운영 문서는 DECISION C HOLD로 동기화됨 (G1/G2 해소).

---

## 관련 Task

### TASK_MAP

| Task | Status | Evidence |
|------|--------|----------|
| ORD-GRUNT 실루엣 텍스트 3안 | **Done** | ORD_GRUNT_SILHOUETTE_CONCEPTS_2026-08-09 |
| ORD-GRUNT shortlist 후속 (LOCK / 시각 / 구현) | **Hold** | DESIGN_GATE · NEXT_STAGE_DECISION · DECISION C |

### DESIGN_TASK_MAP

| Phase | 상태 |
|-------|------|
| ORDER REBOOT Phase 2: ORD 4종 실루엣 3안 | **Partial** — GRUNT 텍스트 3안 Done · HEAVY/GUN/MID 미착수 (text only) |
| NEXT (제품) | DECISION C = HOLD (ORD-GRUNT 후속 착수 없음) · Phase 2 잔여 3종 = Open |

### backlog.json

- Parser: **PASS**
- status: HOLD (전체)
- ORD-GRUNT / GRUNT 관련 item: **없음**
- items: EX-BRAVE-001..004 only (HOLD)

---

## 문서 정합성

### 일치 사항

- 역할·양산·섬멸·EP01+ 전 문서 일치
- Shape 문장·전투 루프 ORD_FINAL ↔ DESCRIPTION ↔ SWARM COLUMN DETAIL 일치
- Shortlist 1순위 = SWARM COLUMN (GATE · NEXT_STAGE · DETAIL)
- 이미지/삼면도/UE HOLD 일치
- backlog에 ORD 항목 없음 ↔ 시각화/모델링 HOLD 정책과 모순 없음
- **G1 해소:** CURRENT_STATE / TASK_MAP이 “3안 Done · DECISION C HOLD”로 반영
- **G2 해소:** DESIGN_TASK_MAP Phase 2 = Partial (GRUNT Done · 잔여 Open), NEXT = HOLD

### 잔여 경미 이슈 (현재 상태 관점)

| ID | 내용 | 근거 |
|----|------|------|
| G3 | DESCRIPTION “**맹수형 마스크**” vs ORD_SPEC 키워드 “**각 · 작음 · 양산**” · SWARM COLUMN “낮고 각진” 계열 | DESCRIPTION.md vs ORD_SPEC · SWARM COLUMN DETAIL. DESCRIPTION 구 시각은 SUPERSEDED 표기. 창작 없이 표현만 정리 여부 판단 가능 |

### 역사적 기록 (충돌 아님)

- conti/소설의 BRAVE·GRUNT 표기
- DESIGN_AUDIT의 ORD_FINAL 통합 이력
- GATE/NEXT_STAGE의 Master 미결정 → DECISION C 반영 이력
- 이전 감사 문서의 G1/G2 (이미 #106으로 해소)

---

## 수정 후보

| ID | 후보 | 근거 파일 | 이유 | 권장 |
|----|------|-----------|------|------|
| G3 | 두부 표현 정합 표기만 (창작 없음) — 어느 쪽을 현행으로 둘지 한 줄 | DESCRIPTION · ORD_SPEC · SWARM COLUMN DETAIL | 경미한 표현 차이 | Master 판단 전 유지 가능 |

이번 커밋에서는 **수정하지 않음**.

---

## 결론

**판정: A — 정의/상태 정합성 양호** (G1/G2 해소 후)

- ORD-GRUNT **정의·역할·전투·shortlist 텍스트**는 충분히 문서화되어 있고 내부 정합이 높다.
- SoR 운영 문서(CURRENT_STATE · TASK_MAP · DESIGN_TASK_MAP)는 DECISION C HOLD로 동기화됨.
- 잔여 G3는 표현 수준이며 제품 진행을 막지 않음.
- 최종 LOCK·시각화·구현은 계속 Master 게이트 (DECISION C = HOLD).

---

## 다음 Git 작업

1. G3는 Master 한 줄 판단 전 유지
2. 제품 작업: Master가 DECISION을 A1/A2/A3/B로 변경할 때만 착수
3. Unreal/이미지/삼면도는 계속 금지·HOLD
4. 본 재감사 문서 merge 후 이전 감사 문서와 병존 (이력)

본 문서는 조사 기록이다. 자동 merge 대상이 아니며, 기존 설계 본문을 변경하지 않는다.
