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
| `docs/PHASE12_TUNING.md` vs `state/PHASE12_TUNING.md` | 이중화 여부 · 통합 시 SoR를 state로 둘지 문서 정책 확인 필요. **승인 전 변경 금지** |

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
이름 중복은 계층 분담이거나 INVESTIGATE 1건(PHASE12)뿐이다.  
깨진 링크 0 · REMOVE 0.

정리 작업이 필요해지면 **별도 승인 후** INVESTIGATE(PHASE12 통합)만 다루는 것이 적절하다.  
이번 단계는 조사·문서화만 수행했다.
