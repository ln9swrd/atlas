// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "MadnessComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnMadnessLevelChangedSignature, int32, NewLevel, float, CurrentMadness);

/**
 * Madness System Component for AXION (BRAVE-001).
 * Handles Madness accumulation (0~5 levels), damage multiplier, and risk output.
 */
UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class EXCELION_API UMadnessComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UMadnessComponent();

	virtual void BeginPlay() override;

	// ----- Parameters -----
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Madness")
	float MaxMadness = 100.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Madness")
	float CurrentMadness = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Madness")
	int32 MaxMadnessLevel = 5;

	UPROPERTY(BlueprintReadOnly, Category = "Madness")
	int32 CurrentMadnessLevel = 0;

	// ----- Delegates -----
	UPROPERTY(BlueprintAssignable, Category = "Madness|Events")
	FOnMadnessLevelChangedSignature OnMadnessLevelChanged;

	// ----- Functions -----
	UFUNCTION(BlueprintCallable, Category = "Madness")
	void AddMadness(float Amount);

	UFUNCTION(BlueprintCallable, Category = "Madness")
	void ReduceMadness(float Amount);

	UFUNCTION(BlueprintPure, Category = "Madness")
	float GetDamageMultiplier() const;

	UFUNCTION(BlueprintPure, Category = "Madness")
	float GetIncomingDamagePenalty() const;

protected:
	void RecalculateLevel();
};
