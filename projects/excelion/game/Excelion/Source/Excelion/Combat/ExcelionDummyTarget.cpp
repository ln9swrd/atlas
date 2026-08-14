// Copyright Excelion. All Rights Reserved.

#include "Combat/ExcelionDummyTarget.h"
#include "Combat/HealthComponent.h"
#include "Components/CapsuleComponent.h"
#include "Components/StaticMeshComponent.h"
#include "UObject/ConstructorHelpers.h"

AExcelionDummyTarget::AExcelionDummyTarget()
{
	PrimaryActorTick.bCanEverTick = false;

	CapsuleComponent = CreateDefaultSubobject<UCapsuleComponent>(TEXT("CapsuleComponent"));
	CapsuleComponent->InitCapsuleSize(40.f, 90.f);
	CapsuleComponent->SetCollisionObjectType(ECC_Pawn);
	CapsuleComponent->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
	CapsuleComponent->SetCollisionResponseToAllChannels(ECR_Block);
	RootComponent = CapsuleComponent;

	FallbackVisualMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("FallbackVisualMesh"));
	FallbackVisualMesh->SetupAttachment(RootComponent);
	FallbackVisualMesh->SetRelativeScale3D(FVector(0.8f, 0.8f, 1.8f));

	static ConstructorHelpers::FObjectFinder<UStaticMesh> DefaultCubeMesh(TEXT("/Engine/BasicShapes/Cube.Cube"));
	if (DefaultCubeMesh.Succeeded())
	{
		FallbackVisualMesh->SetStaticMesh(DefaultCubeMesh.Object);
	}

	HealthComponent = CreateDefaultSubobject<UHealthComponent>(TEXT("HealthComponent"));
	HealthComponent->MaxHealth = 100.f;
}

void AExcelionDummyTarget::BeginPlay()
{
	Super::BeginPlay();

	if (HealthComponent)
	{
		HealthComponent->OnDeath.AddDynamic(this, &AExcelionDummyTarget::OnDeath);
	}
}

bool AExcelionDummyTarget::IsDead() const
{
	return HealthComponent && HealthComponent->IsDead();
}

void AExcelionDummyTarget::OnDeath()
{
	SetActorEnableCollision(false);
}
