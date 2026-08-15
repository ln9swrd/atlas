// Copyright Excelion. All Rights Reserved.

#include "Character/ExcelionCharacter.h"
#include "Data/ExcelionMechaDataAsset.h"
#include "Combat/HealthComponent.h"
#include "Combat/CombatComponent.h"
#include "Combat/SCoreComponent.h"
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
	GetCharacterMovement()->JumpZVelocity = 500.f;
	GetCharacterMovement()->AirControl = 0.35f;

	// Mesh default offset inside capsule
	GetMesh()->SetRelativeLocation(FVector(0.f, 0.f, -90.f));
	GetMesh()->SetRelativeRotation(FRotator(0.f, -90.f, 0.f));

	// Components
	HealthComponent = CreateDefaultSubobject<UHealthComponent>(TEXT("HealthComponent"));
	CombatComponent = CreateDefaultSubobject<UCombatComponent>(TEXT("CombatComponent"));
	SCoreComponent = CreateDefaultSubobject<USCoreComponent>(TEXT("SCoreComponent"));

	// Fallback visual mesh so character is immediately visible in Play without manual asset setup
	FallbackVisualMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("FallbackVisualMesh"));
	FallbackVisualMesh->SetupAttachment(RootComponent);
	FallbackVisualMesh->SetRelativeScale3D(FVector(0.5f, 0.5f, 1.8f));
	FallbackVisualMesh->SetVisibility(true, false);
	FallbackVisualMesh->SetHiddenInGame(false);

	static ConstructorHelpers::FObjectFinder<UStaticMesh> DefaultCubeMesh(TEXT("/Engine/BasicShapes/Cube.Cube"));
	if (DefaultCubeMesh.Succeeded())
	{
		FallbackVisualMesh->SetStaticMesh(DefaultCubeMesh.Object);
	}

	// CRITICAL: Create INPUT ACTIONS AND CONTEXT IN CODE ONLY.
	// DO NOT load from /Game/Input/IMC_Default - that can conflict and cause wrong mappings.
	// This ensures we have predictable input setup at runtime.
	
	DefaultMappingContext = NewObject<UInputMappingContext>(this, TEXT("DefaultMappingContext"));
	UE_LOG(LogTemp, Warning, TEXT("[INIT] Created DefaultMappingContext: %s"), DefaultMappingContext ? TEXT("SUCCESS") : TEXT("FAILED"));
	
	MoveAction = NewObject<UInputAction>(this, TEXT("MoveAction"));
	MoveAction->ValueType = EInputActionValueType::Axis2D;
	UE_LOG(LogTemp, Warning, TEXT("[INIT] Created MoveAction (Axis2D): %s"), MoveAction ? TEXT("SUCCESS") : TEXT("FAILED"));
	
	LookAction = NewObject<UInputAction>(this, TEXT("LookAction"));
	LookAction->ValueType = EInputActionValueType::Axis2D;
	UE_LOG(LogTemp, Warning, TEXT("[INIT] Created LookAction (Axis2D): %s"), LookAction ? TEXT("SUCCESS") : TEXT("FAILED"));
	
	AttackAction = NewObject<UInputAction>(this, TEXT("AttackAction"));
	AttackAction->ValueType = EInputActionValueType::Boolean;
	UE_LOG(LogTemp, Warning, TEXT("[INIT] Created AttackAction (Boolean): %s"), AttackAction ? TEXT("SUCCESS") : TEXT("FAILED"));
	
	DashAction = NewObject<UInputAction>(this, TEXT("DashAction"));
	DashAction->ValueType = EInputActionValueType::Boolean;
	UE_LOG(LogTemp, Warning, TEXT("[INIT] Created DashAction (Boolean): %s"), DashAction ? TEXT("SUCCESS") : TEXT("FAILED"));

	// Map keys to actions via the input mapping context
	if (DefaultMappingContext && MoveAction)
	{
		// Movement: WASD → MoveAction (Axis2D)
		// Each key needs to be mapped individually
		DefaultMappingContext->MapKey(MoveAction, EKeys::W);
		DefaultMappingContext->MapKey(MoveAction, EKeys::A);
		DefaultMappingContext->MapKey(MoveAction, EKeys::S);
		DefaultMappingContext->MapKey(MoveAction, EKeys::D);
		UE_LOG(LogTemp, Warning, TEXT("[INIT] MoveAction mapped: W/A/S/D - Total mappings in IMC: %d"), DefaultMappingContext->GetMappings().Num());
	}
	
	if (DefaultMappingContext && LookAction)
	{
		// Camera: Mouse → LookAction (Axis2D)
		DefaultMappingContext->MapKey(LookAction, EKeys::MouseX);
		DefaultMappingContext->MapKey(LookAction, EKeys::MouseY);
		UE_LOG(LogTemp, Warning, TEXT("[INIT] LookAction mapped: MouseX/MouseY - Total mappings in IMC: %d"), DefaultMappingContext->GetMappings().Num());
	}
	
	if (DefaultMappingContext && AttackAction)
	{
		// Attack: LMB → AttackAction
		DefaultMappingContext->MapKey(AttackAction, EKeys::LeftMouseButton);
		UE_LOG(LogTemp, Warning, TEXT("[INIT] AttackAction mapped: LeftMouseButton - Total mappings in IMC: %d"), DefaultMappingContext->GetMappings().Num());
	}
	
	if (DefaultMappingContext && DashAction)
	{
		// Dash: Shift → DashAction
		DefaultMappingContext->MapKey(DashAction, EKeys::LeftShift);
		UE_LOG(LogTemp, Warning, TEXT("[INIT] DashAction mapped: LeftShift - Total mappings in IMC: %d"), DefaultMappingContext->GetMappings().Num());
	}

	UE_LOG(LogTemp, Warning, TEXT("[EXCELION INIT] Input context created in code - IMC: %s, Move: %s, Look: %s (Final IMC Mapping Count: %d)"),
		DefaultMappingContext ? *DefaultMappingContext->GetName() : TEXT("FAILED"),
		MoveAction ? *MoveAction->GetName() : TEXT("FAILED"),
		LookAction ? *LookAction->GetName() : TEXT("FAILED"),
		DefaultMappingContext ? DefaultMappingContext->GetMappings().Num() : 0);
}

void AExcelionCharacter::PostInitializeComponents()
{
	Super::PostInitializeComponents();

	UE_LOG(LogTemp, Warning, TEXT("========== [EXCELION CHARACTER] PostInitializeComponents =========="));
	UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] Character Spawned - Name: %s, Location: %s"), *GetName(), *GetActorLocation().ToString());
	UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] GetMesh Valid: %d, FallbackVisualMesh Valid: %d"), 
		GetMesh() != nullptr, FallbackVisualMesh != nullptr);
	
	if (FallbackVisualMesh)
	{
		FallbackVisualMesh->SetVisibility(true, false);
		FallbackVisualMesh->SetHiddenInGame(false);
		UE_LOG(LogTemp, Warning, TEXT("[AXION PIE DEBUG] FallbackMesh visible forced"));
	}
	UE_LOG(LogTemp, Warning, TEXT("========== [EXCELION CHARACTER] PostInitializeComponents END =========="));

	ApplyMechaDataAsset();
}

void AExcelionCharacter::ApplyMechaDataAsset(UExcelionMechaDataAsset* InMechaDataAsset)
{
	UExcelionMechaDataAsset* TargetData = InMechaDataAsset ? InMechaDataAsset : MechaDataAsset;

	if (!TargetData)
	{
		UE_LOG(LogTemp, Warning, TEXT("[AExcelionCharacter] MechaDataAsset is NULL on %s! Runtime stats not set from SSOT."), *GetName());
		return;
	}

	const FExcelionMechaBaseStats& Stats = TargetData->BaseStats;

	if (HealthComponent)
	{
		HealthComponent->MaxHealth = Stats.MaxHP;
		HealthComponent->ResetHealth();
	}

	if (CombatComponent)
	{
		CombatComponent->AttackDamage = Stats.AttackPower;
	}

	if (UCharacterMovementComponent* MoveComp = GetCharacterMovement())
	{
		MoveComp->MaxWalkSpeed = Stats.MoveSpeed;
	}

	UE_LOG(LogTemp, Log, TEXT("[AExcelionCharacter] Applied MechaDataAsset (%s) to %s: MaxHP=%.1f, AttackPower=%.1f, MoveSpeed=%.1f"),
		*TargetData->GetName(), *GetName(), Stats.MaxHP, Stats.AttackPower, Stats.MoveSpeed);
}

void AExcelionCharacter::BeginPlay()
{
	UE_LOG(LogTemp, Error, TEXT("========== [CRITICAL] AExcelionCharacter::BeginPlay STARTED =========="));
	Super::BeginPlay();

	UE_LOG(LogTemp, Warning, TEXT("[INIT] BeginPlay - Name: %s, Controller: %s"), 
		*GetName(), Controller ? *Controller->GetName() : TEXT("NULL"));

	// ===== Movement Component Verification =====
	if (UCharacterMovementComponent* MovementComp = GetCharacterMovement())
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] CharacterMovement initialized - MaxWalkSpeed=%.1f, MovementMode=%d"), 
			MovementComp->MaxWalkSpeed, (int32)MovementComp->MovementMode);
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("[MOVE] ERROR: CharacterMovement component is NULL!"));
	}
	
	if (HealthComponent)
	{
		HealthComponent->OnDeath.AddDynamic(this, &AExcelionCharacter::OnDeath);
	}

	// Note: Enhanced Input Mapping Context registration.
	// CRITICAL: We MUST remove all existing contexts first, otherwise IMC_Default will override our runtime context.
	if (APlayerController* PC = Cast<APlayerController>(Controller))
	{
		UE_LOG(LogTemp, Warning, TEXT("[INIT] PlayerController found - clearing old contexts and registering new one"));
		if (UEnhancedInputLocalPlayerSubsystem* Subsystem = ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(PC->GetLocalPlayer()))
		{
			// CRITICAL: Remove ALL existing mapping contexts to prevent conflicts
			Subsystem->ClearAllMappings();
			UE_LOG(LogTemp, Warning, TEXT("[INPUT] Cleared all existing mapping contexts"));
			
			if (DefaultMappingContext)
			{
				// Priority 0 = highest priority (processed first)
				Subsystem->AddMappingContext(DefaultMappingContext, 0);
				UE_LOG(LogTemp, Warning, TEXT("[INPUT] DefaultMappingContext registered with priority 0 (ONLY context)"));
			}
			else
			{
				UE_LOG(LogTemp, Error, TEXT("[INPUT] ERROR: DefaultMappingContext is NULL!"));
			}
		}
		else
		{
			UE_LOG(LogTemp, Error, TEXT("[INPUT] ERROR: EnhancedInputLocalPlayerSubsystem not found!"));
		}
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("[INIT] ERROR: Controller is NULL or not PlayerController!"));
	}
	
	UE_LOG(LogTemp, Error, TEXT("========== [CRITICAL] AExcelionCharacter::BeginPlay END =========="));
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
	UE_LOG(LogTemp, Error, TEXT("========== [CRITICAL] SetupPlayerInputComponent CALLED =========="));
	
	Super::SetupPlayerInputComponent(PlayerInputComponent);

	if (!PlayerInputComponent)
	{
		UE_LOG(LogTemp, Error, TEXT("[CRITICAL] ERROR: PlayerInputComponent is NULL!"));
		return;
	}

	UE_LOG(LogTemp, Warning, TEXT("[INPUT] SetupPlayerInputComponent called - InputComponent valid"));

	if (UEnhancedInputComponent* EnhancedInputComponent = Cast<UEnhancedInputComponent>(PlayerInputComponent))
	{
		if (MoveAction)
		{
			EnhancedInputComponent->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AExcelionCharacter::Move);
			UE_LOG(LogTemp, Warning, TEXT("[INPUT] Bound MoveAction"));
		}
		if (LookAction)
		{
			EnhancedInputComponent->BindAction(LookAction, ETriggerEvent::Triggered, this, &AExcelionCharacter::Look);
			UE_LOG(LogTemp, Warning, TEXT("[INPUT] Bound LookAction"));
		}
		if (AttackAction)
		{
			EnhancedInputComponent->BindAction(AttackAction, ETriggerEvent::Started, this, &AExcelionCharacter::Attack);
			UE_LOG(LogTemp, Warning, TEXT("[INPUT] Bound AttackAction"));
		}
		if (DashAction)
		{
			EnhancedInputComponent->BindAction(DashAction, ETriggerEvent::Started, this, &AExcelionCharacter::Dash);
			UE_LOG(LogTemp, Warning, TEXT("[INPUT] Bound DashAction"));
		}
	}
	else
	{
		UE_LOG(LogTemp, Error, TEXT("[INPUT] ERROR: PlayerInputComponent is not EnhancedInputComponent; legacy input path is disabled."));
	}
	
	UE_LOG(LogTemp, Error, TEXT("========== [CRITICAL] SetupPlayerInputComponent END =========="));
}

void AExcelionCharacter::Move(const FInputActionValue& Value)
{
	const FVector2D MovementVector = Value.Get<FVector2D>();
	
	// ===== DEBUG: Check what value we're receiving =====
	static bool bFirstLog = true;
	if (bFirstLog)
	{
		bFirstLog = false;
		UE_LOG(LogTemp, Error, TEXT("[MOVE DEBUG] First Move() called with Value: X=%.3f Y=%.3f"), MovementVector.X, MovementVector.Y);
		UE_LOG(LogTemp, Error, TEXT("[MOVE DEBUG] MoveAction: %s"), MoveAction ? *MoveAction->GetName() : TEXT("NULL"));
		UE_LOG(LogTemp, Error, TEXT("[MOVE DEBUG] DefaultMappingContext: %s"), DefaultMappingContext ? *DefaultMappingContext->GetName() : TEXT("NULL"));
		if (DefaultMappingContext)
		{
			UE_LOG(LogTemp, Error, TEXT("[MOVE DEBUG] DefaultMappingContext has %d mappings"), DefaultMappingContext->GetMappings().Num());
		}
	}
	
	UE_LOG(LogTemp, Warning, TEXT("[MOVE] Move called: Value=%s"), *MovementVector.ToString());

	if (bIsDashing)
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] BLOCKED: bIsDashing=true"));
		return;
	}
	if (IsDead())
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] BLOCKED: IsDead=true"));
		return;
	}

	if (MovementVector.IsNearlyZero())
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] Input is nearly zero, skipping"));
		return;
	}

	const FVector ForwardDir = GetActorForwardVector();
	const FVector RightDir = GetActorRightVector();

	UE_LOG(LogTemp, Warning, TEXT("[MOVE] Adding input: Forward=%.2f (Y), Right=%.2f (X)"),
		MovementVector.Y, MovementVector.X);
	UE_LOG(LogTemp, Warning, TEXT("[MOVE] Directions - Forward=%s, Right=%s"),
		*ForwardDir.ToString(), *RightDir.ToString());

	AddMovementInput(ForwardDir, MovementVector.Y);
	AddMovementInput(RightDir, MovementVector.X);

	UE_LOG(LogTemp, Warning, TEXT("[MOVE] AddMovementInput completed"));
}

void AExcelionCharacter::MoveForward(float Value)
{
	UE_LOG(LogTemp, Warning, TEXT("[MOVE] MoveForward called: Value=%.2f"), Value);
	
	if (bIsDashing || IsDead())
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] MoveForward blocked: bIsDashing=%d, IsDead=%d"), bIsDashing, IsDead());
		return;
	}
	
	if (Value != 0.f)
	{
		const FVector ForwardDir = GetActorForwardVector();
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] AddMovementInput: Forward=%.2f, Direction=%s"), Value, *ForwardDir.ToString());
		AddMovementInput(ForwardDir, Value);
	}
}

void AExcelionCharacter::MoveRight(float Value)
{
	UE_LOG(LogTemp, Warning, TEXT("[MOVE] MoveRight called: Value=%.2f"), Value);
	
	if (bIsDashing || IsDead())
	{
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] MoveRight blocked: bIsDashing=%d, IsDead=%d"), bIsDashing, IsDead());
		return;
	}
	
	if (Value != 0.f)
	{
		const FVector RightDir = GetActorRightVector();
		UE_LOG(LogTemp, Warning, TEXT("[MOVE] AddMovementInput: Right=%.2f, Direction=%s"), Value, *RightDir.ToString());
		AddMovementInput(RightDir, Value);
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
