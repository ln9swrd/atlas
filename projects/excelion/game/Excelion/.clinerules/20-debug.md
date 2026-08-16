# Excelion Debug Rules

## 3. 디버깅 원칙

디버깅에서 추측 기반 반복 수정을 금지한다.

다음 순서를 따른다.

REPRODUCE
↓
OBSERVE
↓
COLLECT EVIDENCE
↓
ISOLATE
↓
IDENTIFY ROOT CAUSE
↓
PROPOSE MINIMAL FIX
↓
APPLY FIX
↓
REBUILD / RUN
↓
VERIFY
↓
REPORT


## 4. 문제 재현 우선

사용자가 실제 실행에서 발생했다고 보고한 문제가 있다면
기존 테스트 결과보다 현재 실제 증상을 우선한다.

예:

"8/8 PASS"가 존재하더라도
사용자가 실제 Play에서 WASD가 회전한다고 보고하면
기존 PASS를 정상 동작의 증거로 간주하지 않는다.

실제 재현 여부를 다시 확인한다.
