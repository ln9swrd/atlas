# MENOS Browser PoC Robot 위치 최소 Runtime 검증

상태: `NO DIFFERENCE OBSERVED` / 1차 실험 완료
목적: Browser PoC에서 Robot `LEFT / CENTER / RIGHT` 위치가 동일한 전투 조건의 실제 결과에 차이를 만드는지 최소 Runtime 실험으로 확인한다.

## 1. 기준선

- HEAD: `a906aa52dc51eb5ef8bf014b44576efe0e1cb212`
- Branch: `main`
- 실험 전 Working Tree: `?? projects/menos/MENOS_DESIGN_IMPLEMENTATION_AUDIT.md`
- 대상: `projects/menos` Browser PoC
- 실행 방식: 변경하지 않은 Browser PoC를 로컬 HTTP 서버로 실행하고 Playwright로 조작
- Godot: 이번 1차 실험 대상에서 제외
- Commit/Push: 수행하지 않음

기존 변경사항은 수정하거나 되돌리지 않았다.

## 2. 실험 조건

### 독립 변수

Robot 위치:

```text
LEFT
CENTER
RIGHT
```

### 고정 조건

- 동일한 Browser PoC
- 초기 Base HP: `100`
- 초기 Gold: `180`
- 동일한 Tower 구성과 위치
- Cannon 2기, Gatling 2기
- Tower 건설 후 시작 Gold: `0`
- 동일한 Wave 구성: Wave 1~4
- 동일한 Robot: Atlas-01
- 초기 Robot HP: `220`
- 초기 이동 명령: `5`
- 위치 변경 1회 후 남은 명령: `4`
- Robot 능력과 전투 수치 변경 없음
- 코드, 데이터, UI, 밸런스 변경 없음

Tower는 각 실행에서 동일하게 4개를 배치하고, Robot을 출격시킨 뒤 지정 위치로 1회 이동시켰다. Wave 1~3을 순서대로 실행하고 Wave 4를 실행했다.

## 3. 실험 절차

각 실행은 페이지를 새로고침해 초기화했다.

```text
페이지 초기화
    -> 동일한 Tower 4기 배치
    -> Robot 출격
    -> LEFT 또는 CENTER 또는 RIGHT 선택
    -> Wave 1 시작 및 완료
    -> Wave 2 시작 및 완료
    -> Wave 3 시작 및 완료
    -> Wave 4 시작 및 완료
    -> HUD와 Event Feed 기록
```

Browser PoC의 Wave Clear 버튼 문구는 Wave 3 완료 후에도 `ALL WAVES CLEAR`로 표시되지만, 내부 Wave 값이 4인 상태에서 클릭하면 Wave 4가 실행된다. 이 UI 상태는 실험 중 관찰한 기존 구현 특성으로 기록하며 수정하지 않았다.

## 4. 실험 결과

| Robot 위치 | 최종 Base HP | 최종 Robot HP | 최종 Gold | Wave 4 결과 | Giant Feed | 최종 상태 |
| --- | ---: | ---: | ---: | --- | --- | --- |
| LEFT | `100` | `220 / 220` | `916` | Clear | 확인 | `WAVE CLEAR` |
| CENTER | `100` | `220 / 220` | `916` | Clear | 확인 | `WAVE CLEAR` |
| RIGHT | `100` | `220 / 220` | `916` | Clear | 확인 | `WAVE CLEAR` |

각 실행에서 위치 변경 후 Move Commands는 `4`였다.

Gold `916`은 동일한 Tower 비용 차감 후 네 개 Wave의 모든 보상이 동일하게 누적된 결과와 일치한다. Browser HUD에는 Enemy 처치 수를 직접 표시하는 카운터가 없으므로, 개별 처치 수는 별도 측정하지 않았다. Event Feed에서는 세 실행 모두 Giant neutralized 이벤트를 확인했다.

## 5. 관찰

실제 Browser Runtime에서 확인한 사실:

- 세 위치 모두 Wave 4까지 완료했다.
- 세 위치 모두 Base HP가 `100`으로 유지되었다.
- 세 위치 모두 Robot HP가 `220 / 220`으로 유지되었다.
- 세 위치 모두 최종 Gold가 `916`이었다.
- 세 위치 모두 Giant 처치 Feed가 발생했다.
- 세 위치 모두 최종 상태가 `WAVE CLEAR`였다.
- 이번 조건에서는 Base HP, Robot HP, Gold, Wave 결과에 차이가 없었다.

Robot 공격 이벤트의 정확한 횟수와 Enemy 처치 수는 Browser UI에 직접 표시되지 않아 이번 최소 실험에서 수치화하지 않았다.

## 6. 판정

### NO DIFFERENCE OBSERVED

LEFT, CENTER, RIGHT 각 1회 실행 결과, 현재 고정 조건에서는 측정 가능한 전투 결과 차이가 관찰되지 않았다.

이 결과는 다음을 의미하지 않는다.

- Robot 위치에 전략적 의미가 없다.
- 모든 Wave와 모든 Tower 구성에서 위치가 동일하다.
- 위치 시스템이 실패했다.

이번 판정은 현재 Browser PoC의 특정 조건에서 차이가 관찰되지 않았다는 뜻으로만 기록한다.

## 7. 검증 상태

- CODE: `PASS` - 실험 대상 파일을 변경하지 않고 Browser PoC를 실행함
- BUILD: `HIGH CONFIDENCE` - 별도 빌드 없이 정적 Browser PoC를 HTTP 서버에서 실행함
- EDITOR: `N/A` - Godot Editor 실험 아님
- PIE / Browser Runtime: `PASS` - LEFT/CENTER/RIGHT 각 1회 실제 실행 완료

## 8. 미확인 사항

- 다른 Tower 배치에서 위치 차이가 발생하는지
- Spawn 압력이 높은 조건에서 위치 차이가 발생하는지
- 다른 Wave만 대상으로 했을 때 차이가 발생하는지
- 위치별 Robot 공격 이벤트와 실제 처치 수의 차이
- 반복 실행 시 동일 결과가 재현되는지
- 플레이어가 위치 차이를 전략적 선택으로 인식하는지

## 9. OUT OF SCOPE

- 코드 수정
- 데이터 수정
- 밸런스 수정
- Tower, Enemy, Robot 능력 변경
- Godot Wave 결함 수정
- Robot HP 또는 이동 시간 구현
- 추가 반복 실험
- 대규모 통계 실험
- Asset 변경
- Commit/Push

이번 판정 후 밸런스 조정이나 구현 변경으로 자동 진행하지 않는다.
