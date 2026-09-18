# Excelion Design Reorganization Plan

> 2026-08-14  
> 대상: `projects/excelion/design/` 전체  
> 목적: 구조 개편 전 역할·중복·충돌·유효성 조사 + 재구성 계획  
> **이번 단계: 분석만. 기존 파일 수정·이동·삭제·이름변경 금지.**

---

## 1. Audit Summary

- **조사 범위**: `projects/excelion/design/` 이하 모든 파일·하위 디렉터리 (tree recursive).
- **파일 수 (대략)**: 텍스트(.md) 약 120개 이상 + 컨셉 이미지(PNG/JPG) 다수 + 빈 threeview/.gitkeep.
- **기존 감사 문서**: `DESIGN_AUDIT.md` (2026-08-08, STEP 1 Done), `MECHA_STATUS.md`, `STORY_DESIGN_CONFLICTS.md`, `UNCONFIRMED_MECHA_REVIEW.md` 가 이미 존재하며 상당 부분 정합.
- **핵심 발견**:
  - 스펙 SoR (`enemy/`, `brave/FRAME_SPEC` 등) vs 제작 단위 (`mecha/`) 이중 구조는 **의도적**이며 유지 권장.
  - 품질·정체성 LOCK 문서군 (`DESIGN_QUALITY`, `SUPER_ROBOT_MODERN`, `MECHA_3TONE_LOW_DETAIL`) 은 유효.
  - FSS 계열은 **REFERENCE** 로 명확히 구분됨 (TEXT-LOCK 비덮어쓰기 명시).
  - 전투·구현 레이어 (`design/combat/`) 는 Prototype 실행 기준으로 사용 가능.
  - 삼면도 PNG 전무 (HOLD) · 일부 FINAL_SPEC 미완성 · weapon DESCRIPTION 얇음.
  - Novel ↔ Design 차단급 충돌 **없음** (STORY_DESIGN_CONFLICTS 확인).
  - 최근 추가된 `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` (LOCK 후보) 와 기존 `SUPER_ROBOT_MODERN.md` 간 계층·강조점 정리 필요.

**목표 재확인**: 파일 수 축소가 목적이 아님.  
**“Unreal 구현자가 어떤 문서를 기준으로 작업해야 하는가?”** 를 명확히 하는 것.

---

## 2. Current Document Inventory

| File / Path | Role | Status | Duplicate | Conflict | Recommendation |
|-------------|------|--------|-----------|----------|----------------|
| **README.md** | 폴더 지도 · SoR 요약 | OK | 없음 | 없음 | CANON (입구) |
| **DESIGN_AUDIT.md** | 이전 감사 (STEP 1) | Done | 본 문서와 일부 중복 | 없음 | ARCHIVE_CANDIDATE 또는 히스토리 유지 |
| **DESIGN_QUALITY.md** | 피니시 상한 (로봇혼/센티넬) | **LOCK** | 없음 | 없음 | **CANON** |
| **SUPER_ROBOT_MODERN.md** | 슈퍼로봇 모던 패널·근골 | **LOCK** | SUPER_ROBOT_DESIGN_LANGUAGE 와 일부 중복 | 계층 정리 필요 | **CANON** |
| **MECHA_3TONE_LOW_DETAIL.md** | 3톤·패널 레벨 상한 | **LOCK** | 없음 | 없음 | **CANON** |
| **FSS_STYLE_REF.md** | FSS 상징·적용 한도 | 참조 | 없음 | 없음 | **REFERENCE** |
| **FSS_DESIGN_LANGUAGE.md** | FSS 읽힘순서·위계 | 참조 | 없음 | 없음 | **REFERENCE** |
| **FSS_WEAPON_DESIGN.md** | FSS 무기 문법 | 참조 | 없음 | 네메시스 원격과 명시적 비충돌 | **REFERENCE** |
| **MECHA_STATUS.md** | 기체별 상태표 | Done | 없음 | 없음 | IMPLEMENTATION / 운영 |
| **THREEVIEW_CURRENT.md** | 삼면도 큐 | 운용 | 없음 | 없음 | IMPLEMENTATION |
| **GAME_COMBAT_INDEX.md** | 전투 문서 색인 | 운용 | 없음 | 없음 | **IMPLEMENTATION** |
| **STORY_DESIGN_CONFLICTS.md** | Novel×Design 교차 | Done | 없음 | 경미 2건만 | 히스토리 / REFERENCE |
| **UNCONFIRMED_MECHA_REVIEW.md** | SUPPORT/INTERNAL/OBSERVE 판정 | Done | 없음 | 없음 | ARCHIVE_CANDIDATE (판정 완료) |
| **brave/FRAME_SPEC.md** | BRAVE 실루엣·색·금지 | **TEXT-LOCK** | 없음 | 없음 | **CANON** |
| **brave/EXCELION_SPEC.md** | EP13 전개 | TEXT-LOCK | 없음 | 없음 | **CANON** |
| **brave/BRAVE_INFLUENCE.md** | 진겟타·마징가·드론/핀 문법 | **LOCK** | 없음 | 없음 | **CANON** |
| **brave/*.png** | 컨셉 이미지 풀 | 참고 | 없음 | 품질 미달 시 채택 금지 | **REFERENCE** |
| **enemy/*_MECHA_SPEC / ORD_*** | 적 기체 스펙 원본 | TEXT-LOCK | mecha/ 와 의도적 이중 | 없음 | **CANON** (스펙 SoR) |
| **mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md** | 전 메카 SUPER ROBOT FIRST | LOCK 후보 | SUPER_ROBOT_MODERN 과 중복 | 계층·곡선 강조 차이 | **REVIEW** → Master 승인 후 CANON |
| **mecha/ORDER_DESIGN_LANGUAGE.md** | ORDER 진영 조형 | LOCK | 없음 | 상위 SUPER_ROBOT 문서와 정합 | **CANON** |
| **mecha/*/FINAL_SPEC.md** | 제작 요약 스펙 | 부분 Done | 스펙 원본과 요약 관계 | 없음 | **IMPLEMENTATION** / CANON 후보 |
| **mecha/*/DESCRIPTION.md** | 제작 작업 지시 | 대부분 Done | 없음 | 없음 | **IMPLEMENTATION** |
| **mecha/MECHA_MASTER_LIST.md** | 기체 목록 | OK | 없음 | 없음 | **CANON** |
| **mecha/MECHA_DATA_SCHEMA.md** | 데이터 스키마 | OK | 없음 | 없음 | **IMPLEMENTATION** |
| **mecha/threeview/SKILL.md · TOPOLOGY_GUIDE.md** | 삼면도·토폴로지 | OK | character/threeview/SKILL 과 유사 | 없음 | **IMPLEMENTATION** |
| **character/*/OFFICIAL_SETTING.md** | 인물 공식 설정 | TEXT-LOCK 계열 | 없음 | 없음 | **CANON** |
| **character/*/DESCRIPTION.md** | 인물 제작 지시 | OK | 없음 | 없음 | **IMPLEMENTATION** |
| **combat/** (전체) | 전투 루프·패턴·수치·구현맵 | Prototype 운용 | 없음 | 없음 | **IMPLEMENTATION** |
| **gameplay/COMBAT_SYSTEM.md · CORE_GAMEPLAY.md** | 게임플레이 상위 | OK | combat/ 와 일부 중복 가능 | 정리 필요 | **IMPLEMENTATION** / REVIEW |
| **weapon/*/DESCRIPTION.md** | 무기 제작 지시 | 얇음 | 없음 | 없음 | **IMPLEMENTATION** (보강 필요) |
| **env/** · **effect/** · **ui/** · **conti/** · **anime/** | 환경·이펙트·UI·콘티·애니 | 대부분 Done | 없음 | 없음 | 영역별 CANON / IMPLEMENTATION |
| **nemesis/*.png** | 네메시스 컨셉 풀 | 참고 | 없음 | 없음 | **REFERENCE** |

*주: 모든 DESCRIPTION.md, .gitkeep, 빈 threeview 폴더는 IMPLEMENTATION 지원 또는 운영용으로 분류. 상세 목록은 필요 시 확장.*

---

## 3. Canon Candidates

### 디자인 정체성 · 원칙
- `DESIGN_QUALITY.md` — 피니시 상한 (LOCK)
- `SUPER_ROBOT_MODERN.md` — 모던 슈퍼로봇 패널 원칙 (LOCK)
- `MECHA_3TONE_LOW_DETAIL.md` — 3톤·패널 레벨 하드 상한 (LOCK)
- `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` — SUPER ROBOT FIRST · 곡선·영웅 조형 (**LOCK 후보** → Master 승인 필요)
- `mecha/ORDER_DESIGN_LANGUAGE.md` — ORDER 진영 조형 (LOCK)

### 메카 · 무기 · 비율
- `brave/FRAME_SPEC.md` (BRAVE TEXT-LOCK)
- `brave/EXCELION_SPEC.md`
- `brave/BRAVE_INFLUENCE.md`
- `enemy/ORD_SPEC.md` · `ORD_OFFICIAL_SETTING.md` · `ORD_VISUAL_LANGUAGE.md`
- `enemy/SETH_MECHA_SPEC.md` · `CREIL_MECHA_SPEC.md` · `AEGIS_MECHA_SPEC.md` · `NEMESIS_MECHA_SPEC.md`
- `mecha/MECHA_MASTER_LIST.md`
- `mecha/*/FINAL_SPEC.md` (존재하는 것: BRAVE, AEGIS, CREIL, NEMESIS, SETH, EXCELION 등)

### 캐릭터
- `character/*/OFFICIAL_SETTING.md` (lia, kai, seth, yuna, rei 등)

### 3면도 기준
- `mecha/threeview/SKILL.md` · `TOPOLOGY_GUIDE.md`
- `character/threeview/SKILL.md`

**원칙 재확인**: Excelion 최종 정체성은 **Super Robot**. FSS는 표면·읽힘 문법 참고만. 현재 문서들은 이 원칙과 충돌하지 않음 (FSS 문서에 명시적 한도 존재).

---

## 4. Implementation Candidates

Unreal / 프로토타입 구현자가 직접 참조해야 할 문서군.

- `design/combat/` 전체 (`PATTERN_EXECUTION_SPEC`, `COMBAT_LOOP`, `FEEDBACK_SYSTEM`, `ANUBIS_MECHANICS`, `BOSS_STATS`, `IMPLEMENTATION_MAP`, `DIFFICULTY_CURVE`, `SKILL_COUNTER_TABLE`, `TUNING_GUIDE`)
- `GAME_COMBAT_INDEX.md`
- `gameplay/COMBAT_SYSTEM.md` · `CORE_GAMEPLAY.md`
- `mecha/*/DESCRIPTION.md` · `FINAL_SPEC.md`
- `mecha/MECHA_DATA_SCHEMA.md`
- `THREEVIEW_CURRENT.md`
- `mecha/threeview/*` · `character/*/threeview/*`
- `weapon/*/DESCRIPTION.md`
- `test/COMBAT_TEST_SCENARIOS.md`
- `ui/UI_MIN.md` · `effect/MADNESS_VISUAL.md`

---

## 5. Reference Documents

- `FSS_STYLE_REF.md`
- `FSS_DESIGN_LANGUAGE.md`
- `FSS_WEAPON_DESIGN.md`
- `brave/` · `nemesis/` 루트 컨셉 PNG/JPG (채택 시에만 · DESIGN_QUALITY 미달 시 제외)
- `STORY_DESIGN_CONFLICTS.md` (히스토리)
- `DESIGN_AUDIT.md` (이전 감사 기록)

FSS 문서는 모두 “TEXT-LOCK 비덮어쓰기 · Excelion은 Super Robot” 원칙을 명시. 충돌 없음.

---

## 6. Review / Unconfirmed Documents

- `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` — LOCK 후보. 기존 SUPER_ROBOT_MODERN과의 계층·우선순위 Master 확인 필요.
- 일부 `mecha/*/FINAL_SPEC.md` — 30절 수준 미달 (전투 루프·Damage·AI·구현 레이어 보강 필요).
- `weapon/*/DESCRIPTION.md` — 내용 얇음. 보강 또는 FINAL 연동 필요.
- `gameplay/` vs `combat/` — 역할 경계 재확인 권장.
- UNCONFIRMED 3건 (SUPPORT/INTERNAL/OBSERVE) — 이미 STEP 11에서 비승격 판정 완료. 설정집 작성 금지 유지.

---

## 7. Archive Candidates

- `DESIGN_AUDIT.md` — STEP 1 완료 문서. 히스토리로 유지하거나 archive/ 이동 후보.
- `UNCONFIRMED_MECHA_REVIEW.md` — 판정 완료. 히스토리 유지 가능.
- 폐기 완료된 ashur 관련 잔여 (이미 정리됨, 추가 조치 불필요).
- 빈 threeview/.gitkeep 은 유지 (운영용).

**삭제 금지**: 역사적/참고 가치가 있는 문서는 Archive로만 분류.

---

## 8. Document Conflicts

| ID | 내용 | 심각도 | 권장 |
|----|------|--------|------|
| C-SR1 | `SUPER_ROBOT_MODERN.md` (중밀도 패널·근골) vs `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` (SUPER ROBOT FIRST · 곡선 우선 · 건담 금지) | 중 | 계층 확정: SUPER_ROBOT_DESIGN_LANGUAGE를 최상위, MODERN을 BRAVE/중밀도 특화로 둘지 Master 결정 |
| C-SR2 | 두 문서의 프롬프트·검증 항목이 일부 겹침 | 낮 | 통합 또는 명확한 참조 관계 문서화 |
| C-Dual | enemy/ 스펙 vs mecha/ DESCRIPTION·FINAL — 의도적 이중 구조 | 없음 | 유지 (스펙 SoR vs 제작 SoR) |
| C-Weapon | weapon DESCRIPTION 얇음 vs 스토리/전투 무장 요구 | 갭 | 보강 필요 (충돌 아님) |

차단급 충돌 **없음**.

---

## 9. Novel ↔ Design Conflicts

`STORY_DESIGN_CONFLICTS.md` (STEP 2) 결과 재확인:

- **차단급 충돌: 0**
- 경미: BRAVE 키 표기 (18–25 vs 25m 고정), ORD GUN/HEAVY First EP 표기 차이
- 갭: 전투 루프·Damage·AI·삼면도·weapon 매핑·conti EP14–24

Novel 직접 수정 금지. 잠재적 충돌은 위 경미·갭만 기록. 현재 디자인 잠금은 스토리와 정합.

---

## 10. Proposed Directory Structure

**제안만. 실제 이동하지 않음.**

```text
design/
├── README.md                          # 입구 · 지도 · Canon Hierarchy 링크
├── canon/                             # 최종 정체성·원칙·TEXT-LOCK 스펙
│   ├── DESIGN_QUALITY.md
│   ├── SUPER_ROBOT_MODERN.md
│   ├── MECHA_3TONE_LOW_DETAIL.md
│   ├── SUPER_ROBOT_DESIGN_LANGUAGE.md # (승인 후)
│   ├── mecha_principles/              # ORDER_DESIGN_LANGUAGE 등
│   └── specs/                         # FRAME_SPEC, EXCELION_SPEC, enemy/*_SPEC 등
├── mecha/                             # 제작 단위 유지 (또는 canon/mecha + implementation/mecha 분리)
│   ├── (기존 DESCRIPTION / FINAL / threeview 유지)
│   └── ...
├── combat/                            # 구현 중심 (현재 유지 또는 implementation/combat)
├── character/
├── weapon/
├── env/
├── effect/
├── ui/
├── conti/
├── anime/
├── reference/                         # FSS_* · 컨셉 이미지 풀 링크
│   ├── fss/
│   └── concept_images/                # brave/ · nemesis/ PNG 등
├── review/                            # LOCK 후보 · 미확정 · 얇은 문서
├── archive/                           # 완료된 감사·판정 문서
└── (운영)
    ├── THREEVIEW_CURRENT.md
    ├── GAME_COMBAT_INDEX.md
    └── MECHA_STATUS.md
```

세부 폴더명은 감사 결과에 따라 조정 가능. 핵심은 **canon / implementation / reference / review / archive** 구분.

---

## 11. Proposed Canon Hierarchy

```
1. Novel + docs/ (스토리·세계관 최상위)
2. design/canon/ 정체성 원칙
   - SUPER_ROBOT_DESIGN_LANGUAGE (승인 시) 또는 SUPER_ROBOT_MODERN
   - DESIGN_QUALITY
   - MECHA_3TONE_LOW_DETAIL
3. 기체별 TEXT-LOCK 스펙
   - brave/FRAME_SPEC · EXCELION_SPEC
   - enemy/*_MECHA_SPEC · ORD_*
4. mecha/*/FINAL_SPEC · DESCRIPTION (제작 요약)
5. combat/ · gameplay/ (구현 레이어)
6. reference/ (FSS · 컨셉 이미지)
7. review/ · archive/
```

충돌 시 상위 우선. FSS는 절대 2~4를 덮어쓰지 않음.

---

## 12. Migration Order

1. Master 승인: SUPER_ROBOT_DESIGN_LANGUAGE LOCK 여부 + 계층 확정.
2. Canon 문서 목록 확정 및 README에 Hierarchy 명시.
3. reference/ 폴더 신설 후 FSS_* · 컨셉 이미지 링크/이동 제안.
4. review/ · archive/ 신설 후 해당 문서 이동 제안.
5. combat/ · gameplay/ 경계 정리.
6. 실제 파일 이동은 **별도 작업지시** 후 진행 (이번 단계 금지).

---

## 13. Risks

- 이중 구조(스펙 vs 제작)를 잘못 통합하면 SoR 혼란 발생.
- SUPER_ROBOT 문서 두 개를 임의 통합하면 BRAVE 중밀도 원칙 손실 가능.
- 삼면도 HOLD 상태가 길어지면 구현 병목.
- weapon·FINAL 보강 지연 시 전투 프로토타입 품질 저하.
- 파일 이동 시 상대 링크·기존 커밋 참조 깨질 위험 → 이동 시 일괄 검증 필요.

---

## 14. Items Requiring Master Approval

1. `mecha/SUPER_ROBOT_DESIGN_LANGUAGE.md` 를 CANON(LOCK)으로 승격할지 여부.
2. SUPER_ROBOT_MODERN vs SUPER_ROBOT_DESIGN_LANGUAGE 계층 관계 확정.
3. 제안 디렉터리 구조 (특히 canon/ · reference/ · archive/ 도입) 승인.
4. ORD를 BASE+4종 개별 FINAL로 분리할지 여부 (이전 OPEN QUESTION).
5. MECHA_BIBLE 키 문구(18–25 vs 25m) 정리 여부.
6. 이미지 HOLD 해제 시점.

---

## 15. Recommended Next Steps

1. Master가 본 계획의 Canon 후보·계층·구조 제안을 검토·승인.
2. 승인된 항목만 반영하여 **실제 디렉터리 재구성 작업지시** 작성 (2차).
3. SUPER_ROBOT 문서 계층 확정 후 README 및 관련 문서에 명시.
4. 구현 우선순위: combat/ Prototype 레이어 유지 · AEGIS 등 FINAL 보강 (이전 STEP 계획과 연계).
5. 삼면도 큐는 THREEVIEW_CURRENT 유지 · 이미지 HOLD는 Master 결정까지 존중.

---

## 최종 보고 (작업 완료 조건 충족)

1. **조사한 파일 수**: design/ 이하 전체 (텍스트 ~120+ · 이미지 다수 · 하위 디렉터리 전부 포함).
2. **CANON 후보**: DESIGN_QUALITY, SUPER_ROBOT_MODERN, MECHA_3TONE_LOW_DETAIL, FRAME_SPEC, EXCELION_SPEC, BRAVE_INFLUENCE, enemy/*_SPEC, ORDER_DESIGN_LANGUAGE, MECHA_MASTER_LIST, character OFFICIAL_SETTING 등.
3. **IMPLEMENTATION 후보**: combat/ 전체, GAME_COMBAT_INDEX, mecha DESCRIPTION/FINAL, MECHA_DATA_SCHEMA, threeview SKILL, weapon DESCRIPTION, gameplay, test 시나리오.
4. **REFERENCE**: FSS_* 3종, brave/·nemesis/ 컨셉 이미지.
5. **REVIEW**: SUPER_ROBOT_DESIGN_LANGUAGE (LOCK 후보), 일부 FINAL·weapon 얇은 문서.
6. **ARCHIVE 후보**: DESIGN_AUDIT, UNCONFIRMED_MECHA_REVIEW (완료 문서).
7. **주요 충돌**: SUPER_ROBOT 두 문서 계층 (중), 그 외 차단급 없음.
8. **Master 결정 필요**: SUPER_ROBOT_DESIGN_LANGUAGE 승격·계층, 디렉터리 구조 승인, ORD 분리 여부, 이미지 HOLD.
9. **제안하는 다음 작업**: Master 승인 → 2차 구조 이동 작업지시 작성. 이번 단계에서는 구조 변경 없음.

**기존 파일 변경 없음. 분석 결과만 본 문서로 기록.**
