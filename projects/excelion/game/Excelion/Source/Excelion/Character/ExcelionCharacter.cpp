// Copyright Excelion. All Rights Reserved.

#include "Character/ExcelionCharacter.h"
#include "Combat/HealthComponent.h"
#include "Combat/CombatComponent.h"
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/Controller.h"
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"
#include "Engine/LocalPlayer.h"

AExcelionCharacter::AExcelionCharacter()
{
	PrimaryActorTick.bCanEverTick = true;

	// Camera boom
	CameraBoom = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraBoom"));
	CameraBoom->SetupAttachment(RootComponent);
	CameraBoom->TargetArmLength = 400.f;
	CameraBoom->bUsePawnControlRotation = true;
	CameraBoom->bDoCollisionTest = true;

	// Follow camera
	FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
	FollowCamera->SetupAttachment(CameraBoom, USpringArmComponent::SocketName);
	FollowCamera->bUsePawnControlRotation = false;

	// Don't rotate character to camera direction by default
	bUseControllerRotationPitch = false;
	bUseControllerRotationYaw = false;
	bUseControllerRotationRoll = false;

	// Character movement
	GetCharacterMovement()->bOrientRotationToMovement = true;
	GetCharacterMovement()->RotationRate = FRotator(0.f, 500.f, 0.f);
	GetCharacterMovement()->MaxWalkSpeed = 600.f;
	GetCharacterMovement()->JumpZVelocity = 500.f;
	GetCharacterMovement()->AirControl = 0.35f;

	// Components
	HealthComponent = CreateDefaultSubobject<UHealthComponent>(TEXT("HealthComponent"));
	HealthComponent->MaxHealth = 100.f;

	CombatComponent = CreateDefaultSubobject<UCombatComponent>(TEXT("CombatComponent"));
	CombatComponent->AttackDamage = 25.f;
}

void AExcelionCharacter::BeginPlay()
{
	Super::BeginPlay();

	if (HealthComponent)
	{
		HealthComponent->OnDeath.AddDynamic(this, &AExcelionCharacter::OnDeath);
	}

	// Add Input Mapping Context
	if (APlayerController* PC = Cast<APlayerController>(Controller))
	{
		if (UEnhancedInputLocalPlayerSubsystem* Subsystem = ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer()))
		{
			if (DefaultMappingContext)
			{
				Subsystem->AddMappingContext(DefaultMappingContext, 0);
			}
		}
	}
}

void AExcelionCharacter::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

	if (bIsDashing)
	{
		UpdateDash(DeltaTime);
	}

	if (bIsInvulnerable)
	{
		InvulnTimer -= DeltaTime;
		if (InvulnTimer <= 0.f)
		{
			bIsInvulnerable = false;
		}
	}

	if (DashCooldownTimer > 0.f)
	{
		DashCooldownTimer -= DeltaTime;
	}
}

void AExcelionCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	if (UEnhancedInputComponent* EnhancedInput = Cast<UEnhancedInputComponent>(PlayerInputComponent))
	{
		if (MoveAction)
		{
			EnhancedInput->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AExcelionCharacter::Move);
		}
		if (LookAction)
		{
			EnhancedInput->BindAction(LookAction, ETriggerEvent::Triggered, this, &AExcelionCharacter::Look);
		}
		if (AttackAction)
		{
			EnhancedInput->BindAction(AttackAction, ETriggerEvent::Started, this, &AExcelionCharacter::Attack);
		}
		if (DashAction)
		{
			EnhancedInput->BindAction(DashAction, ETriggerEvent::Started, this, &AExcelionCharacter::Dash);
		}
	}
}

void AExcelionCharacter::Move(const FInputActionValue& Value)
{
	if (bIsDashing || IsDead())
	{
		return;
	}

	const FVector2D MovementVector = Value.Get<FVector2D>();

	if (Controller)
	{
		const FRotator Rotation = Controller->GetControlRotation();
		const FRotator YawRotation(0.f, Rotation.Yaw, 0.f);

		const FVector ForwardDir = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::X);
		const FVector RightDir = FRotationMatrix(YawRotation).GetUnitAxis(EAxis::Y);

		AddMovementInput(ForwardDir, MovementVector.Y);
		AddMovementInput(RightDir, MovementVector.X);
	}
}

void AExcelionCharacter::Look(const FInputActionValue& Value)
{
	const FVector2D LookAxis = Value.Get<FVector2D>();
	AddControllerYawInput(LookAxis.X);
	AddControllerPitchInput(LookAxis.Y);
}

void AExcelionCharacter::Attack(const FInputActionValue& Value)
{
	if (IsDead() || bIsDashing)
	{
		return;
	}

	if (CombatComponent)
	{
		CombatComponent->TryAttack();
	}
}

void AExcelionCharacter::Dash(const FInputActionValue& Value)
{
	if (IsDead() || bIsDashing || DashCooldownTimer > 0.f)
	{
		return;
	}
	StartDash();
}

void AExcelionCharacter::StartDash()
{
	bIsDashing = true;
	bIsInvulnerable = true;
	DashTimer = DashDuration;
	InvulnTimer = InvulnerabilityDuration;
	DashCooldownTimer = DashCooldown;

	// Dash direction: input direction or forward
	FVector Velocity = GetVelocity();
	Velocity.Z = 0.f;
	if (Velocity.SizeSquared() > 10.f)
	{
		DashDirection = Velocity.GetSafeNormal();
	}
	else
	{
		DashDirection = GetActorForwardVector();
	}

	// Disable movement during dash
	GetCharacterMovement()->DisableMovement();
}

void AExcelionCharacter::UpdateDash(float DeltaTime)
{
	DashTimer -= DeltaTime;

	const float Alpha = 1.f - (DashTimer / DashDuration);
	const FVector DashOffset = DashDirection * (DashDistance * DeltaTime / DashDuration);
	AddActorWorldOffset(DashOffset, true);

	if (DashTimer <= 0.f)
	{
		EndDash();
	}
}

void AExcelionCharacter::EndDash()
{
	bIsDashing = false;
	GetCharacterMovement()->SetMovementMode(MOVE_Walking);
}

float AExcelionCharacter::TakeDamage(float DamageAmount, FDamageEvent const& DamageEvent, AController* EventInstigator, AActor* DamageCauser)
{
	if (bIsInvulnerable || IsDead())
	{
		return 0.f;
	}

	if (HealthComponent)
	{
		return HealthComponent->ApplyDamage(DamageAmount);
	}
	return 0.f;
}

bool AExcelionCharacter::IsDead() const
{
	return HealthComponent && HealthComponent->IsDead();
}

void AExcelionCharacter::OnDeath()
{
	// Disable input and movement on death
	GetCharacterMovement()->DisableMovement();
	DisableInput(Cast<APlayerController>(Controller));

	// TODO: Notify GameMode for Defeat state (Phase 6)
}
