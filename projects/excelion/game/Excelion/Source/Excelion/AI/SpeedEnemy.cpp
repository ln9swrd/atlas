// Copyright Excelion. All Rights Reserved.

#include "AI/SpeedEnemy.h"
#include "Combat/HealthComponent.h"
#include "Combat/CombatComponent.h"
#include "GameFramework/CharacterMovementComponent.h"

ASpeedEnemy::ASpeedEnemy()
{
	MoveSpeed = 700.f;
	AttackInterval = 0.9f;
	RecoveryTime = 0.5f;
	DetectionRange = 1800.f;
	AttackRange = 150.f;

	if (HealthComponent)
	{
		HealthComponent->MaxHealth = 30.f;
	}
	if (CombatComponent)
	{
		CombatComponent->AttackDamage = 10.f;
		CombatComponent->AttackRange = 100.f;
	}
}
