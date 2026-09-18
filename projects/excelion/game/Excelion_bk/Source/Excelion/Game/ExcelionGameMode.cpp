// Copyright Excelion. All Rights Reserved.

#include "Game/ExcelionGameMode.h"
#include "Character/ExcelionCharacter.h"
#include "Boss/SethBoss.h"
#include "UI/ExcelionHUDWidget.h"
#include "Kismet/GameplayStatics.h"
#include "Engine/World.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/ConstructorHelpers.h"

AExcelionGameMode::AExcelionGameMode()
{
	DefaultPawnClass = AExcelionCharacter::StaticClass();
}

void AExcelionGameMode::BeginPlay()
{
	Super::BeginPlay();
	
	// ===== DEBUG: PIE Visibility Investigation =====
	UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] GameMode BeginPlay - DefaultPawnClass: %s"), 
		DefaultPawnClass ? *DefaultPawnClass->GetName() : TEXT("None"));
	
	if (GetWorld())
	{
		APlayerController* PC = UGameplayStatics::GetPlayerController(GetWorld(), 0);
		if (PC)
		{
			APawn* PossessedPawn = PC->GetPawn();
			UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] PlayerController Possessed Pawn - Class: %s, Name: %s, Location: %s"),
				PossessedPawn ? *PossessedPawn->GetClass()->GetName() : TEXT("None"),
				PossessedPawn ? *PossessedPawn->GetName() : TEXT("None"),
				PossessedPawn ? *PossessedPawn->GetActorLocation().ToString() : TEXT("N/A"));
		}
	}
	// ===== END DEBUG =====
	
	CurrentGameState = EExcelionGameState::Playing;
	SetupHUD();

// ------------------------------------------------------------------
// Minimal Enemy spawn for PIE testing
// ------------------------------------------------------------------
// If an enemy Blueprint exists, spawn a single instance at a default
// location. This keeps the change minimal while allowing combat
// functionalities to be exercised during runtime tests.
// ------------------------------------------------------------------
{
    // Load the Blueprint class at runtime. The path includes the
    // generated class suffix (_C) which points to the actual
    // UClass used by the Blueprint.
    UClass* EnemyBPClass = LoadClass<AActor>(nullptr, TEXT("/Game/Blueprints/BP_ExcelionEnemy.BP_ExcelionEnemy_C"));
    if (EnemyBPClass)
    {
        FActorSpawnParameters SpawnParams;
        // Adjust spawn location to avoid collisions with the player.
        FVector SpawnLocation = FVector(0.f, 0.f, 200.f);
        FRotator SpawnRotation = FRotator::ZeroRotator;
        SpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AdjustIfPossibleButAlwaysSpawn;
        AActor* SpawnedEnemy = GetWorld()->SpawnActor<AActor>(EnemyBPClass, SpawnLocation, SpawnRotation, SpawnParams);
        if (SpawnedEnemy)
        {
            UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] Spawned Enemy: %s at %s"),
                *SpawnedEnemy->GetName(),
                *SpawnedEnemy->GetActorLocation().ToString());
        }
    }
    else
    {
        UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] Failed to load BP_ExcelionEnemy Blueprint class."));
    }
}
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
