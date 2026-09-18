// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"

UENUM(BlueprintType)
enum class EEnemyAIState : uint8
{
	Idle,
	Chase,
	Attack,
	Recovery,
	Dead
};

#include "ExcelionEnemy.generated.h"

class UHealthComponent;
class UCombatComponent;

/**
 * Base Enemy class for Prototype v0.1.
 * Minimal AI: Idle -> Chase -> Attack -> Recovery.
 */
UCLASS()
class EXCELION_API AExcelionEnemy : public ACharacter
{
	GENERATED_BODY()

public:
	AExcelionEnemy();

	virtual void Tick(float DeltaTime) override;
	virtual void BeginPlay() override;

	UFUNCTION()
	void OnDeath();

	UFUNCTION(BlueprintPure, Category = "Enemy")
	bool IsDead() const;

	UFUNCTION(BlueprintPure, Category = "Enemy")
	EEnemyAIState GetAIState() const { return CurrentState; }

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UHealthComponent* HealthComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UCombatComponent* CombatComponent;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "AI")
	float DetectionRange = 1500.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "AI")
	float AttackRange = 180.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "AI")
	float AttackInterval = 1.5f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "AI")
	float RecoveryTime = 0.8f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "AI")
	float MoveSpeed = 400.f;

	EEnemyAIState CurrentState = EEnemyAIState::Idle;
	float StateTimer = 0.f;
	TWeakObjectPtr<AActor> TargetActor;

	void UpdateAI(float DeltaTime);
	void SetState(EEnemyAIState NewState);
	AActor* FindPlayer() const;
	void ChaseTarget(float DeltaTime);
	void PerformAttack();
};
