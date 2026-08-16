# Excelion Unreal Rules
6. Unreal 디버깅
Unreal 문제에서는 다음 계층을 순서대로 조사한다.

Project
Config
GameMode
PlayerController
Pawn / Character
Components
Input Mapping
Blueprint execution
Runtime Actor state
PIE behavior
C++ runtime
Log / Trace

필요 이상으로 여러 계층을 동시에 변경하지 않는다.

7. Input Debugging
입력 문제가 발생하면 반드시 입력의 전체 경로를 추적한다.

Keyboard ↓
Input Mapping ↓
Input Action / Axis ↓
Character / Controller ↓
Movement / Rotation function ↓
Character Transform ↓
실제 화면 결과

각 입력을 개별적으로 확인한다.

W A S D

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

Enhanced Input 과 Legacy Input 이 동시에 작동할 가능성도 조사한다.

8. 실제 런타임 상태 우선

파일