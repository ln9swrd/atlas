// Copyright Excelion. All Rights Reserved.

#include "AI/PowerEnemy.h"
#include "Combat/HealthComponent.h"
#include "Combat/CombatComponent.h"
#include "GameFramework/CharacterMovementComponent.h"

APowerEnemy::APowerEnemy()
{
	MoveSpeed = 280.f;
	AttackInterval = 2.2f;
	RecoveryTime = 1.2f;
	DetectionRange = 1200.f;
	AttackRange = 200.f;

	if (HealthComponent)
	{
		HealthComponent->MaxHealth = 120.f;
	}
	if (CombatComponent)
	{
		CombatComponent->AttackDamage = 35.f;
		CombatComponent->AttackRange = 150.f;
		CombatComponent->AttackRadius = 80.f;
	}
}
