#include "AxionPlayerCharacter.h"

#include "Animation/AnimSequence.h"
#include "Camera/CameraComponent.h"
#include "Components/CapsuleComponent.h"
#include "GameFramework/CharacterMovementComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "UObject/ConstructorHelpers.h"

AAxionPlayerCharacter::AAxionPlayerCharacter()
{
    PrimaryActorTick.bCanEverTick = true;

    static ConstructorHelpers::FObjectFinder<USkeletalMesh> AxionMesh(TEXT("/Game/Axion/Axion.Axion"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> IdleAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Idle.axionaxion_metarig_axion_Idle"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> RunForwardAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Run_Forward.axionaxion_metarig_axion_Run_Forward"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> WalkBackwardAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Walk_Backward.axionaxion_metarig_axion_Walk_Backward"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> StrafeLeftAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Strafe_Left.axionaxion_metarig_axion_Strafe_Left"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> StrafeRightAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Strafe_Right.axionaxion_metarig_axion_Strafe_Right"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> JumpAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Jump.axionaxion_metarig_axion_Jump"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> DashAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Dash_Forward.axionaxion_metarig_axion_Dash_Forward"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> DodgeLeftAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Dodge_Left.axionaxion_metarig_axion_Dodge_Left"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> DodgeRightAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Dodge_Right.axionaxion_metarig_axion_Dodge_Right"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> DodgeBackwardAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Dodge_Backward.axionaxion_metarig_axion_Dodge_Backward"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> BladeDeployAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Blade_Deploy.axionaxion_metarig_axion_Blade_Deploy"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> AttackComboAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Attack_Combo.axionaxion_metarig_axion_Attack_Combo"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> AttackSlashLeftAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Attack_Slash_Left.axionaxion_metarig_axion_Attack_Slash_Left"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> AttackSlashRightAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Attack_Slash_Right.axionaxion_metarig_axion_Attack_Slash_Right"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> GuardAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Guard.axionaxion_metarig_axion_Guard"));
    static ConstructorHelpers::FObjectFinder<UAnimSequence> CounterAsset(TEXT("/Game/Axion/axionaxion_metarig_axion_Counter.axionaxion_metarig_axion_Counter"));

    IdleAnimation = IdleAsset.Object;
    RunForwardAnimation = RunForwardAsset.Object;
    WalkBackwardAnimation = WalkBackwardAsset.Object;
    StrafeLeftAnimation = StrafeLeftAsset.Object;
    StrafeRightAnimation = StrafeRightAsset.Object;
    JumpAnimation = JumpAsset.Object;
    DashForwardAnimation = DashAsset.Object;
    DodgeLeftAnimation = DodgeLeftAsset.Object;
    DodgeRightAnimation = DodgeRightAsset.Object;
    DodgeBackwardAnimation = DodgeBackwardAsset.Object;
    BladeDeployAnimation = BladeDeployAsset.Object;
    AttackComboAnimation = AttackComboAsset.Object;
    AttackSlashLeftAnimation = AttackSlashLeftAsset.Object;
    AttackSlashRightAnimation = AttackSlashRightAsset.Object;
    CounterAnimation = CounterAsset.Object;
    CurrentAnimation = nullptr;
    bActionAnimationPlaying = false;
    ActionAnimationTimeRemaining = 0.0f;

    if (AxionMesh.Succeeded())
    {
        GetMesh()->SetSkeletalMesh(AxionMesh.Object);
        GetMesh()->SetRelativeLocation(FVector::ZeroVector);
        GetMesh()->SetRelativeRotation(FRotator(0.0f, -90.0f, 0.0f));
        GetMesh()->SetAnimationMode(EAnimationMode::AnimationSingleNode);
    }

    GetCharacterMovement()->MaxWalkSpeed = 600.0f;
    bUseControllerRotationYaw = true;
    GetCharacterMovement()->bOrientRotationToMovement = false;

    USpringArmComponent* CameraBoom = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraBoom"));
    CameraBoom->SetupAttachment(RootComponent);
    CameraBoom->TargetArmLength = 450.0f;
    CameraBoom->bUsePawnControlRotation = true;

    UCameraComponent* FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
    FollowCamera->SetupAttachment(CameraBoom, USpringArmComponent::SocketName);
    FollowCamera->bUsePawnControlRotation = false;
}

void AAxionPlayerCharacter::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    if (bActionAnimationPlaying)
    {
        ActionAnimationTimeRemaining -= DeltaSeconds;
        if (ActionAnimationTimeRemaining <= 0.0f)
        {
            bActionAnimationPlaying = false;
            CurrentAnimation = nullptr;
        }
        else
        {
            return;
        }
    }
    UpdateMovementAnimation();
}

void AAxionPlayerCharacter::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
    Super::SetupPlayerInputComponent(PlayerInputComponent);

    PlayerInputComponent->BindAxis(TEXT("MoveForward"), this, &AAxionPlayerCharacter::MoveForward);
    PlayerInputComponent->BindAxis(TEXT("Turn"), this, &APawn::AddControllerYawInput);
    PlayerInputComponent->BindAxis(TEXT("LookUp"), this, &APawn::AddControllerPitchInput);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Pressed, this, &AAxionPlayerCharacter::JumpAction);
    PlayerInputComponent->BindAction(TEXT("Jump"), IE_Released, this, &ACharacter::StopJumping);
    PlayerInputComponent->BindAction(TEXT("Dash"), IE_Pressed, this, &AAxionPlayerCharacter::Dash);
    PlayerInputComponent->BindAction(TEXT("DodgeLeft"), IE_Pressed, this, &AAxionPlayerCharacter::DodgeLeft);
    PlayerInputComponent->BindAction(TEXT("DodgeRight"), IE_Pressed, this, &AAxionPlayerCharacter::DodgeRight);
    PlayerInputComponent->BindAction(TEXT("BladeDeploy"), IE_Pressed, this, &AAxionPlayerCharacter::BladeDeploy);
    PlayerInputComponent->BindAction(TEXT("Attack"), IE_Pressed, this, &AAxionPlayerCharacter::AttackCombo);
    PlayerInputComponent->BindAction(TEXT("AttackSlashLeft"), IE_Pressed, this, &AAxionPlayerCharacter::AttackSlashLeft);
    PlayerInputComponent->BindAction(TEXT("AttackSlashRight"), IE_Pressed, this, &AAxionPlayerCharacter::AttackSlashRight);
    PlayerInputComponent->BindAction(TEXT("Counter"), IE_Pressed, this, &AAxionPlayerCharacter::Counter);
}

void AAxionPlayerCharacter::MoveForward(float Value)
{
    if (Controller && Value != 0.0f)
    {
        AddMovementInput(GetActorForwardVector(), Value);
    }
}

void AAxionPlayerCharacter::UpdateMovementAnimation()
{
    const FVector LocalVelocity = GetActorTransform().InverseTransformVectorNoScale(GetVelocity());
    const float ForwardSpeed = LocalVelocity.X;
    const float RightSpeed = LocalVelocity.Y;
    const float MovementThreshold = 10.0f;
    UAnimSequence* NextAnimation = IdleAnimation;

    if (FMath::Abs(ForwardSpeed) >= FMath::Abs(RightSpeed))
    {
        if (ForwardSpeed > MovementThreshold)
        {
            NextAnimation = RunForwardAnimation;
        }
        else if (ForwardSpeed < -MovementThreshold)
        {
            NextAnimation = WalkBackwardAnimation;
        }
    }
    else if (RightSpeed > MovementThreshold)
    {
        NextAnimation = StrafeRightAnimation;
    }
    else if (RightSpeed < -MovementThreshold)
    {
        NextAnimation = StrafeLeftAnimation;
    }

    if (NextAnimation && NextAnimation != CurrentAnimation)
    {
        CurrentAnimation = NextAnimation;
        GetMesh()->PlayAnimation(CurrentAnimation, true);
    }
}

void AAxionPlayerCharacter::JumpAction()
{
    Jump();
    PlayActionAnimation(JumpAnimation);
}

void AAxionPlayerCharacter::Dash()
{
    LaunchCharacter(GetActorForwardVector() * 1000.0f, true, false);
    PlayActionAnimation(DashForwardAnimation);
}

void AAxionPlayerCharacter::DodgeLeft()
{
    LaunchCharacter(-GetActorRightVector() * 500.0f, true, false);
    PlayActionAnimation(DodgeLeftAnimation);
}

void AAxionPlayerCharacter::DodgeRight()
{
    LaunchCharacter(GetActorRightVector() * 500.0f, true, false);
    PlayActionAnimation(DodgeRightAnimation);
}

void AAxionPlayerCharacter::BladeDeploy()
{
    PlayActionAnimation(BladeDeployAnimation);
}

void AAxionPlayerCharacter::AttackCombo()
{
    PlayActionAnimation(AttackComboAnimation);
}

void AAxionPlayerCharacter::AttackSlashLeft()
{
    PlayActionAnimation(AttackSlashLeftAnimation);
}

void AAxionPlayerCharacter::AttackSlashRight()
{
    PlayActionAnimation(AttackSlashRightAnimation);
}

void AAxionPlayerCharacter::Counter()
{
    PlayActionAnimation(CounterAnimation);
}

void AAxionPlayerCharacter::PlayActionAnimation(UAnimSequence* Animation)
{
    if (!Animation)
    {
        return;
    }

    bActionAnimationPlaying = true;
    ActionAnimationTimeRemaining = Animation->GetPlayLength();
    CurrentAnimation = Animation;
    GetMesh()->PlayAnimation(Animation, false);
}