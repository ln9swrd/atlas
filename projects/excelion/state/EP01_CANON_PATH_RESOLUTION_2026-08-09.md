# EP01 CANON PATH RESOLUTION — 2026-08-09

> 대상: **C-2026-08-09-EP01-PATH**

## ★ Master 결정 (LOCK)

| 항목 | 값 |
|------|-----|
| **결정** | **B** |
| **정본** | **P-B** `novel/EP01_세계가_끝났는데_나는_아직_여기_있다.md` |
| **P-A** | LEGACY / ALTERNATE · 보존 · 비정본 |
| **P-C** | ENHANCEMENT / OUTLINE |
| **본문 재작성** | 금지 (별도 승인 전) |
| **P-A→P-B 병합** | 금지 |
| **일자** | 2026-08-09 |

정합 수정: `NOVEL_CANON` · `EP01_ENHANCEMENT_SPEC` · `P0-1b` · 관련 audit 경로 표기.

---

## 0. 원 범위 (조사 단계)

| 허용 | 금지 |
|------|------|
| 3경로 관계·구조·캐논 일치 기록 | 정본 임의 확정 (조사 단계) |
| 판정 라벨 (후보/파생/레거시 등) | 본문 수정 · 캐논 본문 변경 |
| 차이점·충돌 요약 | 파일 삭제/이동 |
| Master 선택 후 후속 작업 후보만 명시 | 「한 뿌리」 수정/회수 창작 |
| | 이미지·Meshy·UE·M5·코드 |

참조 감사: `NOVEL_EP01_BRANCH_AND_ROOT_THREAD_AUDIT_2026-08-09.md` (A-02)

---

## 1. 공존 경로 개요

| ID | 경로 | 유형 | 분량(대략) | **LOCK 후 역할** |
|----|------|------|------------|------------------|
| **P-A** | `novel/EP01_마지막_기동/Scene01`~`Scene06` | 장면 분할 산문 본문 6파일 | ~34.8 KB 합 | **LEGACY / ALTERNATE** |
| **P-B** | `novel/EP01_세계가_끝났는데_나는_아직_여기_있다.md` | 단일 파일 산문 | ~5.3 KB | **정본** |
| **P-C** | `novel/EP01_REWRITE.md` | 아웃라인·목적·필수 장면 | ~3.8 KB | **ENHANCEMENT / OUTLINE** |
| — | `novel/ep01.md` | **없음** | — | — |

---

## 2–6. 조사 상세

(조사 시점 기록 유지. 예비 판정은 결정 전 상태.)

- P-A: 완성 산문 · H1「콜.」일치 · Enhancement DONE 이력 · Seth 조기 등장
- P-B: NOVEL_CANON 기존 표기 · H1「콜.」일치 · 클라이맥스 중심 · 풀 시퀀스 없음
- P-C: 아웃라인 · 본문 아님

조사 당시 CONFLICT: CANON=P-B vs ENHANCEMENT/P0-1b=P-A → **Master B로 해소.**

---

## 7. Master 선택지 (이력)

| 선택 | 결과 |
|------|------|
| A | 미채택 |
| **B** | **채택 · LOCK** |
| C | 미채택 |
| HOLD | 미채택 |

---

## 8. 선택 B 후 정합 대상 (본 PR 범위)

1. `novel/NOVEL_CANON.md` §1 EP01 행 · LEGACY/OUTLINE 명시
2. `novel/EP01_ENHANCEMENT_SPEC.md` 정본 경로 문구
3. `novel/audit/P0-1b_CANONICAL_CLASSIFICATION.md`
4. `novel/audit/NOVEL_CONTINUITY_AUDIT.md` · `P0-1c` · `P0-1d` 경로 표기

**미실행 유지**: P-B 본문 재작성 · P-A 병합 · 「한 뿌리」 · 이미지/코드.

---

## 9. 조사 파일 목록

- `novel/NOVEL_CANON.md`
- `novel/EP01_ENHANCEMENT_SPEC.md`
- `novel/EP01_마지막_기동/Scene01`~`06`
- `novel/EP01_세계가_끝났는데_나는_아직_여기_있다.md`
- `novel/EP01_REWRITE.md`
- `novel/audit/P0-1b_CANONICAL_CLASSIFICATION.md`
- `state/KAI_HABIT_FIXED.md`
- `state/NOVEL_EP01_BRANCH_AND_ROOT_THREAD_AUDIT_2026-08-09.md`

---

## 10. 종합

```
MASTER: B
정본: P-B EP01_세계가_끝났는데_나는_아직_여기_있다.md
P-A: LEGACY/ALTERNATE 보존
P-C: OUTLINE
C-2026-08-09-EP01-PATH: 문서 정합으로 해소 (본문 미수정)
한 뿌리: TBD 유지
LBN-01~04: CLOSED
```
