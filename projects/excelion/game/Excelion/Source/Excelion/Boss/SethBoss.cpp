// Copyright Excelion. All Rights Reserved.

#include "Boss/SethBoss.h"
#include "Combat/HealthComponent.h"
#include "Character/ExcelionCharacter.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "Kismet/GameplayStatics.h"
#include "DrawDebugHelpers.h"
#include "Engine/World.h"

ASethBoss::ASethBoss()
{
	PrimaryActorTick.bCanEverTick = true;

	HealthComponent = CreateDefaultSubobject<UHealthComponent>(TEXT("HealthComponent"));
	HealthComponent->MaxHealth = 500.f;

	GetCharacterMovement()->MaxWalkSpeed = 200.f;
	GetCharacterMovement()->bOrientRotationToMovement = true;
}

void ASethBoss::BeginPlay()
{
	Super::BeginPlay();

	if (HealthComponent)
	{
		HealthComponent->OnDeath.AddDynamic(this, &ASethBoss::OnDeath);
	}
}

void ASethBoss::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	if (CurrentState != ESethBossState::Death)
	{
		UpdateBoss(DeltaTime);
	}
}

void ASethBoss::UpdateBoss(float DeltaTime)
{
	StateTimer += DeltaTime;

	switch (CurrentState)
	{
	case ESethBossState::Idle:
	{
		AActor* Player = FindPlayer();
		if (Player)
		{
			const float Dist = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
			if (Dist <= DetectionRange)
			{
				TargetActor = Player;
				SetState(ESethBossState::Combat);
			}
		}
		break;
	}
	case ESethBossState::Combat:
	{
		if (!TargetActor.IsValid())
		{
			SetState(ESethBossState::Idle);
			break;
		}

		if (StateTimer >= PatternInterval)
		{
			StartPattern01();
		}
		else
		{
			// Face player
			const FVector Dir = (TargetActor->GetActorLocation() - GetActorLocation()).GetSafeNormal2D();
			if (!Dir.IsNearlyZero())
			{
				SetActorRotation(Dir.Rotation());
			}
		}
		break;
	}
	case ESethBossState::Warning:
	{
		DrawPatternDebug();
		if (StateTimer >= WarningDuration)
		{
			SetState(ESethBossState::Attack);
		}
		break;
	}
	case ESethBossState::Attack:
	{
		if (StateTimer <= 0.1f)
		{
			ExecutePatternAttack();
		}
		if (StateTimer >= AttackDuration)
		{
			SetState(ESethBossState::Recovery);
		}
		break;
	}
	case ESethBossState::Recovery:
	{
		if (StateTimer >= RecoveryDuration)
		{
			SetState(ESethBossState::Combat);
		}
		break;
	}
	default:
		break;
	}
}

void ASethBoss::SetState(ESethBossState NewState)
{
	CurrentState = NewState;
	StateTimer = 0.f;
}

AActor* ASethBoss::FindPlayer() const
{
	return UGameplayStatics::GetPlayerPawn(GetWorld(), 0);
}

void ASethBoss::StartPattern01()
{
	if (!TargetActor.IsValid())
	{
		return;
	}

	// Target location: player current position (telegraph)
	PatternTargetLocation = TargetActor->GetActorLocation();
	PatternTargetLocation.Z = GetActorLocation().Z;

	SetState(ESethBossState::Warning);
}

void ASethBoss::ExecutePatternWarning()
{
	// Handled in Tick via DrawPatternDebug
}

void ASethBoss::ExecutePatternAttack()
{
	// Apply damage to player if inside radius
	if (!TargetActor.IsValid())
	{
		return;
	}

	const float Dist = FVector::Dist2D(TargetActor->GetActorLocation(), PatternTargetLocation);
	if (Dist <= PatternRadius)
	{
		AExcelionCharacter* PlayerChar = Cast<AExcelionCharacter>(TargetActor.Get());
		if (PlayerChar && !PlayerChar->IsInvulnerable())
		{
			PlayerChar->TakeDamage(PatternDamage, FDamageEvent(), GetController(), this);
		}
	}

	// Debug flash
	DrawDebugSphere(GetWorld(), PatternTargetLocation, PatternRadius, 24, FColor::Red, false, 0.5f, 0, 3.f);
}

void ASethBoss::DrawPatternDebug()
{
	// Warning circle (yellow)
	DrawDebugSphere(GetWorld(), PatternTargetLocation, PatternRadius, 24, FColor::Yellow, false, -1.f, 0, 2.f);
}

bool ASethBoss::IsDead() const
{
	return HealthComponent && HealthComponent->IsDead();
}

void ASethBoss::OnDeath()
{
	SetState(ESethBossState::Death);
	GetCharacterMovement()->DisableMovement();
	SetActorEnableCollision(false);

	// TODO: Notify GameMode for Victory (Phase 6)
}
