# Excelion Cleanup Candidate Review

**조사일:** 2026-08-11
**시작 SHA:** `8cd3c11a7c36a74a2d518ff3b094ac7a03cb43a2`
**대상:** `projects/excelion/` only
**목적:** 불필요·중복·고아·legacy 후보 식별 (삭제·이동·수정 없음)

---

## 1. Scope

- 저장소: `ln9swrd/atlas`
- 범위: `projects/excelion/`
- 금지: `git rm` / `git mv` / 원본 수정 / Excelion 외부 변경
- 허용: 본 조사 문서 1건만

---

## 2. Structure

| 경로 | 역할 (문서 기준) | 비고 |
|------|------------------|------|
| `docs/` | 설계 SoR | 00–09 + 구현·UE 준비 문서 |
| `state/` | 운영 SoR | CURRENT_STATE · TASK_MAP · 감사/밸런스 로그 |
| `design/` | 비주얼·에셋 스펙·제작 단위 | mecha/character/env/weapon 등 |
| `novel/` | 스토리 본문·바이블 | EP·설정 |
| `game/` | Unreal 프로젝트 스켈레톤 | `Excelion.uproject` + Config/Source |
| `assets/` | 에셋 placeholder | .gitkeep 중심 |
| `prototype/` | HTML 플레이어블 | v1–v4 |
| `sprints/` · `backlog.json` | 실행 기록 | Sprint-001 역사 |
| 루트 md | CHARTER · MEMORY · README · ENVIRONMENT_PLAN | |
| `planning/` | **없음** | 계획 문서는 `state/`·루트·`docs/`에 분산 |

파일 약 480 · Markdown 약 386 · 디렉터리 약 109.

---

## 3. SoR

| 영역 | Source of Record | 파생 / 비고 |
|------|------------------|---------------|
| 프로젝트 루트 SoR | `projects/excelion/` | 단독 `ln9swrd/excelion` CLOSED |
| 설계 (문서) | `docs/` | DOC_MAP · README |
| 운영 상태 | `state/` (`CURRENT_STATE` · `TASK_MAP`) | |
| 스토리 본문 | `novel/` | |
| 아트·제작 단위 | `design/` | DESCRIPTION · threeview · OFFICIAL_SETTING |
| 파이프라인 계약 | `state/MESHY_BLENDER_PIPELINE_SPEC.md` | forge = DEPRECATION CANDIDATE |
| 전투 구현 스펙 | `docs/COMBAT_SYSTEM.md` | design/gameplay = UE 준비 파생 |
| 전투 루프 상세 | `design/combat/*` | PATTERN · LOOP · FEEDBACK 등 |
| 스토리 전투 표현 | `novel/COMBAT_SYSTEM_BIBLE.md` | 표현 vs 시스템 (충돌 없음 문서화됨) |
| 게임 구현 | `game/Excelion/` | HOLD 상태 스켈레톤 |

외부: `excelion-forge` DEPRECATION · `paramodel` HOLD.

---

## 4. Empty / Placeholder

| Path | Type | Usage | Verdict |
|------|------|-------|---------|
| `design/**/threeview/.gitkeep` (다수) | marker | 디렉터리 추적 | **KEEP** |
| `design/env/**/props/.gitkeep` | marker | 동일 | **KEEP** |
| `assets/**/.gitkeep` | marker | placeholder 구조 | **KEEP** |
| `game/Excelion/Config/DefaultEditor.ini` | 0-byte | UE Config 관례 | **KEEP** (엔진 영향 미확인 시 보호) |
| `DefaultEngine.ini` / `DefaultGame.ini` / `DefaultInput.ini` | 비어 있지 않음 | UE Config | **KEEP** |

빈 파일이 곧 삭제 대상이 되는 경우 없음 (marker · Unreal 경계).

---

## 5. Duplicate

| Path A | Path B | Relationship | Verdict |
|--------|--------|--------------|---------|
| `docs/COMBAT_SYSTEM.md` | `design/gameplay/COMBAT_SYSTEM.md` | 구현 스펙 → UE 준비 파생 (원천 명시) | **KEEP** (계층) |
| `docs/PHASE12_TUNING.md` | `state/PHASE12_TUNING.md` | 짧은 반영 노트 vs ops play-feel 본문; TASK_MAP은 PHASE12_TUNING 참조 | **INVESTIGATE** (통합 여부 · 삭제 아님) |
| `docs/02_COMBAT.md` | `docs/COMBAT_SYSTEM.md` / `design/combat/*` | 설계 개요 vs 구현 vs 상세 | **KEEP** |
| `novel/COMBAT_SYSTEM_BIBLE.md` | 위 전투 문서군 | 서사 표현 | **KEEP** |
| `DESCRIPTION.md` ×N | design 단위별 | 제작 단위 표준 | **KEEP** |
| `OFFICIAL_SETTING.md` ×6 | character/mecha | 단위 설정 | **KEEP** |

주제 유사 ≠ 중복 삭제 대상. 역할이 다른 문서는 KEEP.

---

## 6. Orphan

광범위 파일명 미참조만으로 orphan 확정하지 않음.

- `docs/PHASE*_STATUS.md`: 단계 이력 · 사람이 읽는 ops/설계 로그 → **KEEP**
- `state/CLEANUP_*` · `state/FORGE_*`: 감사·범위 기록 → **KEEP**
- `sprints/Sprint-001*`: 완료 역사 → **KEEP**
- design 단위 DESCRIPTION / .gitkeep: 구조상 필요 → **KEEP**

**REMOVE급 orphan: 0**

---

## 7. Broken Links

`projects/excelion` 내부 Markdown `](...)` 링크 스캔 (http/mailto/# 제외).

- 상대 경로 대상 존재 여부 검사
- **BROKEN: 0**

(백틱 경로 언급은 링크로 계산하지 않음. README Start-here 핵심 경로는 전부 존재.)

---

## 8. Final Candidates

### REMOVE CANDIDATE
- **0**

(SoR 가능성 · Unreal · 참조 불명확 · 역사 가치 중 하나라도 있으면 REMOVE 미확정 정책 준수)

### ARCHIVE CANDIDATE
- **0** (Excelion 트리 밖으로 옮길 필요 없음 · 내부 역사 문서는 state/sprints에 유지)

### KEEP (주요)
- `docs/` 설계 SoR · `state/` 운영 SoR
- `design/` 제작 단위 · `.gitkeep`
- `novel/` 스토리
- `game/Excelion/` 전체 (Config 포함)
- `assets/` placeholder 구조
- 전투 문서 계층 (docs / design/combat / design/gameplay / novel bible)

### INVESTIGATE
| Path | Note |
|------|------|
| `docs/PHASE12_TUNING.md` vs `state/PHASE12_TUNING.md` | **SoR 비교 완료 (2026-08-11 후속)** — 아래 §11. KEEP_BOTH. 통합·삭제는 승인 전 금지 |

---

## 9. Protected Areas

이번 조사에서 변경하지 않음:

- `projects/excelion/` 전체 (특히 `game/` · `design/` · `novel/` · `state/`)
- `projects/_template/`
- `docs/` · `state/` (Atlas 루트) · `archive/` · `core/` · atlas-runtime

`planning/` 디렉터리는 현재 트리에 없음.

---

## 10. Conclusion

**현재 Excelion에 즉시 cleanup(삭제·이동)이 필요한 항목은 없다.**

구조는 DOC_MAP/README가 정의한 SoR 계층과 일치한다.
빈 파일은 marker/Unreal 관례다.
PHASE12_TUNING 이중 파일은 §11에서 **KEEP_BOTH** 로 판정 (역할 분리·파생 관계).
깨진 링크 0 · REMOVE 0.

통합이 필요하면 **별도 승인 후** state를 본문 SoR로 두고 docs 요약/포인터화 + 수치 정합을 검토한다.
원본 PHASE12 파일은 본 문서 갱신 시에도 변경하지 않았다.

---

## 11. PHASE12_TUNING SoR 비교 (2026-08-11 후속)

**대상**
- `projects/excelion/docs/PHASE12_TUNING.md` (35 lines)
- `projects/excelion/state/PHASE12_TUNING.md` (156 lines)

**금지 준수:** 두 원본 삭제·이동·통합·이름변경·내용수정 없음.

### 11.1 내용 비교

| 항목 | docs | state |
|------|------|-------|
| 성격 | Phase 12.1 **튜닝 반영 체크리스트** | Play Feel **설계 본문** (원칙·의도·Next) |
| 원칙 섹션 | 없음 | 있음 (감각 1개 / PERFECT 폭발 / MISS 납득) |
| HIT 창 | PERFECT slow **0.15** · GOOD **0.10** | `PERFECT=0.15` · `GOOD=0.10` (judgeHit) |
| MISS | LATE+34 / EARLY-28 · 붉은 파형 · 링 | ±ms 라벨 · 파형 · 링 · telegraph 재출현 |
| Telegraph | timeToImpact<0.1 → scale 1.2 · brightness 1.5 | 동일 + pulseSpeed |
| Combo | 20 / 30 / 50 단계 | 동일 + 10배수 악센트 사운드 |
| Adaptive | 샘플 **5**회 전 무변화 · telegraphScale lerp×0.12 | samples **≥3** · difficulty lerp 0.05 |
| Session | retries≥3 && avgRun<60s → applyEase | 동일 + fail 후 spawn 템포↑ |
| Next 체크리스트 | 없음 | main.js 반영 · 플레이테스트 |
| main 연결 예 | `fb.onPerfect` 등 있음 | 섹션별 스케치 코드 |

- **동일/공통:** Phase 12.1 play-feel 주제, PERFECT/GOOD 창 0.15/0.10, MISS 시각 언어, Combo 20/30/50, Session ease 조건.
- **한쪽에만:** state = 원칙·PERFECT 연출 3요소·Next; docs = 짧은 main 연결 예·telegraphScale lerp 수치.
- **소프트 드리프트:** Adaptive 샘플 임계 5 vs 3 등 — 같은 필드의 완전 모순이라기보다 표현·초안 차이. **하드 CONFLICT로 보지 않음.**
- **관계:** state가 설계 본문, docs가 반영 체크리스트에 가까움 → **원본(state) + 파생/병행 요약(docs)** 성격. 수치 드리프트로 순수 복사 파생은 아님.

### 11.2 참조

`git grep PHASE12_TUNING` (전체):

| 위치 | 내용 |
|------|------|
| `state/TASK_MAP.md` | Done · 텍스트 `PHASE12_TUNING.md` (**경로 미지정**) |
| `state/CURRENT_STATE.md` | Done 목록 |
| `state/PRODUCT_PRIORITY_REVIEW_2026-08-09.md` | DONE 목록 |
| `docs/maintenance/EXCELION_CLEANUP_REVIEW_2026-08-11.md` | 본 조사 |
| `state/PHASE12_TUNING.md` | 자체 제목 |

- `docs/PHASE12_TUNING.md` **전체 경로 참조:** maintenance 문서 외 **0**
- `state/PHASE12_TUNING.md` **전체 경로 참조:** maintenance 문서 외 **0**
- scripts / CI / design / novel / game: **참조 없음**
- ops 완료 기록은 **state/** 쪽 TASK_MAP·CURRENT_STATE가 담당

### 11.3 Git 이력

| 파일 | 커밋 | 시각 | 메시지 |
|------|------|------|--------|
| docs | `7492b02` | 2026-08-09 13:39 +0900 | docs: Phase12.1 tuning checklist |
| state | `fcd06b2` | 2026-08-09 13:44 +0900 | docs(excelion): add PHASE12_TUNING.md — play-feel… |

- 각 1커밋 · 이후 수정 없음.
- docs가 약 5분 먼저 생성, state가 직후 본문 추가로 해석 가능.
- “최신 커밋 = SoR” 규칙 적용하지 않음. 역할·참조·운영 구조로 판정.

### 11.4 SoR 판정

**docs/PHASE12_TUNING.md**
- Role: 설계 트리 내 **튜닝 반영 체크리스트 / 스냅샷**
- SoR: **아니오** (play-feel 본문 SoR 아님)
- References: 경로 직접 참조 0 (ops는 bare 이름)
- Last meaningful update: `7492b02` (2026-08-09)

**state/PHASE12_TUNING.md**
- Role: **Play-feel 설계·운영 기록 본문** (원칙·상세·Next)
- SoR: **예 — PHASE12 play-feel 튜닝 본문 후보** (TASK_MAP Done과 정합)
- References: TASK_MAP / CURRENT_STATE / PRODUCT_PRIORITY (이름 수준)
- Last meaningful update: `fcd06b2` (2026-08-09)

### 11.5 Relationship & Recommendation

| 항목 | 값 |
|------|-----|
| Relationship | **SOURCE_DERIVED** (state 본문 · docs 체크리스트; 소프트 수치 드리프트 존재) |
| Recommendation | **KEEP_BOTH** |
| MERGE | 승인 후에만. 시 state를 본문 SoR로 두고 docs는 요약/포인터 + Adaptive 등 수치 정합 |
| REMOVE | 금지 (현 단계) |

### 11.6 후속

- 필수 cleanup: **없음**
- 선택(승인 후): TASK_MAP 경로를 `state/PHASE12_TUNING.md`로 명시 · docs↔state 수치 정합 · docs 포인터화
