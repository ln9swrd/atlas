// Copyright (c) 2026 Excelion Team. All Rights Reserved.

#include "ExcelionPhantomMech.h"

AExcelionPhantomMech::AExcelionPhantomMech()
{
    PrimaryActorTick.bCanEverTick = true;
    bIsStealthActive = false;
    CloakEnergy = 100.0f;

    MechSkeletalMesh = GetMesh();
}

void AExcelionPhantomMech::BeginPlay()
{
    Super::BeginPlay();
}

void AExcelionPhantomMech::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);

    if (bIsStealthActive)
    {
        CloakEnergy -= DeltaTime * 10.0f;
        if (CloakEnergy <= 0.0f)
        {
            ToggleStealthCloak(false);
        }
    }
}

void AExcelionPhantomMech::ToggleStealthCloak(bool bEnable)
{
    bIsStealthActive = bEnable;
}

bool AExcelionPhantomMech::AttachWeaponToSocket(FName SocketName, AActor* WeaponActor)
{
    if (!WeaponActor || !MechSkeletalMesh)
    {
        return false;
    }
    return WeaponActor->AttachToComponent(MechSkeletalMesh, FAttachmentTransformRules::SnapToTargetNotIncludingScale, SocketName);
}
