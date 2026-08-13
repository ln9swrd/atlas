// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "ExcelionGameMode.generated.h"

UENUM(BlueprintType)
enum class EExcelionGameState : uint8
{
	Playing,
	Victory,
	Defeat
};

/**
 * Minimal GameMode for AXION Prototype v0.1.
 * Provides Victory / Defeat / Retry hooks.
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

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Game")
	EExcelionGameState CurrentGameState = EExcelionGameState::Playing;

	void SetGameState(EExcelionGameState NewState);
	void HandleVictory();
	void HandleDefeat();
};
