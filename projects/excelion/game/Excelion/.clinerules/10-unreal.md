# Excelion Unreal Rules

## 6. Unreal 디버깅

Unreal 문제에서는 다음 계층을 순서대로 조사한다.

1. Project
2. Config
3. GameMode
4. PlayerController
5. Pawn / Character
6. Components
7. Input Mapping
8. Blueprint execution
9. Runtime Actor state
10. PIE behavior
11. C++ runtime
12. Log / Trace

필요 이상으로 여러 계층을 동시에 변경하지 않는다.


## 7. Input Debugging

입력 문제가 발생하면 반드시 입력의 전체 경로를 추적한다.

Keyboard
↓
Input Mapping
↓
Input Action / Axis
↓
Character / Controller
↓
Movement / Rotation function
↓
Character Transform
↓
실제 화면 결과

각 입력을 개별적으로 확인한다.

W
A
S
D

각각이 어떤 함수에 연결되는지 확인한다.

특히 다음을 확인한다.

- Enhanced Input
- Legacy Input
- DefaultInput.ini
- Input Mapping Context
- Input Action
- Add Movement Input
- Add Controller Yaw Input
- Add Actor Rotation
- Controller Rotation
- Character Rotation
- Orient Rotation to Movement

Enhanced Input과 Legacy Input이 동시에 작동할 가능성도 조사한다.


## 8. 실제 런타임 상태 우선

파일에 기록된 설정만 보고 Runtime 동작을 확정하지 않는다.

다음은 서로 다른 정보로 취급한다.

DESIGN
CONFIGURATION
IMPLEMENTATION
RUNTIME STATE
OBSERVED BEHAVIOR

특히 Runtime State와 Observed Behavior가 Config와 다르면
Runtime/Observed 결과를 우선하여 원인을 조사한다.
