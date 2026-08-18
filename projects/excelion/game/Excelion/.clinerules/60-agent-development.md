# Excelion Agent Development Rules

## 1. Git 기준선 우선

작업 시작 전에 반드시 확인:

- HEAD
- Branch
- Working Tree
- 대상 파일의 Git 상태
- 관련 설계/검증 문서

Git 기준선과 현재 작업지시를 대조한 후 작업한다.

## 2. 작업 범위 잠금

판단 순서:

작업지시
→ Git 기준선
→ 현재 코드
→ 최소 수정안

작업지시에 없는 기능/문제를 발견해도 임의로 수정하지 않는다.
별도 OUT OF SCOPE로 보고한다.

## 3. Master 승인 우선

Master의 명시적 승인 없이 다음을 변경하지 않는다:

- 설계
- Canon
- Blueprint
- Asset
- Config
- 프로젝트 구조
- 대규모 리팩터링

## 4. 최소 수정

가능하면 최소 파일/최소 함수/최소 코드만 수정한다.
현재 문제와 직접 관계없는 개선은 별도 작업으로 분리한다.

## 5. Working Tree 보호

기존 변경사항을 보존한다.

다음 행위를 임의로 수행하지 않는다:

- revert
- reset
- stash
- 기존 변경 덮어쓰기
- unrelated 변경 수정

## 6. 검증 상태

다음 상태를 명확히 구분한다:

- CODE VERIFIED
- BUILD VERIFIED
- EDITOR VERIFIED
- PIE VERIFIED
- NOT VERIFIED

Build 성공을 PIE VERIFIED로 표시하지 않는다.
코드 존재만으로 기능 VERIFIED 처리하지 않는다.

## 7. Unreal Editor 접근 제한

Unreal Editor를 사용할 수 없는 경우:

- Blueprint 상태를 추정하지 않는다.
- Asset 상태를 추정하지 않는다.
- PIE 결과를 추정하지 않는다.
- 실제 Runtime 결과를 VERIFIED 처리하지 않는다.

## 8. Agent 역할 분리

개발 Agent:

- 조사
- 최소 코드 수정
- Build
- Diff 확인
- Commit 금지
- Push 금지

Git Agent:

- Git status
- Diff
- Commit
- Push
- Git 기록 관리

Git Agent는 코드나 Unreal 시스템을 임의로 수정하지 않는다.

## 9. 종료

작업지시의 질문에 답하면 작업을 종료한다.
추가 문제를 발견해도 자동으로 다음 작업을 시작하지 않는다.

## 10. 보고

최종 보고에는 최소한 다음을 포함한다:

- STATUS
- BASELINE
- 조사 결과
- 변경 사항
- DIFF
- BUILD
- EDITOR
- PIE
- 미확인 사항
- OUT OF SCOPE
- Git 상태

작업 범위 밖의 수정은 수행하지 않는다.
