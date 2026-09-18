// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "SCoreComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnSCoreChangedSignature, float, CurrentSCore, float, MaxSCore);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnOverheatStateChangedSignature, bool, bIsOverheated);

/**
 * S-Core Energy & Heat Management Component for Excelion Mechas.
 * Handles energy accumulation, consumption, and overheating.
 */
UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class EXCELION_API USCoreComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	USCoreComponent();

	virtual void BeginPlay() override;
	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	// ----- S-Core Energy -----
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core")
	float MaxSCore = 100.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core")
	float CurrentSCore = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core")
	float ChargeRatePerSec = 5.0f;

	// ----- Overheat System -----
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core|Heat")
	float MaxHeat = 100.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core|Heat")
	float CurrentHeat = 0.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core|Heat")
	float HeatDissipationRate = 15.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "S-Core|Heat")
	float OverheatThreshold = 100.0f;

	UPROPERTY(BlueprintReadOnly, Category = "S-Core|Heat")
	bool bIsOverheated = false;

	// ----- Delegates -----
	UPROPERTY(BlueprintAssignable, Category = "S-Core|Events")
	FOnSCoreChangedSignature OnSCoreChanged;

	UPROPERTY(BlueprintAssignable, Category = "S-Core|Events")
	FOnOverheatStateChangedSignature OnOverheatStateChanged;

	// ----- Functions -----
	UFUNCTION(BlueprintCallable, Category = "S-Core")
	void AddSCore(float Amount);

	UFUNCTION(BlueprintCallable, Category = "S-Core")
	bool ConsumeSCore(float Amount);

	UFUNCTION(BlueprintCallable, Category = "S-Core|Heat")
	void AddHeat(float Amount);

	UFUNCTION(BlueprintPure, Category = "S-Core")
	bool CanUseSCoreAbility(float Cost) const;

protected:
	void UpdateDissipation(float DeltaTime);
};
