# ORD-GRUNT Git Audit — 2026-08-12

> 조사 및 기록만. 설정/디자인/스토리 창작·수정 없음.  
> Unreal 미실행.

## 조사 기준

| 항목 | 값 |
|------|-----|
| HEAD | `2b5c90300194320e6965b76c9786543bdebdf54f` |
| 날짜 | 2026-08-12 |
| Branch | main |
| Working tree | CLEAN |
| Open Excelion PR | 없음 |

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
| 역할 | ORD_OFFICIAL · ORD_SPEC · MECHA_STATUS | 전 구간 **양산 잡** · 섬멸 대상 · “많이 나온다” |
| 분류 | ORD_FINAL_SPEC · ORDER 진영 | Order 양산 실행 단위 · SUPER ROBOT(적대 과장) · 성장 없음 |
| 관련 세력/메카 | ORD_OFFICIAL · MECHA_MASTER_LIST | Order · 형제: HEAVY / GUN / MID(몬투) · VS 주역 AXION(구 BRAVE) |
| 스토리 위치 | MECHA_STORY_APPEARANCE · EPISODE_MATRIX · conti | EP01+ · VS 후보 · 잔당 전술(GRUNT 주력) |

**Shape 문장 (ORD_FINAL / DESCRIPTION):** 떼로 덮치는 하층 투기 기계

**전투 루프:** 스폰 → 접근 → 압박 → 쉽게 파괴

---

## 디자인 정의

### 확인된 정의

| 항목 | 근거 |
|------|------|
| 실루엣 키워드 | 각 · 작음 · 양산 (ORD_SPEC / OFFICIAL) |
| SUPER ROBOT 조형 | 저중심 · 짧은 목 · 넓은 골반 · 떼로 읽히는 한 덩어리 (DESCRIPTION) |
| 3TONE 방향 | T1 산화철/황토 · T2 흙·암회 · T3 센서 적/냉점 (DESCRIPTION · ORD_FINAL) |
| 무장 | 내장 화기 또는 단순 블레이드 · 거대 실루엣 파괴 무기 없음 |
| 텍스트 실루엣 3안 | `ORD_GRUNT_SILHOUETTE_CONCEPTS_2026-08-09.md` — SWARM COLUMN / RAM FRAME / SCRAP HOUND |
| Shortlist | **SWARM COLUMN** = 1순위 (DETAIL · COMBAT_RULES · CONSISTENCY · DESIGN_GATE) |
| SWARM COLUMN 상세 | 낮고 압축 · 하체 질량 · 집단 압박 덩어리 · 두부 낮고 각진 |
| 삼면도 | STOP · 폴더 `mecha/ord-grunt/threeview` 존재하나 실루엣 3안 후 착수 (THREEVIEW_CURRENT) |
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
| 역할·전투·Loop 텍스트 | **Done / TEXT-LOCK 계열** | ORD_SPEC · ORD_FINAL · MECHA_STATUS Description Done |
| 실루엣 텍스트 3안 | **산출물 존재 (2026-08-09)** | ORD_GRUNT_SILHOUETTE_CONCEPTS |
| SWARM COLUMN 상세·전투규칙·정합 | **텍스트 패키지 내부 정합 완료** | DESIGN_GATE CONFLICT: 0 |
| 제품 SoR Next 표기 | **여전히 “실루엣 텍스트 3안”** | CURRENT_STATE · TASK_MAP · DESIGN_TASK_MAP |
| 시각화 / 삼면도 / 구현 | **HOLD / Open** | DESIGN_GATE · M5 HOLD · MECHA_STATUS |
| Master 후속 결정 | **미응답 (권고 C. HOLD)** | ORD_GRUNT_NEXT_STAGE_DECISION |

**핵심:** 텍스트 실루엣 3안 및 shortlist 상세는 **이미 존재**한다. SoR 운영 문서의 Next 문구는 그 이전 단계 표현으로 남아 있다.

---

## 관련 Task

### TASK_MAP

| Task | Status | Evidence 열 |
|------|--------|-------------|
| ORD-GRUNT 실루엣 텍스트 3안 | **Next** | DESIGN_TASK_MAP |

### DESIGN_TASK_MAP

| Phase | 상태 |
|-------|------|
| ORDER REBOOT Phase 2: ORD **4종** 실루엣 3안 | **Next** (text only) |
| 하단 NEXT 줄 | ORD-**GRUNT** silhouette 3 concepts (text only) |

**차이:** Phase 2는 4종 전체, 하단/CURRENT_STATE/TASK_MAP은 GRUNT 단일. GRUNT 3안 문서는 존재; HEAVY/GUN/MID(몬투) 개별 실루엣 3안 문서는 이 조사에서 동일 형식의 전용 파일로 확인되지 않음.

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

### 충돌·불일치 (현재 상태 관점)

| ID | 내용 | 근거 |
|----|------|------|
| G1 | SoR **Next = 실루엣 텍스트 3안** 인데, 3안+shortlist 상세 **이미 존재** | CURRENT_STATE · TASK_MAP vs state/ORD_GRUNT_*_2026-08-09.md · DESIGN_GATE |
| G2 | DESIGN_TASK Phase 2 = **4종** 실루엣 3안 vs 제품 Next = **GRUNT만** | DESIGN_TASK_MAP 본문 불일치 |
| G3 | OFFICIAL 실루엣 “**각진 두부**” vs DESCRIPTION “**맹수형 마스크**” | ORD_OFFICIAL §2 vs mecha/ord-grunt/DESCRIPTION — SWARM COLUMN DETAIL은 “낮고 각진”으로 OFFICIAL에 가깝고, DESCRIPTION 구 시각은 SUPERSEDED 표기 |

### 역사적 기록 (충돌 아님)

- conti/소설의 BRAVE·GRUNT 표기
- DESIGN_AUDIT의 ORD_FINAL 통합 이력
- GATE/NEXT_STAGE의 Master 미결정 기록

---

## 수정 후보

| ID | 후보 | 근거 파일 | 이유 | 권장 |
|----|------|-----------|------|------|
| G1 | CURRENT_STATE / TASK_MAP Next 문구를 “텍스트 3안 완료 · shortlist SWARM COLUMN · Master LOCK/후속 대기” 등으로 **현재 산출물에 맞게** 갱신 | CURRENT_STATE.md · TASK_MAP.md · DESIGN_GATE | 작업 상태가 실제 산출물과 어긋남 | **Master 승인 후** 최소 문구 수정 |
| G2 | DESIGN_TASK_MAP Phase 2 범위 명확화 (GRUNT만 완료 / 4종 잔여 Open) | DESIGN_TASK_MAP.md | Phase 라벨과 NEXT 줄 불일치 | 승인 후 |
| G3 | 두부 표현 정합 (OFFICIAL vs DESCRIPTION) — 창작 없이 어느 쪽을 현행으로 둘지 표기만 | ORD_OFFICIAL · DESCRIPTION · SWARM COLUMN DETAIL | 경미한 표현 차이 | 판단 불명확 시 유지 · Master |

이번 커밋에서는 **수정하지 않음**.

---

## 결론

**판정: B — 경미한 정합성 수정 필요**

- ORD-GRUNT **정의·역할·전투·shortlist 텍스트**는 충분히 문서화되어 있고 내부 정합이 높다.
- 문제는 주로 **운영 SoR(Next 표기)** 가 2026-08-09 텍스트 패키지 완료 이후를 반영하지 못한 점(G1)과 Phase 2 범위 표기(G2).
- 신규 디자인 창작이 아니라 **상태 문구 동기화** 수준의 후속이면 충분하다.
- 최종 LOCK·시각화·구현은 계속 Master 게이트 (NEXT_STAGE 권고 C. HOLD와 정합).

---

## 다음 Git 작업

1. (승인 시) G1·G2 최소 문구 패치 — CURRENT_STATE / TASK_MAP / DESIGN_TASK_MAP만  
2. G3는 Master 한 줄 판단 전 유지  
3. 제품 작업: Master DECISION (A1 흑실루엣 / B 추가 텍스트 / C HOLD) 후에만 착수  
4. Unreal/이미지/삼면도는 계속 금지·HOLD  

본 문서는 조사 기록이다. 자동 merge 대상이 아니며, 기존 설계 본문을 변경하지 않는다.
