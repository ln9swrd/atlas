// Copyright Excelion. All Rights Reserved.

#include "UI/ExcelionHUDWidget.h"
#include "Character/ExcelionCharacter.h"
#include "Boss/SethBoss.h"
#include "Combat/HealthComponent.h"
#include "Combat/SCoreComponent.h"

void UExcelionHUDWidget::InitializeHUD(AExcelionCharacter* InPlayerCharacter, ASethBoss* InBossActor)
{
	PlayerCharacter = InPlayerCharacter;
	BossActor = InBossActor;
}

float UExcelionHUDWidget::GetPlayerHealthPercent() const
{
	if (PlayerCharacter.IsValid())
	{
		if (UHealthComponent* HealthComp = PlayerCharacter->FindComponentByClass<UHealthComponent>())
		{
			return HealthComp->GetHealthPercent();
		}
	}
	return 0.0f;
}

float UExcelionHUDWidget::GetPlayerSCorePercent() const
{
	if (PlayerCharacter.IsValid())
	{
		if (USCoreComponent* SCoreComp = PlayerCharacter->GetSCoreComponent())
		{
			return SCoreComp->MaxSCore > 0.f ? SCoreComp->CurrentSCore / SCoreComp->MaxSCore : 0.0f;
		}
	}
	return 0.0f;
}

float UExcelionHUDWidget::GetPlayerHeatPercent() const
{
	if (PlayerCharacter.IsValid())
	{
		if (USCoreComponent* SCoreComp = PlayerCharacter->GetSCoreComponent())
		{
			return SCoreComp->MaxHeat > 0.f ? SCoreComp->CurrentHeat / SCoreComp->MaxHeat : 0.0f;
		}
	}
	return 0.0f;
}

bool UExcelionHUDWidget::IsPlayerOverheated() const
{
	if (PlayerCharacter.IsValid())
	{
		if (USCoreComponent* SCoreComp = PlayerCharacter->GetSCoreComponent())
		{
			return SCoreComp->bIsOverheated;
		}
	}
	return false;
}

float UExcelionHUDWidget::GetBossHealthPercent() const
{
	if (BossActor.IsValid())
	{
		if (UHealthComponent* BossHealth = BossActor->FindComponentByClass<UHealthComponent>())
		{
			return BossHealth->GetHealthPercent();
		}
	}
	return 0.0f;
}

bool UExcelionHUDWidget::IsBossActive() const
{
	return BossActor.IsValid() && !BossActor->IsDead();
}
