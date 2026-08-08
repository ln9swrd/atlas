# P0-1b 정본 확인

> 2026-08-08

## 분류 기준

- **정본 (SoR)**: 현재 스토리의 기준이 되는 본문/설정. 이후 작업의 출발점.
- **초안/Rewrite**: 구조·의도 문서. 본문 아님.
- **설정**: 캐릭터·세계관·전투 규칙. 메인 SoR(`docs/`)와 충돌 시 docs 우선.
- **분석/플롯**: 구조 분석, 시놉시스, 비트 상세. 본문 보조.
- **AI 엔진**: 집필/검증 규칙. 작품 본문과 분리.
- **감사/체크포인트**: 보완 작업용.
- **중복/구버전**: 이름·내용이 겹치거나 대체된 것.

---

## 1. EP 본문 — 정본 후보

| 파일 | 판정 | 비고 |
|------|------|------|
| `EP01_마지막_기동/Scene01~06` | **정본 (EP01)** | 가장 완성도 높은 산문 본문. 씬 단위. |
| `ep02.md` ~ `ep24.md` | **정본** | CURRENT_STATE 기준 EP1–24 본문 Done. 밀도 차이 있음. |
| `EP01_REWRITE.md` | 초안/구조 | 아웃라인·목적·필수 장면 체크. 본문 아님. |
| `EP01_세계가_끝났는데_나는_아직_여기_있다.md` | 구버전/중복 | Scene 폴더와 겹침. 정본으로 쓰지 않음. |

**주의**: 단일 `ep01.md` 없음. EP01은 `EP01_마지막_기동/`이 현재 정본.

---

## 2. 설정 문서

| 파일 | 판정 | 비고 |
|------|------|------|
| `CHARACTER_BIBLE.md` | **설정 정본 (novel 측)** | 이름 통일: 카이 (구 카일). 메인 SoR는 `docs/01_CHARACTER`. |
| `MECHA_BIBLE.md` | 설정 |
| `COMBAT_SYSTEM_BIBLE.md` | 설정 |
| `NEMESIS_DEEP_ANALYSIS.md` | 설정/분석 |
| `FACTION_ANALYSIS.md` | 설정/분석 |
| `ELITE_BT_COMPARE.md` | 설정 |
| `ORD_REMNANT_AI_BT.md` | 설정 |
| `ORD_REMNANT_TACTICS.md` | 설정 |
| `TIMELINE_ANALYSIS.md` | 설정/분석 |
| `NARRATIVE_STRUCTURE_BASICS.md` | 설정/가이드 |

---

## 3. 구조·플롯·시놉시스 (분석)

| 파일 | 판정 |
|------|------|
| `EP14_24_PLOT.md` | 분석 |
| `EP14_24_STRUCTURE_ANALYSIS.md` | 분석 |
| `EP14_24_SYNOPSIS.md` | 분석 |
| `EP17_*` (BODY, COMBAT, PART3, SYNOPSIS_DRAFT) | 분석/초안 |
| `EP19_SYNOPSIS.md` | 분석 |
| `EP21_SYNOPSIS.md` | 분석 |
| `EP22_*` | 분석 |
| `EP23_RHYTHM_ANALYSIS.md` | 분석 |
| `EP24_STRUCTURE_ANALYSIS.md` | 분석 |
| `EP_CLIMAX_DESIGN.md` | 분석 |
| `STORY_REVIEW_2026-08-07.md` | 리뷰 |
| `REBUILD_ANALYSIS_PLAN.md` | 계획 |

---

## 4. AI 엔진 (작품과 분리)

| 파일 | 판정 |
|------|------|
| `CLIMAX_IMPL_LOGIC.md` | AI 엔진 (C1~C6) |
| `CLIMAX_TYPE_SPEC.md` | AI 엔진 |

→ 이후 `engine/`으로 이동 권장.

---

## 5. audit (신규)

| 파일 | 판정 |
|------|------|
| `audit/NOVEL_REWORK_CHECKPOINT.md` | 체크포인트 |
| `audit/P0-1a_FILE_LIST.md` | 감사 |
| `audit/P0-1b_CANONICAL_CLASSIFICATION.md` | 감사 (본 문서) |

---

## 6. 이미 발견된 충돌 / 이슈

| ID | 내용 | 심각도 | 조치 |
|----|------|--------|------|
| C-01 | 이름: CHARACTER_BIBLE = **카이**, EP01 Scene01 = **카일** | 중 | P0-2에서 전수 수정. 카이로 통일. |
| C-02 | EP01 본문이 3종 공존 (REWRITE / 세계가... / 마지막_기동) | 중 | 마지막_기동을 정본으로 확정. 나머지는 보존하되 참조 우선순위 낮춤. |
| C-03 | ep01.md 부재 | 낮 | 필요 시 `ep01.md`로 통합 또는 심볼릭 링크 검토 (나중에). |
| C-04 | 메인 SoR는 `docs/` · novel 설정은 보조 | 정보 | CHARACTER_BIBLE에 명시됨. 충돌 시 docs 우선. |

---

## 7. 정본 요약 (작업 기준)

**이야기 본문**
- EP01: `EP01_마지막_기동/Scene01~06`
- EP02~24: `ep02.md` ~ `ep24.md`

**캐릭터/세계관 (novel 내부)**
- `CHARACTER_BIBLE.md` (단, docs 우선)

**AI 집필 규칙**
- `CLIMAX_*` → 추후 engine/ 이동

**보완 작업 추적**
- `audit/`

---

**P0-1b 완료.**
다음: P0-1c 캐릭터 설정 비교 또는 P0-2 설정 충돌 감사로 진행 가능.
