// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "ExcelionDummyTarget.generated.h"

class UHealthComponent;
class UCapsuleComponent;
class UStaticMeshComponent;

/**
 * Minimal Stationary Dummy Target for U2 Combat Core Verification.
 * Pure target with Capsule Collision (Pawn channel), Visual Fallback Cube, and UHealthComponent (MaxHealth=100).
 */
UCLASS()
class EXCELION_API AExcelionDummyTarget : public AActor
{
	GENERATED_BODY()

public:
	AExcelionDummyTarget();

	virtual void BeginPlay() override;

	UFUNCTION()
	void OnDeath();

	UFUNCTION(BlueprintPure, Category = "Dummy")
	bool IsDead() const;

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Collision")
	UCapsuleComponent* CapsuleComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Visual")
	UStaticMeshComponent* FallbackVisualMesh;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UHealthComponent* HealthComponent;
};
