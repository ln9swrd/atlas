# State Discipline (R7)

Goal: multi-file state desync 방지.

## Single Source of Truth

| 질문 | 읽는 파일 |
|------|-----------|
| 지금 타겟이 뭔가? | **`state/CURRENT_STATE.md`** 만 |
| 열린 작업이 뭔가? | **`state/TASK_MAP.md`** 만 |
| 결정이 뭔가? | **`docs/DECISIONS.md`** 만 |
| 세션 루프 | `docs/06_OPERATIONS/DAILY_LOOP.md` |

다른 파일(`PROJECT_MAP`, `CONTEXT_INDEX`, Review, 제품 state)은 **파생/인덱스**. 충돌 시 위 SoR가 이김.

## Write rules

1. 상태 변경 시 **먼저** `CURRENT_STATE.md` 또는 `TASK_MAP.md` 갱신.
2. 같은 커밋(또는 즉시 다음 커밋)에서 파생 파일 동기화.
3. 채팅/이슈만으로 “Done” 선언 금지 → 파일 + commit message.
4. 제품 hold 중 `projects/*/state` 수정 금지 (ACTIVE_TARGET = platform).

## Minimal set (Always load)

`CONTEXT_INDEX.md` Always 표 준수. 그 외 대규모 탐색 금지.

## Checklist (세션 끝)

- [ ] CURRENT_STATE Next / Do not 최신
- [ ] TASK_MAP Open 행 = 실제 남은 일
- [ ] 새 Decision이면 DECISIONS.md 행 추가
