// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "ExcelionHUDWidget.generated.h"

class AExcelionCharacter;
class ASethBoss;

/**
 * Base UMG HUD Widget for Excelion Prototype
 * Binds Player HP, S-Core, Heat, and Boss HP for UMG Layout.
 */
UCLASS()
class EXCELION_API UExcelionHUDWidget : public UUserWidget
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, Category = "HUD")
	void InitializeHUD(AExcelionCharacter* InPlayerCharacter, ASethBoss* InBossActor);

	UFUNCTION(BlueprintPure, Category = "HUD|Player")
	float GetPlayerHealthPercent() const;

	UFUNCTION(BlueprintPure, Category = "HUD|Player")
	float GetPlayerSCorePercent() const;

	UFUNCTION(BlueprintPure, Category = "HUD|Player")
	float GetPlayerHeatPercent() const;

	UFUNCTION(BlueprintPure, Category = "HUD|Player")
	bool IsPlayerOverheated() const;

	UFUNCTION(BlueprintPure, Category = "HUD|Boss")
	float GetBossHealthPercent() const;

	UFUNCTION(BlueprintPure, Category = "HUD|Boss")
	bool IsBossActive() const;

protected:
	UPROPERTY(BlueprintReadOnly, Category = "HUD|References")
	TWeakObjectPtr<AExcelionCharacter> PlayerCharacter;

	UPROPERTY(BlueprintReadOnly, Category = "HUD|References")
	TWeakObjectPtr<ASethBoss> BossActor;
};
