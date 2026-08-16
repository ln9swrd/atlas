<<<<<<< HEAD
# Excelion Debug Workflow

사용자가 문제를 보고하면 다음 절차를 반드시 따른다.

**핵심 규칙: 각 PHASE는 독립적인 작업 단위이다.**

Agent가 한 번의 사용자 지시만으로 PHASE 1~11 전체를 자동 실행하지 않는다.

각 PHASE 실행 후:
→ 결과 보고
→ 중단
=======
Excelion Debug Workflow
사용자가 문제를 보고하면 다음 절차를 반드시 따른다.

핵심 규칙: 각 PHASE는 독립적인 작업 단위이다.

Agent가 한 번의 사용자 지시만으로 PHASE 1~11 전체를 자동 실행하지 않는다.

각 PHASE 실행 후: → 결과 보고 → 중단
>>>>>>> 6032771c (08156)

다음 단계는 새로운 지시를 받은 후에만 시작한다.

특히 다음 단계는 반드시 분리한다.
<<<<<<< HEAD
- 조사
- 원인 분석
- 수정 계획
- 수정
- 검증

예외: 긴 작업을 자동으로 실행해야 하는 명시적인 Master 지시가 있는 경우에만 연속 실행을 허용한다.
기본 동작은 "한 단계 실행 → 결과 보고 → 대기"이다.


## PHASE 1 — REPRODUCE

사용자가 보고한 현상을 정확히 정의한다.

예:
"W/A/S/D가 시계방향 회전으로 동작한다."
=======

조사
원인 분석
수정 계획
수정
검증
예외: 긴 작업을 자동으로 실행해야 하는 명시적인 Master 지시가 있는 경우에만 연속 실행을 허용한다. 기본 동작은 "한 단계 실행 → 결과 보고 → 대기"이다.

PHASE 1 — REPRODUCE
사용자가 보고한 현상을 정확히 정의한다.

예: "W/A/S/D가 시계방향 회전으로 동작한다."
>>>>>>> 6032771c (08156)

추상화하지 않는다.

실제 사용자 행동과 실제 결과를 그대로 기록한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 2 — BASELINE

현재 프로젝트 상태를 조사한다.

- Git 상태
- 변경 파일
- Unreal 버전
- 관련 Blueprint
- 관련 Config
- 관련 C++
- 관련 Log

=======
PHASE 2 — BASELINE
현재 프로젝트 상태를 조사한다.

Git 상태
변경 파일
Unreal 버전
관련 Blueprint
관련 Config
관련 C++
관련 Log
>>>>>>> 6032771c (08156)
기존 PASS 결과가 있으면 함께 조사한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 3 — REPRODUCTION

=======
PHASE 3 — REPRODUCTION
>>>>>>> 6032771c (08156)
가능하면 동일한 환경에서 실제로 문제를 재현한다.

재현하지 못하면:

"재현 실패"

라고 보고한다.

재현하지 못한 상태에서 원인을 확정하지 않는다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 4 — HYPOTHESIS

=======
PHASE 4 — HYPOTHESIS
>>>>>>> 6032771c (08156)
원인 후보를 최대 3~5개로 제한한다.

각 후보에 대해:

<<<<<<< HEAD
- 근거
- 반대 증거
- 확인 방법

=======
근거
반대 증거
확인 방법
>>>>>>> 6032771c (08156)
을 작성한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 5 — ISOLATION

=======
PHASE 5 — ISOLATION
>>>>>>> 6032771c (08156)
한 번에 하나의 가설을 검증한다.

검증을 위해 필요한 최소한의 변경만 허용한다.

가능하면 변경 없이 관찰한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 6 — ROOT CAUSE

=======
PHASE 6 — ROOT CAUSE
>>>>>>> 6032771c (08156)
다음 조건을 만족할 때 원인을 확정한다.

"이 원인을 제거하면 관찰된 문제가 설명된다."

단순히 가능성이 높다는 이유로 Root Cause라고 부르지 않는다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 7 — FIX PLAN

=======
PHASE 7 — FIX PLAN
>>>>>>> 6032771c (08156)
최소 변경안을 작성한다.

변경 전:

현재 상태

변경:

정확한 파일 / Asset / Blueprint / 설정

변경 후:

예상 상태

→ 결과 보고 후 중단 (Master 승인 대기)

<<<<<<< HEAD

## PHASE 8 — APPLY

=======
PHASE 8 — APPLY
>>>>>>> 6032771c (08156)
승인된 범위만 수정한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 9 — VERIFY

=======
PHASE 9 — VERIFY
>>>>>>> 6032771c (08156)
반드시 실제 실행한다.

그리고 사용자의 원래 증상을 다시 테스트한다.

예:

<<<<<<< HEAD
W → 전진
A → 좌측
S → 후진
D → 우측
=======
W → 전진 A → 좌측 S → 후진 D → 우측
>>>>>>> 6032771c (08156)

이 네 가지가 모두 실제로 맞아야 Input Fix PASS.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 10 — REGRESSION

=======
PHASE 10 — REGRESSION
>>>>>>> 6032771c (08156)
기존에 정상이어야 하는 기능이 깨지지 않았는지 확인한다.

예:

Input 수정 후:

<<<<<<< HEAD
- Movement
- Camera
- Attack
- Boss
- Victory
- Defeat
- Retry

=======
Movement
Camera
Attack
Boss
Victory
Defeat
Retry
>>>>>>> 6032771c (08156)
등 관련 기능을 다시 확인한다.

→ 결과 보고 후 중단

<<<<<<< HEAD

## PHASE 11 — REPORT

최종 결과:

ROOT CAUSE
FIX
VERIFICATION
REGRESSION
REMAINING RISK
NEXT

형식으로 보고한다.
=======
PHASE 11 — REPORT
최종 결과:

ROOT CAUSE FIX VERIFICATION REGRESSION REMAINING RISK NEXT

형식으로 보고한다.
>>>>>>> 6032771c (08156)
