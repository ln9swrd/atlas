// Copyright Excelion. All Rights Reserved.

#include "Game/ExcelionGameMode.h"
#include "Character/ExcelionCharacter.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"

AExcelionGameMode::AExcelionGameMode()
{
	DefaultPawnClass = AExcelionCharacter::StaticClass();
}

void AExcelionGameMode::BeginPlay()
{
	Super::BeginPlay();
	CurrentGameState = EExcelionGameState::Playing;
}

void AExcelionGameMode::NotifyPlayerDeath()
{
	if (CurrentGameState != EExcelionGameState::Playing)
	{
		return;
	}
	HandleDefeat();
}

void AExcelionGameMode::NotifyBossDeath()
{
	if (CurrentGameState != EExcelionGameState::Playing)
	{
		return;
	}
	HandleVictory();
}

void AExcelionGameMode::Retry()
{
	UGameplayStatics::OpenLevel(this, FName(*GetWorld()->GetName()));
}

void AExcelionGameMode::SetGameState(EExcelionGameState NewState)
{
	CurrentGameState = NewState;
}

void AExcelionGameMode::HandleVictory()
{
	SetGameState(EExcelionGameState::Victory);
	UE_LOG(LogTemp, Warning, TEXT("[Excelion] VICTORY — Seth defeated."));
}

void AExcelionGameMode::HandleDefeat()
{
	SetGameState(EExcelionGameState::Defeat);
	UE_LOG(LogTemp, Warning, TEXT("[Excelion] DEFEAT — AXION down. Call Retry() to restart."));
}
