// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "SethBoss.generated.h"

class UHealthComponent;

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnBossPhaseChangedSignature, int32, NewPhase);

UENUM(BlueprintType)
enum class ESethBossPhase : uint8
{
	Phase1,
	Phase2Transition,
	Phase2
};

/**
 * Seth Boss — Vertical Slice Boss (UE 5.4)
 * Multi-phase state machine (Phase 1 -> Phase 2) & Pattern 01 (Area Blast) / Pattern 02 (Beam Charge).
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

	UFUNCTION(BlueprintPure, Category = "Boss")
	ESethBossPhase GetBossPhase() const { return CurrentPhase; }

	UPROPERTY(BlueprintAssignable, Category = "Boss|Events")
	FOnBossPhaseChangedSignature OnPhaseChanged;

protected:
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UHealthComponent* HealthComponent;

	// ----- Phase Control -----
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boss|Phase")
	float Phase2HPThreshold = 0.5f; // Phase 2 triggers at 50% HP

	UPROPERTY(BlueprintReadOnly, Category = "Boss|Phase")
	ESethBossPhase CurrentPhase = ESethBossPhase::Phase1;

	// ----- Pattern Parameters -----
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

	int32 ActivePatternIndex = 1; // 1 = Area Blast, 2 = Beam Charge
	ESethBossState CurrentState = ESethBossState::Idle;
	float StateTimer = 0.f;
	FVector PatternTargetLocation = FVector::ZeroVector;
	FVector BeamDirection = FVector::ForwardVector;
	TWeakObjectPtr<AActor> TargetActor;

	void UpdateBoss(float DeltaTime);
	void SetState(ESethBossState NewState);
	void CheckPhaseTransition();
	void TriggerPhase2();
	AActor* FindPlayer() const;

	/** Pattern implementations. */
	void SelectNextPattern();
	void StartPattern01(); // Area Blast
	void StartPattern02(); // Beam Charge (Phase 2)
	void ExecutePatternAttack();
	void DrawPatternDebug();
};
