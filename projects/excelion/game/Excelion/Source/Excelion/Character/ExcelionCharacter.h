// Copyright Excelion. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "InputActionValue.h"
#include "ExcelionCharacter.generated.h"

class USpringArmComponent;
class UCameraComponent;
class UInputMappingContext;
class UInputAction;
class UHealthComponent;
class UCombatComponent;
class USCoreComponent;
class UExcelionMechaDataAsset;

/**
 * AXION Player Character — Prototype v0.1
 * Movement, Camera, Attack, Dash, Health, S-Core.
 */
UCLASS()
class EXCELION_API AExcelionCharacter : public ACharacter
{
	GENERATED_BODY()

public:
	AExcelionCharacter();

	virtual void Tick(float DeltaTime) override;
	virtual void SetupPlayerInputComponent(class UInputComponent* PlayerInputComponent) override;
	virtual void PostInitializeComponents() override;
	virtual void BeginPlay() override;

	/** Applies stats from MechaDataAsset SSOT to runtime components. */
	void ApplyMechaDataAsset();

	/** Called when character dies. */
	UFUNCTION()
	void OnDeath();

	UFUNCTION(BlueprintPure, Category = "AXION|Health")
	bool IsDead() const;

	UFUNCTION(BlueprintPure, Category = "AXION|Dash")
	bool IsDashing() const { return bIsDashing; }

	UFUNCTION(BlueprintPure, Category = "AXION|Dash")
	bool IsInvulnerable() const { return bIsInvulnerable; }

	UFUNCTION(BlueprintPure, Category = "AXION|Combat")
	USCoreComponent* GetSCoreComponent() const { return SCoreComponent; }

protected:
	// ----- Camera -----
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
	USpringArmComponent* CameraBoom;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Camera")
	UCameraComponent* FollowCamera;

	// ----- Components -----
	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UHealthComponent* HealthComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	UCombatComponent* CombatComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Combat")
	USCoreComponent* SCoreComponent;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Visual")
	UStaticMeshComponent* FallbackVisualMesh;

	// ----- Enhanced Input (assets to be created in Editor) -----
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
	UInputMappingContext* DefaultMappingContext;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
	UInputAction* MoveAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
	UInputAction* LookAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
	UInputAction* AttackAction;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Input")
	UInputAction* DashAction;

	// ----- Dash -----
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Dash")
	float DashDistance = 600.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Dash")
	float DashDuration = 0.20f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Dash")
	float DashCooldown = 1.0f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Dash")
	float InvulnerabilityDuration = 0.25f;

	bool bIsDashing = false;
	bool bIsInvulnerable = false;
	float DashTimer = 0.f;
	float InvulnTimer = 0.f;
	float DashCooldownTimer = 0.f;
	FVector DashDirection = FVector::ZeroVector;

	// ----- Input Handlers -----
	void Move(const FInputActionValue& Value);
	void Look(const FInputActionValue& Value);
	void Attack(const FInputActionValue& Value);
	void Dash(const FInputActionValue& Value);

	void StartDash();
	void UpdateDash(float DeltaTime);
	void EndDash();

	/** Override damage reception to respect invulnerability. */
	virtual float TakeDamage(float DamageAmount, struct FDamageEvent const& DamageEvent, class AController* EventInstigator, AActor* DamageCauser) override;
};
