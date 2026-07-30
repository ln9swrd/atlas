# Original Conversations Duplicate Policy

Source: `obsidian/Archive/Original Conversations/ANALYSIS_REPORT.md` Phase 0
Effective: 2026-07-30

---

## Exact Duplicates (SHA identical)

| Keep (canonical) | Duplicate | Size |
|------------------|-----------|------|
| 55.md | 61.md | 9,544 |
| 56.md | 62.md | 2,774 |
| 57.md | 63.md | 10,593 |
| 59.md | 65.md | 4,374 |
| 60.md | 66.md | 5,461 |

**Policy**: 낮은 번호만 canonical로 유지. 높은 번호는:
1. 즉시 삭제하지 않음 (안전)
2. `Named Conversations`에서 `*_중복본.md`로 이미 표시된 상태 유지
3. 추후 정리 시 높은 번호 파일 삭제 + 이 문서에 기록

## Near-Duplicate

| Pair | Note |
|------|------|
| 58.md ≈ 64.md | 크기 15,890 vs 15,883 (끝부분 truncation 차이) |

**Policy**: 둘 다 유지. 관계는 본 문서에만 기록. 내용 병합은 하지 않음.

## Named Conversations 반영

`obsidian/Archive/Named Conversations/` 및 `archive/summary/`에 이미 중복본 식별명이 부여되어 있음.
추가 자동 삭제는 Owner 확인 후 별도 커밋으로 수행.

## Core 승격 후보 (중복 제외)

| Grade | Files |
|-------|-------|
| Core | 0, 1, 5, 50, 58, 80, 86 |
| 선별 Core | 20, 25 |
| 참고 | 10, 15, 70 |
| 중복 정리 대상 | 55=61, 56=62, 57=63, 59=65, 60=66, 64≈58 |
