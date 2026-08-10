// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "AI/ExcelionEnemy.h"
#include "SpeedEnemy.generated.h"

/**
 * Speed-type enemy: fast movement, low HP, weak attack, short interval.
 */
UCLASS()
class EXCELION_API ASpeedEnemy : public AExcelionEnemy
{
	GENERATED_BODY()

public:
	ASpeedEnemy();
};
