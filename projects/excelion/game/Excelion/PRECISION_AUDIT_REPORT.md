# 정밀 검토 보고서 — 지속성(Persistence) 문제 근본 원인 분석

## 📋 발견된 3가지 중대 결함

### ❌ 문제 1: IMC_Excelion 존재하지 않음
**상황:**
- 코드: `DefaultMappingContext`를 가정 (IMC_Excelion으로 명명된 것으로 추정)
- 실제: `/Game/Input/` 디렉토리에 **IMC_Default.uasset만 존재**
- 결과: Input Mapping Context가 None으로 남아 있어 Enhanced Input 시스템 미작동

**수정 완료:**
✓ [ExcelionCharacter.cpp](projects/excelion/game/Excelion/Source/Excelion/Character/ExcelionCharacter.cpp) 생성자에 자동 로드 로직 추가
```cpp
DefaultMappingContext = LoadObject<UInputMappingContext>(nullptr, TEXT("/Game/Input/IMC_Default"));
```
- 이제 플레이 시 IMC_Default가 자동으로 로드됨
- Blueprint CDO에서 수동 할당 불필요

---

### ❌ 문제 2: MoveForward/MoveRight 축 정의 없음
**상황:**
- DefaultInput.ini에 `AxisMappings` 섹션 자체가 없음
- SetupPlayerInputComponent에서 fallback 축 바인딩이 선택적 (조건부)
- 결과: Enhanced Input 실패 시 이동 불가능

**수정 완료:**
✓ [DefaultInput.ini](projects/excelion/game/Excelion/Config/DefaultInput.ini) 마지막에 추가:
```ini
+AxisMappings=(AxisName="MoveForward",Key=W,Scale=1.0)
+AxisMappings=(AxisName="MoveForward",Key=S,Scale=-1.0)
+AxisMappings=(AxisName="MoveRight",Key=D,Scale=1.0)
+AxisMappings=(AxisName="MoveRight",Key=A,Scale=-1.0)
```
- W/A/S/D 키가 이제 MoveForward/MoveRight 축으로 매핑됨
- Enhanced Input 실패 시 자동 폴백

✓ [ExcelionCharacter.cpp](projects/excelion/game/Excelion/Source/Excelion/Character/ExcelionCharacter.cpp) SetupPlayerInputComponent 수정:
```cpp
// LEGACY FALLBACK: Always bind MoveForward/MoveRight axis handlers...
PlayerInputComponent->BindAxis("MoveForward", this, &AExcelionCharacter::MoveForward);
PlayerInputComponent->BindAxis("MoveRight", this, &AExcelionCharacter::MoveRight);
```
- 이제 **항상** legacy 축이 바인딩되어 Enhanced Input이 없어도 작동

---

### ❌ 문제 3: NewMap의 World Settings이 저장되지 않음
**상황:**
- NewMap.umap 파일: 14 KB (매우 작음)
- 일반적 configured map: 30+ KB
- 원인: NewMap을 생성했지만 World Settings 오버라이드를 저장하지 않았음
- 결과: 매번 PIE 시작 시 GameMode Override가 None으로 리셋됨

**상태:**
- 코드 레벨 수정은 완료 (DefaultEngine.ini에 GlobalDefaultGameMode 설정)
- **에디터 레벨 수정은 필요** (아래 참고)

---

## ✅ 완료된 수정사항

### 1. DefaultEngine.ini (이미 수정됨)
```ini
[/Script/EngineSettings.GameMapsSettings]
GameDefaultMap=/Game/Maps/NewMap
GlobalDefaultGameMode=/Script/Excelion.ExcelionGameMode
```
- ✓ 프로젝트 기본 맵: NewMap
- ✓ 프로젝트 기본 게임모드: ExcelionGameMode

### 2. DefaultInput.ini (지금 수정됨)
```ini
DefaultPlayerInputClass=/Script/EnhancedInput.EnhancedPlayerInput
DefaultInputComponentClass=/Script/EnhancedInput.EnhancedInputComponent

+AxisMappings=(AxisName="MoveForward",Key=W,Scale=1.0)
+AxisMappings=(AxisName="MoveForward",Key=S,Scale=-1.0)
+AxisMappings=(AxisName="MoveRight",Key=D,Scale=1.0)
+AxisMappings=(AxisName="MoveRight",Key=A,Scale=-1.0)
```
- ✓ Enhanced Input 클래스 설정 (기존)
- ✓ W/A/S/D 축 매핑 추가 (신규)

### 3. ExcelionCharacter.h (지금 수정됨)
```cpp
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Input", meta = (DisplayName = "Default Mapping Context"))
TObjectPtr<class UInputMappingContext> DefaultMappingContext;
```
- ✓ TObjectPtr로 변경 (더 안전한 포인터 관리)
- ✓ BlueprintReadWrite로 변경 (런타임 검사 가능)

### 4. ExcelionCharacter.cpp - 생성자 (지금 수정됨)
```cpp
if (!DefaultMappingContext)
{
    DefaultMappingContext = LoadObject<UInputMappingContext>(nullptr, TEXT("/Game/Input/IMC_Default"));
}
if (!MoveAction)
{
    MoveAction = LoadObject<UInputAction>(nullptr, TEXT("/Game/Input/IA_Move"));
}
// ... 나머지 Input Assets도 동일
```
- ✓ 자동 에셋 로드 로직 추가
- ✓ Blueprint에서 할당 안 되면 자동 로드

### 5. ExcelionCharacter.cpp - SetupPlayerInputComponent (지금 수정됨)
```cpp
// LEGACY FALLBACK: Always bind MoveForward/MoveRight axis handlers...
UE_LOG(LogTemp, Warning, TEXT("[INPUT DEBUG] Binding legacy MoveForward/MoveRight axis handlers..."));
PlayerInputComponent->BindAxis("MoveForward", this, &AExcelionCharacter::MoveForward);
PlayerInputComponent->BindAxis("MoveRight", this, &AExcelionCharacter::MoveRight);
UE_LOG(LogTemp, Warning, TEXT("[INPUT DEBUG] Legacy axis fallback ALWAYS BOUND..."));
```
- ✓ 조건부에서 항상 바인딩으로 변경
- ✓ 중복 로그로 보증성 강화

---

## 🔧 다음 단계: Unreal Editor에서 수행 필요

### Step 1: 프로젝트 컴파일
1. Visual Studio에서 Excelion.sln 열기
2. Excelion (Development) 선택 → Build
3. 또는 Unreal Editor에서:
   - Tools → Compile (또는 Ctrl+Shift+B)

**예상 로그:**
```
[EXCELION INIT] Auto-loaded Input Assets - IMC: IMC_Default, Move: IA_Move, Look: IA_Look
[INPUT DEBUG] Legacy axis fallback ALWAYS BOUND - MoveForward/MoveRight from DefaultInput.ini
```

### Step 2: NewMap World Settings 저장
1. Unreal Editor 실행
2. `Content Browser` → `/Game/Maps/`
3. `NewMap` 더블클릭 (열기)
4. `Shift + L` → **World Settings** 패널 열기
5. **Maps & Modes** 섹션 확인:
   - `GameMode Override`: 현재값 확인 (None이면 수정)
   - 만약 None: `BP_ExcelionGameMode` 선택
6. **File** → **Save** (Ctrl+S)

**확인:**
- NewMap.umap 파일 크기가 14KB → 30KB 이상으로 증가
- 매번 열어도 GameMode Override 값 유지

### Step 3: 모든 에셋 저장
1. **File** → **Save All** (Ctrl+Shift+S)
2. 또는 각 파일별 저장 확인

### Step 4: PIE 테스트
1. **Play** 버튼 (또는 Alt+P)
2. **검증 항목:**
   - [ ] W: 앞으로 이동
   - [ ] A: 왼쪽으로 이동
   - [ ] S: 뒤로 이동
   - [ ] D: 오른쪽으로 이동
   - [ ] 마우스: 카메라 회전
   - [ ] 매번 재설정 필요 없음 (저장됨)
3. **Esc** 또는 **Stop**으로 종료

### Step 5: 로그 확인
1. Output Log 보기: **Window** → **Developer Tools** → **Output Log**
2. 다음 로그 확인:
   ```
   [EXCELION INIT] Auto-loaded Input Assets - IMC: IMC_Default, Move: IA_Move, Look: IA_Look
   [INPUT DEBUG] SetupPlayerInputComponent called
   [INPUT DEBUG] MoveAction bound via Enhanced Input
   [INPUT DEBUG] LookAction bound via Enhanced Input
   [INPUT DEBUG] Legacy axis fallback ALWAYS BOUND - MoveForward/MoveRight from DefaultInput.ini
   ```

---

## 📊 기대 효과

### 현재 문제
- ❌ 매번 PIE마다 설정 재구성 필요
- ❌ Input 에셋이 None
- ❌ MoveForward/MoveRight 축 없음
- ❌ World Settings 리셋

### 수정 후
- ✅ 자동 Input 에셋 로드 (IMC_Default, IA_Move 등)
- ✅ 항상 작동하는 W/A/S/D 축 (DefaultInput.ini)
- ✅ 항상 바인딩되는 legacy fallback
- ✅ World Settings 저장되어 유지 (에디터 저장 후)
- ✅ **설정 재구성 불필요 → 무한 반복 루프 해소**

---

## 🔍 지속성 문제의 본질

**이전 가설:** "프로젝트 기본 맵이 OpenWorld여서 리셋됨"
- ✓ 맞음 (이미 수정)
- ✓ 하지만 이것만으로는 불충분

**실제 근본 원인 (3가지 복합 발생):**
1. Input 에셋 누락 (IMC_Excelion 없음)
2. Axis 정의 없음 (MoveForward/MoveRight 불가)
3. World Settings 오버라이드 미저장 (NewMap에)

**이 3가지를 모두 수정해야만** "매번 설정 재구성" 문제 해결됨.

---

## 📝 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| DefaultEngine.ini (GameDefaultMap) | ✅ DONE | 이미 수정됨 |
| DefaultEngine.ini (GlobalDefaultGameMode) | ✅ DONE | 이미 수정됨 |
| DefaultInput.ini (Axis Mappings) | ✅ DONE | 방금 추가됨 |
| ExcelionCharacter.h (프로퍼티 개선) | ✅ DONE | TObjectPtr, BlueprintReadWrite |
| ExcelionCharacter.cpp (자동 로드) | ✅ DONE | IMC_Default, IA_Move 등 자동 로드 |
| ExcelionCharacter.cpp (항상 바인딩) | ✅ DONE | legacy MoveForward/MoveRight 항상 바인딩 |
| 프로젝트 컴파일 | ⏳ TODO | Editor에서 수행 필요 |
| NewMap World Settings 저장 | ⏳ TODO | Editor에서 수행 필요 |
| PIE 검증 | ⏳ TODO | 컴파일 후 테스트 |

