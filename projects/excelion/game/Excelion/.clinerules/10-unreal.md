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

8. Unreal Editor 검증 도구 우선순위

**Unreal Editor 가 실행 중인 경우**:
- Editor 의 실제 상태를 **반드시 우선 검증한다**.
- 검증 도구의 기본 우선순위:
  1. **Unreal MCP** (MCP 에서 정보를 확인할 수 있으면 우선 사용)
  2. **Unreal Editor Python API** (Python Script Plugin 또는 다른 Python 호출 경로)
  3. **Remote Control API** (API endpoint 접근 가능 여부 확인)
  4. **UAsset 직접 파싱** (파서 없음 또는 마지막 수단)

- MCP 에서 정보를 확인할 수 없는 경우:
  - 즉시 UNVERIFIED 로 종료하지 않는다.
  - 현재 사용 가능한 Unreal Python 또는 Remote Control 경로를 확인하여 동일한 정보를 조회할 수 있는지 조사한다.

- UAsset Parser 는 Editor 기반 검증 방법으로 확인할 수 없는 경우에만 대안으로 검토한다.

**도구 제한**:
- 도구 존재라는 사실만으로 **사용 가능하다고 가정하지 않는다**.
- 실제 연결 상태와 제공 기능을 확인한다.
- 검증 가능한 방법이 있음에도 단순히 "UAsset Parser 가 없다"는 이유만으로 UNVERIFIED 처리하지 않는다.

9. 실제 런타임 상태 우선
======= SEARCH
