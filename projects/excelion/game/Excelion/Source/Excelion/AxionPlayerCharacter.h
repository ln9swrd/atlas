#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Character.h"
#include "AxionPlayerCharacter.generated.h"

class UAnimSequence;

UCLASS()
class EXCELION_API AAxionPlayerCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AAxionPlayerCharacter();

    virtual void Tick(float DeltaSeconds) override;

protected:
    virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

private:
    void MoveForward(float Value);
    void UpdateMovementAnimation();
    void JumpAction();
    void Dash();
    void DodgeLeft();
    void DodgeRight();
    void BladeDeploy();
    void AttackCombo();
    void AttackSlashLeft();
    void AttackSlashRight();
    void Counter();
    void PlayActionAnimation(UAnimSequence* Animation);

    UAnimSequence* IdleAnimation;
    UAnimSequence* RunForwardAnimation;
    UAnimSequence* WalkBackwardAnimation;
    UAnimSequence* StrafeLeftAnimation;
    UAnimSequence* StrafeRightAnimation;
    UAnimSequence* JumpAnimation;
    UAnimSequence* DashForwardAnimation;
    UAnimSequence* DodgeLeftAnimation;
    UAnimSequence* DodgeRightAnimation;
    UAnimSequence* DodgeBackwardAnimation;
    UAnimSequence* BladeDeployAnimation;
    UAnimSequence* AttackComboAnimation;
    UAnimSequence* AttackSlashLeftAnimation;
    UAnimSequence* AttackSlashRightAnimation;
    UAnimSequence* CounterAnimation;
    UAnimSequence* CurrentAnimation;
    bool bActionAnimationPlaying;
    float ActionAnimationTimeRemaining;
};