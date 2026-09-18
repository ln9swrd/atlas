# Orphan Gitlink Cleanup — 2026-08-11

기준: `docs/maintenance/UNEXPECTED_MAIN_COMMIT_REVIEW_2026-08-11.md`  
기준 SHA: `c0dc87f3df127fefc8ea55b1017fe06c9520604e`  
도입 커밋: `82d5ee2f605bd0a10bfc14e80bcb5efc5401f5ec`

## 삭제

| 경로 | 유형 | 근거 |
|------|------|------|
| `debloat.ps1` | 파일 | Windows bloat 제거 · Atlas 무관 · 참조 0 |
| `projects/wafermap-converter` | 고아 gitlink `631c1691…` | `.gitmodules` 없음 · 맵 미등재 · 참조 0 |

외부 `ln9swrd/wafermap-converter` 레포: **변경 없음**.

## Gitlink 검증

| 항목 | 결과 |
|------|------|
| gitlink count | **0** (목표) |
| `.gitmodules` | 없음 (변경 없음) |
| wafermap / debloat 운영 참조 | 0 |

## 보호 영역

excelion / `_template` / vision / P2 / P3: **변경 0**

## P4/P1 유지

root `atlas-runtime` 없음 · `core/review/print_settings.yaml` 없음 · archive pointer 유지

## user@example.com 조사

| 항목 | 결과 |
|------|------|
| Author/Committer (82d5ee2) | `user <user@example.com>` |
| 정상 Atlas 푸시 identity | `ln9swrd <129256046+ln9swrd@users.noreply.github.com>` |
| 이력 내 `user@example.com` | **56회** (과거부터 존재 · 이번만의 신규 아님) |
| 메시지 성격 | `initialize git repository and update converter logic` — wafermap 로컬 작업 흔적 |
| 자동화 여부 | GH API rate limit으로 verification/actor 상세 미확인 |
| 추정 | 로컬 git `user.name/email` 미설정(placeholder) 환경에서 **직접 push** |

### 재발 방지 권고

1. 로컬: `git config user.email`을 GitHub noreply로 고정  
2. `main` 직접 push 제한 (PR only) 검토  
3. pre-receive/branch protection: placeholder email 거부 (가능 시)  
4. 고아 gitlink: `.gitmodules` 없는 `160000` 진입 시 CI 경고

**history rewrite / force push: 하지 않음** (82d5ee2 커밋은 이력에 잔존, 트리만 정리).

## 다음

P2 R5 · P3 Alpha/Beta 정책 대기 유지.
