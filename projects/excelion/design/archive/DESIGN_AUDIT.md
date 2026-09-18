# DESIGN_AUDIT — STEP 1

> 2026-08-08  
> 대상: `projects/excelion/design/`  
> 계획: EXCELION_GITHUB_LIMITED_WORK_PLAN STEP 1  
> **위치:** `design/archive/` (2026-08-14 아카이브)

**상태: Done**

---

## 1. 폴더 역할 지도

| 경로 | 역할 | SoR |
|------|------|-----|
| **루트 md** | 품질·참조·큐 | DESIGN_QUALITY·SUPER_ROBOT_MODERN = LOCK / FSS* = 참조 |
| **mecha/** | **기체 제작 단위** (DESCRIPTION + threeview) | 제작 SoR |
| **enemy/** | 적 기체 **스펙 원본** | 스펙 SoR (TEXT-LOCK) |
| **brave/** | BRAVE 스펙 원본 + **컨셉 이미지 풀** | FRAME/EXCELION = 스펙 SoR · PNG = 참고 |
| **nemesis/** | 네메시스 컨셉 이미지 풀 | 참고 (스펙은 enemy/) |
| **character/** | 인물 제작 단위 | 설정+DESCRIPTION |
| **weapon/** | 무기 제작 단위 | DESCRIPTION |
| **env/** | 맵·환경 제작 단위 | DESCRIPTION + MAP_MOOD |
| **effect/** | 광기 시각 | MADNESS_VISUAL |
| **ui/** | UI 최소 | UI_MIN |
| **conti/** | EP01–13 콘티 | 콘티 SoR |
| **anime/** | 애니 보드 | PASS1 |
| **THREEVIEW_CURRENT.md** | 삼면도 큐 (1개씩) | 운영 |

규칙: **스펙 충돌 시 enemy/ · brave/FRAME 원본 우선** · mecha DESCRIPTION은 작업 지시 요약.

---

## 2. 문서 목록 · 상태

### 2.1 루트

| 파일 | 역할 | 상태 |
|------|------|------|
| README.md | 폴더 지도 | OK |
| DESIGN_QUALITY.md | 피니시 상한 | **LOCK** |
| SUPER_ROBOT_MODERN.md | BRAVE 중밀도 | **LOCK** |
| FSS_STYLE_REF.md | FSS 상징 참조 | 참조 · ASHUR 정리됨 |
| FSS_DESIGN_LANGUAGE.md | FSS 문법 참조 | 참조 · 정리됨 |
| FSS_WEAPON_DESIGN.md | FSS 무기 참조 | 참조 · 정리됨 |
| THREEVIEW_CURRENT.md | 큐 | CURRENT=brave · 이미지 HOLD |
| DESIGN_AUDIT.md | 본 문서 | **Done** |

### 2.2 스펙 원본 (enemy/ · brave/)

| 문서 | 대상 | TEXT-LOCK |
|------|------|-----------|
| brave/FRAME_SPEC.md | BRAVE | **Yes** |
| brave/EXCELION_SPEC.md | EP13 전개 | Yes |
| brave/BRAVE_INFLUENCE.md | 영향 문법 | LOCK |
| enemy/ORD_SPEC.md | ORD 4종 | Yes |
| enemy/ORD_OFFICIAL_SETTING.md | ORD 확장 | 초안→통합됨 |
| enemy/ORD_VISUAL_LANGUAGE.md | Order 그림체 | LOCK |
| enemy/SETH_MECHA_SPEC.md | 세스기 | Yes |
| enemy/CREIL_MECHA_SPEC.md | 크레일 | **Yes** (2026-08-08) |
| enemy/AEGIS_MECHA_SPEC.md | 아이기스 | **Yes** (2026-08-08) |
| enemy/NEMESIS_MECHA_SPEC.md | 네메시스기 | Yes (후보→운용) |

### 2.3 제작 단위 (mecha/)

| 폴더 | DESCRIPTION | FINAL_SPEC | threeview PNG |
|------|-------------|------------|---------------|
| brave | Yes | **Yes** | **없음** (HOLD) |
| excelion | Yes | No | 없음 |
| seth | Yes | No | 없음 |
| creil | Yes | No | 없음 |
| aegis | Yes | No | 없음 |
| nemesis | Yes | No | 없음 |
| ord-grunt/heavy/gun/mid | Yes | ORD_FINAL 통합 | 없음 |

공통: `mecha/ORD_FINAL_SPEC.md` · `MECHA_MASTER_LIST.md` · `threeview/SKILL.md` · `TOPOLOGY_GUIDE.md`

### 2.4 인물 · 무기 · 환경 · 기타

| 영역 | 상태 |
|------|------|
| character (lia/kai/rei/yuna/seth) | DESCRIPTION + OFFICIAL · threeview PNG 대부분 미커밋 |
| weapon (brave-*, seth-*) | DESCRIPTION만 · 얇음 |
| env (4맵) | DESCRIPTION + MAP_MOOD · props 빈 폴더 |
| effect | MADNESS_VISUAL Done |
| ui | UI_MIN Done |
| conti | EP01–13 Done |
| anime | PASS1_BOARD Done |

---

## 3. SoR 우선순위 (충돌 시)

```
1. novel/ + docs/ (스토리·세계관 캐논)
2. enemy/*_MECHA_SPEC · brave/FRAME_SPEC · EXCELION_SPEC
3. mecha/*/FINAL_SPEC · ORD_FINAL_SPEC
4. mecha/*/DESCRIPTION · character/*/DESCRIPTION
5. 컨셉 PNG (brave/ · nemesis/) — 채택 시에만 · QUALITY 미달 시 제외
```

---

## 4. 중복 · 폐기

| 유형 | 내용 |
|------|------|
| **폐기** | ashur 전 경로 (2026-08-07) · 문서 잔여 정리 완료 (FSS) |
| **이중 구조** | 스펙(enemy/brave) vs 제작(mecha) — **의도적** · 유지 |
| **컨셉 풀** | design/brave/*.png · design/nemesis/*.png — 참고 전용 · 삭제 금지 |
| **통합본** | ORD_FINAL_SPEC = ORD 4종 통합 · 개별 ORD_*_FINAL 미분리 |
| **요약 FINAL** | BRAVE_FINAL_SPEC = 제작 요약 · 30절 계획 수준 아님 |

---

## 5. 메카 체계 vs MASTER_LIST

| ID | MASTER | 스펙 | 제작 DESCRIPTION | 계획 FINAL(30절) |
|----|--------|------|------------------|------------------|
| BRAVE | EXISTING | FRAME+FINAL | Yes | 부분 |
| EXCELION | EXISTING | EXCELION_SPEC | Yes | 미착수 |
| NEMESIS | EXISTING | NEMESIS_SPEC | Yes | 미착수 |
| SETH | EXISTING | SETH_SPEC | Yes | 미착수 |
| CREIL | EXISTING | CREIL_SPEC LOCK | Yes | 미착수 |
| AEGIS | EXISTING | AEGIS_SPEC LOCK | Yes | 미착수 |
| ORD-GRUNT/MID/GUN/HEAVY | EXISTING | ORD_FINAL | Yes | 부분(통합) |
| SUPPORT | UNCONFIRMED | — | — | STEP 11 |
| INTERNAL | UNCONFIRMED | — | — | STEP 11 |
| OBSERVE | UNCONFIRMED | — | — | STEP 11 |

MISSING: 0

---

## 6. 참조 관계 (요약)

```
FRAME_SPEC ──► BRAVE_FINAL_SPEC ──► mecha/brave/DESCRIPTION
EXCELION_SPEC ──► mecha/excelion/
ORD_SPEC + OFFICIAL + VISUAL ──► ORD_FINAL_SPEC ──► mecha/ord-*
SETH/CREIL/AEGIS/NEMESIS_SPEC ──► mecha/{seth,creil,aegis,nemesis}/
DESIGN_QUALITY + SUPER_ROBOT_MODERN ──► 전 mecha 피니시
FSS_* ──► 표면·문법 참고만 (TEXT-LOCK 비덮어쓰기)
THREEVIEW_CURRENT ──► mecha/*/threeview 순회
conti + novel ──► 스토리 검증 (STEP 2)
```

---

## 7. 갭 (계획 30절 FINAL 기준)

현재 TEXT-LOCK 스펙은 **실루엣·색·금지·기본 역할** 중심.

계획서 요구(공통 구조 01–30) 대비 **대부분 미작성**:

- Mechanical Structure / Armor / Propulsion / Power
- Weapons 상세 · Defensive Systems · Special Systems
- **Combat Loop · AI · Weakness · Damage States**
- VFX/SFX · Animation
- Three-view / Turnaround / Exploded / Weapon Sheet 요구사항 상세
- **Game Implementation** (신호→대응→판정→경직→종료)

→ STEP 4 이후 FINAL은 **전투·구현 레이어 보강**이 핵심.

---

## 8. 이슈 요약

| # | 이슈 | 심각도 |
|---|------|--------|
| 1 | 삼면도 PNG 전 기체 미커밋 (HOLD) | 운영 |
| 2 | 계획 30절 FINAL 미달 (전투루프·구현) | 높음 (후속 STEP) |
| 3 | NEMESIS_SPEC 상태 문구 “후보” 잔여 가능 | 낮음 |
| 4 | weapon DESCRIPTION 얇음 | 중 |
| 5 | UNCONFIRMED 3건 미판정 | STEP 11 |
| 6 | conti EP14–24 없음 (S1 후반 콘티 갭) | 스토리 트랙 |

---

## 9. 상태 블록

```
CURRENT: STEP 1 DESIGN_AUDIT Done
DONE: design/ 구조·SoR·중복·참조·갭 정리
NEXT: STEP 2 STORY_DESIGN_CONFLICTS (EP01~24 × design)
BLOCKED: 이미지 생성 HOLD
SOURCE: design/** · mecha/MECHA_MASTER_LIST · DESIGN_TASK_MAP
DECISIONS:
  - 스펙 SoR = enemy/ + brave/FRAME|EXCELION
  - 제작 SoR = mecha/
  - 현재 FINAL = 요약 TEXT-LOCK · 30절은 후속 STEP
OPEN QUESTIONS:
  - ORD를 BASE+4종 개별 FINAL로 쪼갤지 여부
  - NEMESIS_SPEC “후보” 문구 정리 시점
```

**STEP 1 = Done. 히스토리 보존.**
