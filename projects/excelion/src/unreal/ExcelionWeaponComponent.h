// Copyright (c) 2026 Excelion Team. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "ExcelionWeaponComponent.generated.h"

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class UExcelionWeaponComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UExcelionWeaponComponent();

    virtual void BeginPlay() override;

    // Weapon Swapping System
    UFUNCTION(BlueprintCallable, Category = "Weapon")
    bool EquipWeapon(FName WeaponSlot, AActor* WeaponActor);

    // Ammo / Energy Consumption
    UFUNCTION(BlueprintCallable, Category = "Weapon")
    bool ConsumeAmmo(int32 Amount);

    UFUNCTION(BlueprintCallable, Category = "Weapon")
    bool ConsumeEnergy(float EnergyAmount);

protected:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
    int32 CurrentAmmo;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Weapon")
    float CurrentShieldEnergy;
};
