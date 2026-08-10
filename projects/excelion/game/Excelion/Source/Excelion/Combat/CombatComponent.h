// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "CombatComponent.generated.h"

/**
 * Minimal combat component for Prototype v0.1.
 * Handles attack state, cooldown, and simple sphere-trace hit detection.
 */
UCLASS(ClassGroup = (Custom), meta = (BlueprintSpawnableComponent))
class EXCELION_API UCombatComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UCombatComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	/** Attempt to perform an attack. Returns true if attack started. */
	UFUNCTION(BlueprintCallable, Category = "Combat")
	bool TryAttack();

	UFUNCTION(BlueprintPure, Category = "Combat")
	bool IsAttacking() const { return bIsAttacking; }

	UFUNCTION(BlueprintPure, Category = "Combat")
	bool CanAttack() const;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackDamage = 20.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackRange = 150.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackRadius = 60.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackCooldown = 0.4f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackCooldownTime = 0.15f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackCooldownEndTime = 0.35f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	TArray<TEnumAsByte<EObjectTypeQuery>> AttackObjectTypes;

protected:
	bool bIsAttacking = false;
	float AttackTimer = 0.f;
	bool bDamageAppliedThisAttack = false;

	void PerformHitDetection();
	void EndAttack();
};
