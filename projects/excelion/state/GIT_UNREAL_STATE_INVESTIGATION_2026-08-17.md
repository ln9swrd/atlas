# GIT / Unreal State Investigation — 2026-08-17

> 목적: Excelion 현재 Git main 기준 조사 결과 보존.
> 범위: 문서 기록만. Unreal Asset / C++ / Blueprint / Config / Canon / 게임 시스템 변경 없음.
> 기준 HEAD: `4b1375d18c57094f4e1761497c8b70e48cf71a11`

---

## 1. 현재 Git 기준점

```
main HEAD = 4b1375d18c57094f4e1761497c8b70e48cf71a11
```

이 기준으로 조사 결과를 기록한다.

---

## 2. 조사 결과 — 핵심 구조 (Git 확인)

```
Engine Association
→ UE 5.4

Default Map
→ /Game/Maps/NewMap

Global Default GameMode
→ /Game/Blueprints/BP_ExcelionGameMode.BP_ExcelionGameMode_C

Default Pawn (문서·스크립트 기준)
→ BP_ExcelionCharacter

Character C++
→ ExcelionCharacter

Input
→ Enhanced Input

Mapping Context
→ IMC_Default

Actions
→ IA_Move
→ IA_Look
→ IA_Attack
→ IA_Dash

RemoteControl Plugin
→ Enabled

Python Remote Execution
→ Enabled (bRemoteExecution=True)
```

특히 `diagnose_and_fix_input.py`에:

```
BP_ExcelionGameMode
→ DefaultPawnClass
→ BP_ExcelionCharacter
```

설정 및 Read-back 검증 로직이 존재한다.

---

## 3. Asset 존재 (Git 트리 확인)

확인됨:

```
/Game/Blueprints/BP_ExcelionCharacter.uasset
```

존재한다.

반면 현재 Git 트리에서는:

```
BP_ExcelionCharacter0.uasset
```

를 확인하지 못했다.

**확정하지 말 것:** BP_ExcelionCharacter0가 불필요한 Asset이다.

Master PC Unreal Editor에서 보였던 BP_ExcelionCharacter0의 정체는 **미확인**.

미확인 가능성:

```
- PIE/Runtime 인스턴스 명칭
- 로컬 작업트리에만 존재하는 Asset
- Editor의 기존 Loaded Object
- Git main과 다른 로컬 상태
```

---

## 4. PlayerController 상태

현재 Git 조사에서:

```
ExcelionPlayerController
```

라는 별도 Custom PlayerController 구현은 확인하지 못했다.

명시적인 `PlayerControllerClass` 설정도 현재 조사 범위에서는 확인하지 못했다.

기록:

```
Custom PlayerController
→ 미확인 / 구현 근거 없음

기본 APlayerController 사용
→ 가능성 높음 / 미확정
```

추정값을 확정값으로 승격하지 않는다.

---

## 5. 이미 완료된 Prototype 상태 (CURRENT_STATE.md 기준)

```
U1 Player
→ VERIFIED

U2 Combat
→ VERIFIED

U3 Enemy Combat
→ VERIFIED

U4-B Seth Boss
→ VERIFIED

P5-1 Victory
→ VERIFIED

P5-2 Defeat
→ VERIFIED

P5-3 Retry / Level Travel
→ VERIFIED

P5-4 Full Vertical Slice
→ VERIFIED (8/8 PASS)
```

P5-4 시나리오:

```
Scenario A
Player → Enemy → Boss → Victory

Scenario B
Player → Death → Defeat → Retry → Level Reset
```

---

## 6. 검증 수준 구분

**Git에서 확인된 것**

- 파일 존재
- 코드 존재
- 검증 스크립트 존재
- 상태 문서의 VERIFIED 기록
- Git commit history

**Git만으로 확인할 수 없는 것 (미확인)**

- 현재 Master PC의 Unreal Editor 상태
- 현재 로컬 Content Browser Asset 상태
- 현재 PIE Runtime의 실제 Possessed Pawn
- 현재 Editor에서 보이는 BP_ExcelionCharacter0의 정체
- 현재 로컬 프로젝트와 Git main의 완전한 동일성

후자는 미확인으로 기록한다.

---

## 7. 문서 정합성 메모

TASK_MAP.md가 현재 구현 진척( P5 Vertical Slice VERIFIED 등 )과 맞지 않는 부분이 있다.
이번 작업에서 임의로 정정하지 않는다. 차이는 **문서 정합성 문제**로만 기록한다.

---

## 8. 이번 작업 범위

허용: 문서 추가/수정 · 상태 기록 · 조사 결과 기록 · Commit

금지: Unreal Asset 변경 · 코드 변경 · Config 변경 · Blueprint 변경 · 파일 삭제/이동 · Branch 변경 · History rewrite · Force push

---

## 9. NEXT

다음 작업 (Master 지시 대기):

- Master PC Unreal Editor와 Git main 상태 대조
- BP_ExcelionCharacter 실제 Asset 수 확인
- GameMode Default Pawn 확인
- PIE Possessed Pawn 확인

---

**기록 원칙:** 이번 Commit의 목적은 "무엇을 고치는 것"이 아니라 "지금까지 확인한 사실과 미확인 사항을 보존하는 것"이다.
특히 BP_ExcelionCharacter0, PlayerController, 로컬 Editor 상태에 대해서는 추정으로 결론 내리지 않는다.
