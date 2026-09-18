// Copyright Excelion. All Rights Reserved.

#include "AI/ExcelionEnemy.h"
#include "Combat/HealthComponent.h"
#include "Combat/CombatComponent.h"
#include "Character/ExcelionCharacter.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"

AExcelionEnemy::AExcelionEnemy()
{
	PrimaryActorTick.bCanEverTick = true;

	HealthComponent = CreateDefaultSubobject<UHealthComponent>(TEXT("HealthComponent"));
	HealthComponent->MaxHealth = 50.f;

	CombatComponent = CreateDefaultSubobject<UCombatComponent>(TEXT("CombatComponent"));
	CombatComponent->AttackDamage = 15.f;
	CombatComponent->AttackRange = 120.f;

	GetCharacterMovement()->MaxWalkSpeed = MoveSpeed;
	GetCharacterMovement()->bOrientRotationToMovement = true;
}

void AExcelionEnemy::BeginPlay()
{
	Super::BeginPlay();

	GetCharacterMovement()->MaxWalkSpeed = MoveSpeed;

	if (HealthComponent)
	{
		HealthComponent->OnDeath.AddDynamic(this, &AExcelionEnemy::OnDeath);
	}
}

void AExcelionEnemy::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	if (CurrentState != EEnemyAIState::Dead)
	{
		UpdateAI(DeltaTime);
	}
}

void AExcelionEnemy::UpdateAI(float DeltaTime)
{
	StateTimer += DeltaTime;

	switch (CurrentState)
	{
	case EEnemyAIState::Idle:
	{
		AActor* Player = FindPlayer();
		if (Player)
		{
			const float Dist = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
			if (Dist <= DetectionRange)
			{
				TargetActor = Player;
				SetState(EEnemyAIState::Chase);
			}
		}
		break;
	}
	case EEnemyAIState::Chase:
	{
		if (!TargetActor.IsValid() || Cast<AExcelionCharacter>(TargetActor.Get())->IsDead())
		{
			SetState(EEnemyAIState::Idle);
			break;
		}

		const float Dist = FVector::Dist(GetActorLocation(), TargetActor->GetActorLocation());
		if (Dist <= AttackRange)
		{
			SetState(EEnemyAIState::Attack);
		}
		else
		{
			ChaseTarget(DeltaTime);
		}
		break;
	}
	case EEnemyAIState::Attack:
	{
		if (StateTimer >= 0.1f && CombatComponent && CombatComponent->CanAttack())
		{
			PerformAttack();
		}
		if (StateTimer >= AttackInterval)
		{
			SetState(EEnemyAIState::Recovery);
		}
		break;
	}
	case EEnemyAIState::Recovery:
	{
		if (StateTimer >= RecoveryTime)
		{
			SetState(EEnemyAIState::Chase);
		}
		break;
	}
	default:
		break;
	}
}

void AExcelionEnemy::SetState(EEnemyAIState NewState)
{
	CurrentState = NewState;
	StateTimer = 0.f;

	if (NewState == EEnemyAIState::Attack || NewState == EEnemyAIState::Recovery || NewState == EEnemyAIState::Dead)
	{
		GetCharacterMovement()->StopMovementImmediately();
	}
}

AActor* AExcelionEnemy::FindPlayer() const
{
	return UGameplayStatics::GetPlayerPawn(GetWorld(), 0);
}

void AExcelionEnemy::ChaseTarget(float DeltaTime)
{
	if (!TargetActor.IsValid())
	{
		return;
	}

	const FVector Direction = (TargetActor->GetActorLocation() - GetActorLocation()).GetSafeNormal2D();
	AddMovementInput(Direction, 1.f);
}

void AExcelionEnemy::PerformAttack()
{
	if (CombatComponent)
	{
		CombatComponent->TryAttack();
	}
}

bool AExcelionEnemy::IsDead() const
{
	return HealthComponent && HealthComponent->IsDead();
}

void AExcelionEnemy::OnDeath()
{
	SetState(EEnemyAIState::Dead);
	GetCharacterMovement()->DisableMovement();
	SetActorEnableCollision(false);
}
