// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "AI/ExcelionEnemy.h"
#include "PowerEnemy.generated.h"

/**
 * Power-type enemy: slow movement, high HP, strong attack, long interval.
 */
UCLASS()
class EXCELION_API APowerEnemy : public AExcelionEnemy
{
	GENERATED_BODY()

public:
	APowerEnemy();
};
