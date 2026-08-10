// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "SethBoss.generated.h"

class UHealthComponent;

UENUM(BlueprintType)
enum class ESethBossState : uint8
{
	Idle,
	Combat,
	Warning,
	Attack,
	Recovery,
	Death
};

/**
 * Seth Boss — Prototype v0.1
 * Minimal state machine + Pattern 01 (Warning -> Delay -> Attack Area -> Damage -> Recovery).
 */
UCLASS()
class EXCELION_API ASethBoss : public ACharacter
{
	GENERATED_BODY()

public:
	ASethBoss();

	virtual void Tick(float DeltaTime) override;
	virtual void BeginPlay() override;

	UFUNCTION()
	void OnDeath();

	UFUNCTION(BlueprintPure, Category = "Boss")
	bool IsDead() const;

	UFUNCTION(BlueprintPure, Category = "Boss")
	ESethBossState GetBossState() const { return CurrentState; }

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UHealthComponent* HealthComponent;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float PatternInterval = 4.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float WarningDuration = 1.2f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float AttackDuration = 0.6f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float RecoveryDuration = 1.5f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float PatternDamage = 40.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float PatternRadius = 300.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Pattern")
	float PatternRange = 800.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss")
	float DetectionRange = 2000.f;

	ESethBossState CurrentState = ESethBossState::Idle;
	float StateTimer = 0.f;
	FVector PatternTargetLocation = FVector::ZeroVector;
	TWeakObjectPtr<AActor> TargetActor;

	void UpdateBoss(float DeltaTime);
	void SetState(ESethBossState NewState);
	AActor* FindPlayer() const;

	/** Pattern 01 implementation. */
	void StartPattern01();
	void ExecutePatternWarning();
	void ExecutePatternAttack();
	void DrawPatternDebug();
};
