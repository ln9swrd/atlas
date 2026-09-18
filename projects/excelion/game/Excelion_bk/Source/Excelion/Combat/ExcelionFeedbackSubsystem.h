// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "Camera/CameraShakeBase.h"
#include "ExcelionFeedbackSubsystem.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHitStopTriggeredSignature, float, Duration);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnCameraShakeTriggeredSignature, TSubclassOf<UCameraShakeBase>, ShakeClass, float, Scale);

/**
 * Excelion Combat Feedback Subsystem (WorldSubsystem)
 * World-level SSOT feedback bus handling HitStop, Camera Shake, SFX/VFX events.
 */
UCLASS()
class EXCELION_API UExcelionFeedbackSubsystem : public UWorldSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;
	virtual void Deinitialize() override;

	// ----- Delegates -----
	UPROPERTY(BlueprintAssignable, Category = "Feedback|Events")
	FOnHitStopTriggeredSignature OnHitStopTriggered;

	UPROPERTY(BlueprintAssignable, Category = "Feedback|Events")
	FOnCameraShakeTriggeredSignature OnCameraShakeTriggered;

	// ----- Feedback Triggers -----
	UFUNCTION(BlueprintCallable, Category = "Feedback")
	void TriggerHitStop(float Duration = 0.08f, float TimeDilation = 0.01f);

	UFUNCTION(BlueprintCallable, Category = "Feedback")
	void TriggerCameraShake(TSubclassOf<UCameraShakeBase> ShakeClass, float Scale = 1.0f);

	UFUNCTION(BlueprintCallable, Category = "Feedback")
	void BroadcastHitImpact(FVector ImpactLocation, FVector ImpactNormal, bool bCriticalHit = false);

private:
	FTimerHandle HitStopTimerHandle;
	void ResetHitStopDilation();
};
