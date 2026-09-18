# SOT_MAP — Excelion Source of Truth

> 2026-08-13 · AI 작업 경계용 지도 · 정본 이동/개명 없음

**목적:** 에이전트가 “어디를 믿고, 어디를 손대도 되는지” 5분 안에 판단.

**LOCK 의미:** 절대 수정 불가 ≠ LOCK.  
LOCK = **명시적 작업지시·Master 승인 없이 AI가 임의 수정하지 않는다.**

---

## 0. 작업 시작 순서 (필수)

1. `projects/excelion/state/CURRENT_STATE.md`
2. **이 파일 (SOT_MAP)**
3. 대상 파일의 권한 확인
4. 작업 범위·변경 대상 확인
5. 변경 수행 (권한 허용 시만)

플랫폼 라우팅만 볼 때: `state/CURRENT_STATE.md` (Atlas 루트).

---

## 1. 영역별 지도

| 영역 | SOURCE OF TRUTH | 권한 | 참조 (읽기) | 이력/과거 |
|------|-----------------|------|-------------|-----------|
| **프로젝트 상태** | `state/CURRENT_STATE.md` · `state/TASK_MAP.md` | EDITABLE (상태 갱신) | `CONTEXT_INDEX.md` | `state/*_2026-08-*.md` (감사 이력) |
| **세계관 / 캐논** | `novel/NOVEL_CANON.md` | **LOCK** | `docs/09_STORY_S1.md` · `EPISODE_MATRIX.md` | audit/ |
| **Novel 본문** | `novel/ep02.md`…`ep24.md` · EP01=`novel/EP01_세계가_끝났는데_나는_아직_여기_있다.md` | **LOCK** | EP*_REWRITE · SYNOPSIS | `EP01_마지막_기동/` LEGACY |
| **Episode 구조** | `novel/EPISODE_MATRIX.md` | **LOCK** | `EP14_24_PLOT.md` | audit/ |
| **Character** | `design/character/*/OFFICIAL_SETTING.md` · `novel/CHARACTER_BIBLE.md` | **LOCK** (설정) | DESCRIPTION · threeview NOTES | — |
| **Mecha** | `design/mecha/*/*_FINAL_SPEC.md` · `design/mecha/MECHA_MASTER_LIST.md` | **LOCK** | DESCRIPTION · enemy/*_MECHA_SPEC | — |
| **Enemy / ORD** | `design/enemy/ORD_*` · 관련 FINAL_SPEC | **LOCK** | state/ORD_GRUNT_* (결정·감사) | — |
| **Weapon** | `design/weapon/*/DESCRIPTION.md` | 제한적 EDITABLE (지시 시) | threeview | — |
| **Game Design** | `design/gameplay/` · `design/combat/` · `docs/COMBAT_SYSTEM.md` | 제한적 EDITABLE | state/BALANCE_* · PLAY_* | PHASE*_STATUS |
| **Unreal 구현** | `game/Excelion/` (uproject · Source · Config) | **LOCK** | `docs/UNREAL_*` | — |
| **Prototype** | `prototype/` | 제한적 EDITABLE (지시 시) | prototype README | 구 playable_v* |
| **Pipeline 문서** | `state/MESHY_BLENDER_PIPELINE_SPEC.md` | 제한적 EDITABLE | PROJECT_MEMORY | forge DEPRECATION |
| **Audit / History** | (정본 아님) | **LOCK** (이력 보존) | — | `state/*AUDIT*` · `docs/maintenance/` |
| **Backlog** | `backlog.json` · `state/TASK_MAP.md` | EDITABLE (상태 동기) | sprints/ | — |
| **진입·원칙** | `README.md` · `PROJECT_CHARTER.md` · `PROJECT_MEMORY.md` | 제한적 EDITABLE | docs/ | — |

---

## 2. 권한 정의

| 권한 | 의미 |
|------|------|
| **LOCK** | 명시적 작업지시 + 범위 지정 없이 수정 금지 |
| **EDITABLE** | CURRENT_STATE / 작업지시 범위 안에서 상태·운영 문서 갱신 가능 |
| **제한적 EDITABLE** | 지시서에 파일·범위가 명시된 경우만 |

---

## 3. 명시적 지시 없이 수정 금지 (요약)

- `novel/NOVEL_CANON.md` 및 Novel 본문
- `*_FINAL_SPEC.md` · OFFICIAL_SETTING
- `game/Excelion/**` (Unreal)
- `archive/**` · 과거 audit 본문
- SOT_MAP에서 LOCK으로 표시된 모든 경로

---

## 4. 플랫폼 vs 프로젝트 state

| 파일 | 역할 |
|------|------|
| `state/CURRENT_STATE.md` (Atlas 루트) | 플랫폼 상태 · **어느 프로젝트가 SoR인지** 라우팅 |
| `projects/excelion/state/CURRENT_STATE.md` | **Excelion 실제 작업 상태** · Done / Next / HOLD |

동일 작업 상태를 양쪽에 중복 기록하지 않는다.  
제품 상세는 excelion state만 갱신한다.

---

## 5. HANDOFF (작업 종료 시 최소 기록)

`projects/excelion/state/CURRENT_STATE.md`에 다음을 남긴다 (또는 Notes에 한 블록):

- 작업명
- 현재 상태
- 완료 / 미완료
- 변경 파일 목록
- 마지막 관련 commit (가능 시)
- 다음 작업
- 재개 조건

다음 에이전트: **CURRENT_STATE → SOT_MAP → 최근 commit → 작업 범위** 순으로 확인.

---

## 6. 비고

- 이 맵은 정본을 **가리키기만** 한다. 정본 파일을 대체하지 않는다.
- 충돌 시: NOVEL_CANON 및 이 맵의 LOCK 경로가 우선.
