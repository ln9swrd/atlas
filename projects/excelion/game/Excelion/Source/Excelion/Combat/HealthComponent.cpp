// Copyright Excelion. All Rights Reserved.

#include "Combat/HealthComponent.h"

UHealthComponent::UHealthComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

void UHealthComponent::BeginPlay()
{
	Super::BeginPlay();
	CurrentHealth = MaxHealth;
	bIsDead = false;
}

float UHealthComponent::ApplyDamage(float DamageAmount)
{
	if (bIsDead || DamageAmount <= 0.f)
	{
		return 0.f;
	}

	const float PreviousHealth = CurrentHealth;
	CurrentHealth = FMath::Max(0.f, CurrentHealth - DamageAmount);
	const float ActualDamage = PreviousHealth - CurrentHealth;

	OnHealthChanged.Broadcast(CurrentHealth, MaxHealth);

	if (CurrentHealth <= 0.f)
	{
		HandleDeath();
	}

	return ActualDamage;
}

void UHealthComponent::ResetHealth()
{
	CurrentHealth = MaxHealth;
	bIsDead = false;
	OnHealthChanged.Broadcast(CurrentHealth, MaxHealth);
}

float UHealthComponent::GetHealthPercent() const
{
	return MaxHealth > 0.f ? CurrentHealth / MaxHealth : 0.f;
}

void UHealthComponent::HandleDeath()
{
	if (bIsDead)
	{
		return;
	}
	bIsDead = true;
	OnDeath.Broadcast();
}
