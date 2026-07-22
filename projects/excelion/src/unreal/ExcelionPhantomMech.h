// Copyright (c) 2026 Excelion Team. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "ExcelionPhantomMech.generated.h"

UCLASS(Config=Game)
class AExcelionPhantomMech : public ACharacter
{
    GENERATED_BODY()

public:
    AExcelionPhantomMech();

    virtual void BeginPlay() override;
    virtual void Tick(float DeltaTime) override;

    // Stealth Cloaking Component Toggle
    UFUNCTION(BlueprintCallable, Category = "Stealth")
    void ToggleStealthCloak(bool bEnable);

    // Socket Weapon Mounting
    UFUNCTION(BlueprintCallable, Category = "Weapon")
    bool AttachWeaponToSocket(FName SocketName, AActor* WeaponActor);

protected:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stealth")
    bool bIsStealthActive;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stealth")
    float CloakEnergy;

    UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Mesh")
    USkeletalMeshComponent* MechSkeletalMesh;
};
