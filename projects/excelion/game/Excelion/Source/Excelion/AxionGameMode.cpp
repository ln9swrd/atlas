#include "AxionGameMode.h"

#include "AxionPlayerCharacter.h"

AAxionGameMode::AAxionGameMode()
{
    DefaultPawnClass = AAxionPlayerCharacter::StaticClass();
}