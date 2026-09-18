// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "ExcelionMechaDataAsset.generated.h"

UENUM(BlueprintType)
enum class EExcelionMechaCategory : uint8
{
	Player,
	Enemy,
	Boss
};

/**
 * Base Mecha Static Configuration Stats
 */
USTRUCT(BlueprintType)
struct EXCELION_API FExcelionMechaBaseStats
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	FName MechaId = "axion-001";

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	FText DisplayName;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	EExcelionMechaCategory Category = EExcelionMechaCategory::Player;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float MaxHP = 100.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float Armor = 10.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float MoveSpeed = 600.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float AttackPower = 25.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float StaggerResist = 50.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
	float Scale = 25.0f; // Height in meters
};

/**
 * Weapon Static Spec
 */
USTRUCT(BlueprintType)
struct EXCELION_API FExcelionWeaponSpec
{
	GENERATED_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
	FName WeaponId;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
	float Damage = 25.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
	float Range = 150.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
	float HeatCost = 10.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
	FName SocketName = "Weapon_R";
};

/**
 * Data Asset SSOT for Excelion Mecha Configuration
 */
UCLASS(BlueprintType)
class EXCELION_API UExcelionMechaDataAsset : public UPrimaryDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Mecha")
	FExcelionMechaBaseStats BaseStats;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Mecha")
	TArray<FExcelionWeaponSpec> WeaponSpecs;
};
