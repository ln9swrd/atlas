// Copyright Excelion. All Rights Reserved.

#include "Combat/CombatComponent.h"
#include "Combat/HealthComponent.h"
#include "GameFramework/Actor.h"
#include "Engine/World.h"
#include "DrawDebugHelpers.h"
#include "Kismet/KismetSystemLibrary.h"

UCombatComponent::UCombatComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
	PrimaryComponentTick.bStartWithTickEnabled = false;
}

void UCombatComponent::BeginPlay()
{
	Super::BeginPlay();

	if (AttackObjectTypes.Num() == 0)
	{
		AttackObjectTypes.Add(UEngineTypes::ConvertToObjectType(ECC_Pawn));
	}
}

void UCombatComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	if (!bIsAttacking)
	{
		return;
	}

	AttackTimer += DeltaTime;

	if (!bDamageAppliedThisAttack && AttackTimer >= DamageWindowStart)
	{
		PerformHitDetection();
		bDamageAppliedThisAttack = true;
	}

	if (AttackTimer >= AttackDuration)
	{
		EndAttack();
	}
}

bool UCombatComponent::CanAttack() const
{
	return !bIsAttacking;
}

bool UCombatComponent::TryAttack()
{
	if (!CanAttack())
	{
		return false;
	}

	bIsAttacking = true;
	AttackTimer = 0.f;
	bDamageAppliedThisAttack = false;
	SetComponentTickEnabled(true);
	return true;
}

void UCombatComponent::PerformHitDetection()
{
	AActor* Owner = GetOwner();
	if (!Owner)
	{
		return;
	}

	const FVector Start = Owner->GetActorLocation();
	const FVector Forward = Owner->GetActorForwardVector();
	const FVector End = Start + Forward * AttackRange;

	TArray<AActor*> ActorsToIgnore;
	ActorsToIgnore.Add(Owner);

	TArray<FHitResult> HitResults;
	const bool bHit = UKismetSystemLibrary::SphereTraceMultiForObjects(
		GetWorld(),
		Start,
		End,
		AttackRadius,
		AttackObjectTypes,
		false,
		ActorsToIgnore,
		EDrawDebugTrace::ForDuration,
		HitResults,
		true,
		FLinearColor::Red,
		FLinearColor::Green,
		1.0f
	);

	if (!bHit)
	{
		return;
	}

	for (const FHitResult& Hit : HitResults)
	{
		AActor* HitActor = Hit.GetActor();
		if (!HitActor || HitActor == Owner)
		{
			continue;
		}

		UHealthComponent* TargetHealth = HitActor->FindComponentByClass<UHealthComponent>();
		if (TargetHealth && !TargetHealth->IsDead())
		{
			TargetHealth->ApplyDamage(AttackDamage);
		}
	}
}

void UCombatComponent::EndAttack()
{
	bIsAttacking = false;
	AttackTimer = 0.f;
	bDamageAppliedThisAttack = false;
	SetComponentTickEnabled(false);
}
