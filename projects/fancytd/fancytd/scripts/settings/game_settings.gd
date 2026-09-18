class_name GameSettings
extends Resource

@export_group("Game")
@export var initial_gold: int = 100
@export var initial_life: int = 20

@export_group("Towers")
@export var towers: Array[TowerData] = []

@export_group("Enemies")
@export var enemies: Array[EnemyData] = []

@export_group("Waves")
@export var waves: Array[WaveData] = []

@export_group("Rewards")
@export var rewards: Array[RewardData] = []
