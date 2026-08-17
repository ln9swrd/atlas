# Excelion C++ 소스 코드 검토 보고서
**Code Review Report — Excelion Game Project**

**작성일**: 2026-08-17  
**상태**: 컴파일 성공 (No compilation errors)

---

## 📋 Executive Summary

- **총 C++ 파일**: 31개 (Headers + Source)
- **Compilation Status**: ✅ Clean (No errors)
- **Major Issues Found**: 2개
- **Minor Issues Found**: 3개
- **Best Practices**: Generally followed, with room for improvements

---

## 🔴 Critical Issues

### 1. **Potential Null Pointer Dereference in `ExcelionEnemy::UpdateAI()`**
**File**: [Source/Excelion/AI/ExcelionEnemy.cpp](Source/Excelion/AI/ExcelionEnemy.cpp#L47)  
**Severity**: HIGH

```cpp
case EEnemyAIState::Chase:
{
    if (!TargetActor.IsValid() || Cast<AExcelionCharacter>(TargetActor.Get())->IsDead())
    {
        SetState(EEnemyAIState::Idle);
        break;
    }
```

**Problem**: The cast to `AExcelionCharacter` is not validated before calling `IsDead()`. If the cast fails (returns nullptr), calling `IsDead()` will crash.

**Recommended Fix**:
```cpp
AExcelionCharacter* CharTarget = Cast<AExcelionCharacter>(TargetActor.Get());
if (!TargetActor.IsValid() || (CharTarget && CharTarget->IsDead()))
{
    SetState(EEnemyAIState::Idle);
    break;
}
```

---

### 2. **Weak Pointer Access Without Validation in `ExcelionHUDWidget`**
**File**: [Source/Excelion/UI/ExcelionHUDWidget.cpp](Source/Excelion/UI/ExcelionHUDWidget.cpp#L40)  
**Severity**: MEDIUM

Multiple functions access `PlayerCharacter` and `BossActor` weak pointers after `.IsValid()` check, but the pointers can become invalid between the check and access in multi-frame scenarios.

**Example**:
```cpp
float UExcelionHUDWidget::GetPlayerSCorePercent() const
{
    if (PlayerCharacter.IsValid())
    {
        if (USCoreComponent* SCoreComp = PlayerCharacter->GetSCoreComponent())
        {
            return SCoreComp->MaxSCore > 0.f ? SCoreComp->CurrentSCore / SCoreComp->MaxSCore : 0.0f;
        }
    }
    return 0.0f;
}
```

**Recommended Fix**:
```cpp
float UExcelionHUDWidget::GetPlayerSCorePercent() const
{
    if (AExcelionCharacter* Player = PlayerCharacter.Get())
    {
        if (USCoreComponent* SCoreComp = Player->GetSCoreComponent())
        {
            return SCoreComp->MaxSCore > 0.f ? SCoreComp->CurrentSCore / SCoreComp->MaxSCore : 0.0f;
        }
    }
    return 0.0f;
}
```

---

## 🟡 Important Issues

### 3. **Division by Zero Risk in Multiple Components**
**Files**: 
- [HealthComponent.cpp](Source/Excelion/Combat/HealthComponent.cpp#L61)
- [ExcelionHUDWidget.cpp](Source/Excelion/UI/ExcelionHUDWidget.cpp#L28)

**Severity**: MEDIUM

While there are checks like `MaxHeat > 0.f`, the checks should be more defensive.

**Recommended**: Add assertions or ensure defaults prevent zero division:
```cpp
float UExcelionHUDWidget::GetPlayerSCorePercent() const
{
    if (AExcelionCharacter* Player = PlayerCharacter.Get())
    {
        if (USCoreComponent* SCoreComp = Player->GetSCoreComponent())
        {
            if (SCoreComp->MaxSCore > 0.f)
            {
                return FMath::Clamp(SCoreComp->CurrentSCore / SCoreComp->MaxSCore, 0.f, 1.f);
            }
        }
    }
    return 0.0f;
}
```

---

### 4. **Missing Null Check in Delegate Connection**
**File**: [Source/Excelion/Game/ExcelionGameMode.cpp](Source/Excelion/Game/ExcelionGameMode.cpp#L41)

**Severity**: LOW-MEDIUM

```cpp
void AExcelionGameMode::SetupHUD()
{
    if (HUDWidgetClass && GetWorld())
    {
        APlayerController* PC = UGameplayStatics::GetPlayerController(GetWorld(), 0);
        if (PC)
        {
            ActiveHUDWidget = CreateWidget<UExcelionHUDWidget>(PC, HUDWidgetClass);
            // Missing null check on ActiveHUDWidget before using it
            if (ActiveHUDWidget)
            {
```

Already has the check but should verify PC is valid before casting.

---

### 5. **Overheating Logic Edge Case**
**File**: [Source/Excelion/Combat/SCoreComponent.cpp](Source/Excelion/Combat/SCoreComponent.cpp#L58)

**Severity**: LOW

Heat might not drop to exactly 0.0f due to floating-point precision:
```cpp
void USCoreComponent::UpdateDissipation(float DeltaTime)
{
    if (CurrentHeat > 0.0f)
    {
        CurrentHeat = FMath::Clamp(CurrentHeat - (HeatDissipationRate * DeltaTime), 0.0f, MaxHeat);
        if (bIsOverheated && CurrentHeat <= 0.0f)  // ✓ Good - uses <=
        {
            bIsOverheated = false;
            OnOverheatStateChanged.Broadcast(false);
        }
    }
}
```

This is **already handled correctly** with `<=` comparison.

---

## ✅ Strengths

### Memory Management
- ✅ Good use of `TWeakObjectPtr` for actor references  
- ✅ Proper component ownership hierarchy  
- ✅ `CreateDefaultSubobject` used appropriately  

### Unreal Engine Patterns
- ✅ Proper use of `UCLASS()`, `UPROPERTY()`, `UFUNCTION()` macros  
- ✅ Delegate system (`OnHealthChanged`, `OnDeath`) implemented correctly  
- ✅ Component-based architecture well-structured  

### State Management
- ✅ Clear state machines (Enemy AI, Boss Combat)  
- ✅ State timer properly reset on state transitions  
- ✅ Recovery and cooldown systems well-designed  

### Input System
- ✅ Enhanced Input System properly integrated  
- ✅ Fallback to runtime input mapping works correctly  
- ✅ Input action binding strategy is sound  

---

## 🔧 Recommendations

### Priority 1 (Critical)
1. **Fix null pointer dereference in `ExcelionEnemy::UpdateAI()`** - Cast validation required
2. **Add `.Get()` pattern to weak pointer access** - Replace `.IsValid() -> access` with `.Get()` pattern

### Priority 2 (Important)
3. Add `ensure()` or `check()` macros for critical paths
4. Add more defensive null checks around delegate connections
5. Consider adding debug asserts for state machine transitions

### Priority 3 (Nice to Have)
6. Add logging for edge cases (e.g., attack miss scenarios)
7. Consider adding performance profiling points for combat traces
8. Add FString sanitization in log messages if user input is used

---

## 📊 Code Quality Metrics

| Metric | Status |
|--------|--------|
| Compilation Errors | ✅ 0 |
| Null Pointer Issues | 🟡 2 Major |
| Resource Leaks | ✅ None Detected |
| Memory Management | ✅ Good |
| Documentation | ✅ Good (Comments present) |
| Code Style | ✅ Consistent |

---

## 🎯 Action Items

- [ ] Fix ExcelionEnemy null pointer cast validation
- [ ] Update all weak pointer access to use `.Get()` pattern
- [ ] Add unit tests for combat detection
- [ ] Add edge case testing for overheating transition
- [ ] Review SethBoss pattern execution for nullptr scenarios

---

## 📌 Notes

- The codebase follows UE5.4 conventions well
- Input system fallback strategy is robust
- Combat system hit detection properly validated
- Boss phase transition logic is clean

---

**Review Completed**: 2026-08-17  
**Reviewer**: Code Review Agent  
**Recommended Action**: Address Priority 1 issues before next build
