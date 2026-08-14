// Copyright Excelion. All Rights Reserved.

#include "Combat/SCoreComponent.h"

USCoreComponent::USCoreComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
}

void USCoreComponent::BeginPlay()
{
	Super::BeginPlay();
	CurrentSCore = 0.0f;
	CurrentHeat = 0.0f;
	bIsOverheated = false;
}

void USCoreComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	// Passive S-Core charge when not overheated
	if (!bIsOverheated && CurrentSCore < MaxSCore)
	{
		AddSCore(ChargeRatePerSec * DeltaTime);
	}

	UpdateDissipation(DeltaTime);
}

void USCoreComponent::AddSCore(float Amount)
{
	if (Amount <= 0.0f) return;

	CurrentSCore = FMath::Clamp(CurrentSCore + Amount, 0.0f, MaxSCore);
	OnSCoreChanged.Broadcast(CurrentSCore, MaxSCore);
}

bool USCoreComponent::ConsumeSCore(float Amount)
{
	if (!CanUseSCoreAbility(Amount))
	{
		return false;
	}

	CurrentSCore = FMath::Clamp(CurrentSCore - Amount, 0.0f, MaxSCore);
	OnSCoreChanged.Broadcast(CurrentSCore, MaxSCore);
	return true;
}

void USCoreComponent::AddHeat(float Amount)
{
	if (Amount <= 0.0f) return;

	CurrentHeat = FMath::Clamp(CurrentHeat + Amount, 0.0f, MaxHeat);
	if (!bIsOverheated && CurrentHeat >= OverheatThreshold)
	{
		bIsOverheated = true;
		OnOverheatStateChanged.Broadcast(true);
	}
}

bool USCoreComponent::CanUseSCoreAbility(float Cost) const
{
	return !bIsOverheated && (CurrentSCore >= Cost);
}

void USCoreComponent::UpdateDissipation(float DeltaTime)
{
	if (CurrentHeat > 0.0f)
	{
		CurrentHeat = FMath::Clamp(CurrentHeat - (HeatDissipationRate * DeltaTime), 0.0f, MaxHeat);
		if (bIsOverheated && CurrentHeat <= 0.0f)
		{
			bIsOverheated = false;
			OnOverheatStateChanged.Broadcast(false);
		}
	}
}
