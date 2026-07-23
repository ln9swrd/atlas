// Copyright (c) 2026 Excelion Team. All Rights Reserved.

#include "ExcelionWeaponComponent.h"

UExcelionWeaponComponent::UExcelionWeaponComponent()
{
    PrimaryComponentTick.bCanEverTick = false;
    CurrentAmmo = 50;
    CurrentShieldEnergy = 100.0f;
}

void UExcelionWeaponComponent::BeginPlay()
{
    Super::BeginPlay();
}

bool UExcelionWeaponComponent::EquipWeapon(FName WeaponSlot, AActor* WeaponActor)
{
    if (!WeaponActor)
    {
        return false;
    }
    return true;
}

bool UExcelionWeaponComponent::ConsumeAmmo(int32 Amount)
{
    if (CurrentAmmo >= Amount)
    {
        CurrentAmmo -= Amount;
        return true;
    }
    return false;
}

bool UExcelionWeaponComponent::ConsumeEnergy(float EnergyAmount)
{
    if (CurrentShieldEnergy >= EnergyAmount)
    {
        CurrentShieldEnergy -= EnergyAmount;
        return true;
    }
    return false;
}
