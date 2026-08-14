// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "CombatComponent.generated.h"

/**
 * Minimal combat component for Prototype v0.1.
 * Handles attack state, duration, and simple sphere-trace hit detection.
 */
UCLASS(ClassGroup = (Custom), meta = (BlueprintSpawnableComponent))
class EXCELION_API UCombatComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UCombatComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

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

	/** Total attack duration before returning to idle. */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float AttackDuration = 0.4f;

	/** Time after attack start when damage is applied. */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float DamageWindowStart = 0.15f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	TArray<TEnumAsByte<EObjectTypeQuery>> AttackObjectTypes;

	UFUNCTION(BlueprintCallable, Category = "Combat")
	void PerformHitDetection();

protected:
	bool bIsAttacking = false;
	float AttackTimer = 0.f;
	bool bDamageAppliedThisAttack = false;

	void EndAttack();
};
