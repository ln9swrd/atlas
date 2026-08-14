// Copyright Excelion. All Rights Reserved.

#include "Combat/ExcelionFeedbackSubsystem.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"
#include "TimerManager.h"

void UExcelionFeedbackSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);
}

void UExcelionFeedbackSubsystem::Deinitialize()
{
	if (UWorld* World = GetWorld())
	{
		World->GetTimerManager().ClearTimer(HitStopTimerHandle);
	}
	Super::Deinitialize();
}

void UExcelionFeedbackSubsystem::TriggerHitStop(float Duration, float TimeDilation)
{
	UWorld* World = GetWorld();
	if (!World) return;

	// Apply hitstop time dilation
	UGameplayStatics::SetGlobalTimeDilation(World, TimeDilation);
	OnHitStopTriggered.Broadcast(Duration);

	// Reset after scaled duration
	World->GetTimerManager().SetTimer(HitStopTimerHandle, this, &UExcelionFeedbackSubsystem::ResetHitStopDilation, Duration * TimeDilation, false);
}

void UExcelionFeedbackSubsystem::ResetHitStopDilation()
{
	if (UWorld* World = GetWorld())
	{
		UGameplayStatics::SetGlobalTimeDilation(World, 1.0f);
	}
}

void UExcelionFeedbackSubsystem::TriggerCameraShake(TSubclassOf<UCameraShakeBase> ShakeClass, float Scale)
{
	if (!ShakeClass) return;

	if (APlayerController* PC = UGameplayStatics::GetPlayerController(GetWorld(), 0))
	{
		PC->ClientStartCameraShake(ShakeClass, Scale);
		OnCameraShakeTriggered.Broadcast(ShakeClass, Scale);
	}
}

void UExcelionFeedbackSubsystem::BroadcastHitImpact(FVector ImpactLocation, FVector ImpactNormal, bool bCriticalHit)
{
	// Trigger hitstop on critical hit
	if (bCriticalHit)
	{
		TriggerHitStop(0.12f, 0.01f);
	}
}
