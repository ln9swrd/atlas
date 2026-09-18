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
	HealthComponent->MaxHealth = 480.f;

	GetCharacterMovement()->MaxWalkSpeed = 200.f;
	GetCharacterMovement()->bOrientRotationToMovement = true;

	// Fallback visual mesh for Seth Boss
	FallbackVisualMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("FallbackVisualMesh"));
	FallbackVisualMesh->SetupAttachment(RootComponent);
	FallbackVisualMesh->SetRelativeScale3D(FVector(1.2f, 1.2f, 2.5f));

	static ConstructorHelpers::FObjectFinder<UStaticMesh> DefaultCylinderMesh(TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));
	if (DefaultCylinderMesh.Succeeded())
	{
		FallbackVisualMesh->SetStaticMesh(DefaultCylinderMesh.Object);
	}
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
		CheckPhaseTransition();
		UpdateBoss(DeltaTime);
	}
}

void ASethBoss::CheckPhaseTransition()
{
	if (CurrentPhase == ESethBossPhase::Phase1 && HealthComponent)
	{
		const float HealthRatio = HealthComponent->GetHealthPercent();
		if (HealthRatio <= Phase2HPThreshold)
		{
			TriggerPhase2();
		}
	}
}

void ASethBoss::TriggerPhase2()
{
	CurrentPhase = ESethBossPhase::Phase2;
	GetCharacterMovement()->MaxWalkSpeed = 320.f; // Increased speed in Phase 2
	PatternInterval = 2.8f; // Faster pattern interval
	OnPhaseChanged.Broadcast(2);
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
			SelectNextPattern();
		}
		else
		{
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

void ASethBoss::SelectNextPattern()
{
	if (!TargetActor.IsValid()) return;

	if (CurrentPhase == ESethBossPhase::Phase2)
	{
		// Toggle or pick pattern in Phase 2
		ActivePatternIndex = (ActivePatternIndex == 1) ? 2 : 1;
	}
	else
	{
		ActivePatternIndex = 1;
	}

	if (ActivePatternIndex == 1)
	{
		StartPattern01();
	}
	else
	{
		StartPattern02();
	}
}

void ASethBoss::StartPattern01()
{
	if (!TargetActor.IsValid()) return;

	PatternTargetLocation = TargetActor->GetActorLocation();
	PatternTargetLocation.Z = GetActorLocation().Z;
	SetState(ESethBossState::Warning);
}

void ASethBoss::StartPattern02()
{
	if (!TargetActor.IsValid()) return;

	PatternTargetLocation = TargetActor->GetActorLocation();
	BeamDirection = (TargetActor->GetActorLocation() - GetActorLocation()).GetSafeNormal2D();
	SetState(ESethBossState::Warning);
}

void ASethBoss::ExecutePatternAttack()
{
	if (!TargetActor.IsValid()) return;

	AExcelionCharacter* PlayerChar = Cast<AExcelionCharacter>(TargetActor.Get());
	if (!PlayerChar || PlayerChar->IsInvulnerable()) return;

	if (ActivePatternIndex == 1)
	{
		// Pattern 01 Area Blast
		const float Dist = FVector::Dist2D(PlayerChar->GetActorLocation(), PatternTargetLocation);
		if (Dist <= PatternRadius)
		{
			if (UHealthComponent* PlayerHealth = PlayerChar->FindComponentByClass<UHealthComponent>())
			{
				PlayerHealth->ApplyDamage(PatternDamage);
			}
		}
		DrawDebugSphere(GetWorld(), PatternTargetLocation, PatternRadius, 24, FColor::Red, false, 0.5f, 0, 3.f);
	}
	else if (ActivePatternIndex == 2)
	{
		// Pattern 02 Beam Charge
		const FVector BeamEnd = GetActorLocation() + (BeamDirection * PatternRange);
		const FVector PlayerLoc = PlayerChar->GetActorLocation();
		const float DistToLine = FMath::PointDistToSegment(PlayerLoc, GetActorLocation(), BeamEnd);

		if (DistToLine <= 120.f)
		{
			if (UHealthComponent* PlayerHealth = PlayerChar->FindComponentByClass<UHealthComponent>())
			{
				PlayerHealth->ApplyDamage(PatternDamage * 1.25f);
			}
		}
		DrawDebugLine(GetWorld(), GetActorLocation(), BeamEnd, FColor::Red, false, 0.6f, 0, 15.f);
	}
}

void ASethBoss::DrawPatternDebug()
{
	if (ActivePatternIndex == 1)
	{
		DrawDebugSphere(GetWorld(), PatternTargetLocation, PatternRadius, 24, FColor::Yellow, false, -1.f, 0, 2.f);
	}
	else if (ActivePatternIndex == 2)
	{
		const FVector BeamEnd = GetActorLocation() + (BeamDirection * PatternRange);
		DrawDebugLine(GetWorld(), GetActorLocation(), BeamEnd, FColor::Yellow, false, -1.f, 0, 5.f);
	}
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
}
