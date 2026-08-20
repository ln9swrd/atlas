# GameMode BeginPlay 적용 문제 조사 — 2026-08-18

> 목적: READ-ONLY 조사 결과 보존.
> 범위: 문서만. 코드/Blueprint/Asset/Config 변경 없음.
> 기준 HEAD: b0b728454e579be13d90e36e42dae572e8d02070

## 1. C++ 확인

- `AExcelionGameMode::BeginPlay()` **존재**
- `Super::BeginPlay()` 호출
- `[AXION PIE DEBUG]` 로그 포함
  - DefaultPawnClass
  - PlayerController Possessed Pawn (Class / Name / Location)

파일: `game/Excelion/Source/Excelion/Game/ExcelionGameMode.cpp`

## 2. Config 확인

`DefaultEngine.ini`:

```
GlobalDefaultGameMode=/Game/Blueprints/BP_ExcelionGameMode.BP_ExcelionGameMode_C
```

실제 PIE 경로 = `BP_ExcelionGameMode_C`

## 3. 현재 상태

| 항목 | 상태 |
|------|------|
| CODE VERIFIED | YES |
| CONFIG VERIFIED | YES |
| EDITOR VERIFIED | NOT VERIFIED |
| PIE VERIFIED | NOT VERIFIED |

## 4. 다음 검증

- Unreal Editor에서 `BP_ExcelionGameMode` Parent Class가 `AExcelionGameMode`인지 확인
- PIE 시 `[AXION PIE DEBUG]` 로그 출력 여부 확인

## 5. 작업 범위

- 문서 1개 추가만
- 코드/Blueprint/Asset/Config 변경 없음
- 기존 변경사항 되돌리기 없음
- 추가 수정 없음
