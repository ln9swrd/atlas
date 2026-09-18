// Copyright Excelion. All Rights Reserved.

#include "Combat/MadnessComponent.h"

UMadnessComponent::UMadnessComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

void UMadnessComponent::BeginPlay()
{
	Super::BeginPlay();
	CurrentMadness = 0.0f;
	CurrentMadnessLevel = 0;
}

void UMadnessComponent::AddMadness(float Amount)
{
	if (Amount <= 0.0f) return;

	CurrentMadness = FMath::Clamp(CurrentMadness + Amount, 0.0f, MaxMadness);
	RecalculateLevel();
}

void UMadnessComponent::ReduceMadness(float Amount)
{
	if (Amount <= 0.0f) return;

	CurrentMadness = FMath::Clamp(CurrentMadness - Amount, 0.0f, MaxMadness);
	RecalculateLevel();
}

void UMadnessComponent::RecalculateLevel()
{
	const int32 NewLevel = FMath::Clamp(FMath::FloorToInt((CurrentMadness / MaxMadness) * MaxMadnessLevel), 0, MaxMadnessLevel);
	if (NewLevel != CurrentMadnessLevel)
	{
		CurrentMadnessLevel = NewLevel;
		OnMadnessLevelChanged.Broadcast(CurrentMadnessLevel, CurrentMadness);
	}
}

float UMadnessComponent::GetDamageMultiplier() const
{
	// 0% at Lvl 0 up to +50% extra attack power at Lvl 5
	return 1.0f + (CurrentMadnessLevel * 0.10f);
}

float UMadnessComponent::GetIncomingDamagePenalty() const
{
	// 0% penalty at Lvl 0 up to +25% extra incoming damage penalty at Lvl 5
	return 1.0f + (CurrentMadnessLevel * 0.05f);
}
