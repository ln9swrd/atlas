// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"

UENUM(BlueprintType)
enum class EExcelionGameState : uint8
{
	Playing,
	Victory,
	Defeat
};

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnExcelionGameStateChangedSignature, EExcelionGameState, NewState);

#include "ExcelionGameMode.generated.h"

/**
 * GameMode for Excelion Prototype.
 * Handles HUD Spawning, Victory / Defeat state transition, and Retry.
 */
UCLASS()
class EXCELION_API AExcelionGameMode : public AGameModeBase
{
	GENERATED_BODY()

public:
	AExcelionGameMode();

	virtual void BeginPlay() override;

	UFUNCTION(BlueprintCallable, Category = "Game")
	void NotifyPlayerDeath();

	UFUNCTION(BlueprintCallable, Category = "Game")
	void NotifyBossDeath();

	UFUNCTION(BlueprintCallable, Category = "Game")
	void Retry();

	UFUNCTION(BlueprintPure, Category = "Game")
	EExcelionGameState GetExcelionGameState() const { return CurrentGameState; }

	UPROPERTY(BlueprintAssignable, Category = "Game|Events")
	FOnExcelionGameStateChangedSignature OnGameStateChanged;

protected:
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "UI")
	TSubclassOf<class UExcelionHUDWidget> HUDWidgetClass;

	UPROPERTY(BlueprintReadOnly, Category = "UI")
	class UExcelionHUDWidget* ActiveHUDWidget;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Game")
	EExcelionGameState CurrentGameState = EExcelionGameState::Playing;

	void SetGameState(EExcelionGameState NewState);
	void HandleVictory();
	void HandleDefeat();
	void SetupHUD();
};
