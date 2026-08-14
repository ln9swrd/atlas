// Copyright Excelion. All Rights Reserved.

#include "Game/ExcelionGameMode.h"
#include "Character/ExcelionCharacter.h"
#include "Boss/SethBoss.h"
#include "UI/ExcelionHUDWidget.h"
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
	SetupHUD();
}

void AExcelionGameMode::SetupHUD()
{
	if (HUDWidgetClass && GetWorld())
	{
		APlayerController* PC = UGameplayStatics::GetPlayerController(GetWorld(), 0);
		if (PC)
		{
			ActiveHUDWidget = CreateWidget<UExcelionHUDWidget>(PC, HUDWidgetClass);
			if (ActiveHUDWidget)
			{
				AExcelionCharacter* PlayerChar = Cast<AExcelionCharacter>(PC->GetPawn());
				ASethBoss* BossPawn = Cast<ASethBoss>(UGameplayStatics::GetActorOfClass(GetWorld(), ASethBoss::StaticClass()));

				ActiveHUDWidget->InitializeHUD(PlayerChar, BossPawn);
				ActiveHUDWidget->AddToViewport();
			}
		}
	}
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
	OnGameStateChanged.Broadcast(CurrentGameState);
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
