class_name MenosData

const TOWERS = {
	"cannon": {"name": "CANNON", "cost": 55, "damage": 42.0, "cooldown": 1.35, "range": 155.0, "preference": "heavy", "level2": {"upgrade_cost": 75, "damage": 60.0, "cooldown": 1.15, "range": 165.0}},
	"gatling": {"name": "GATLING", "cost": 35, "damage": 9.0, "cooldown": 0.23, "range": 145.0, "preference": "fast", "level2": {"upgrade_cost": 50, "damage": 13.0, "cooldown": 0.20, "range": 155.0}}
}

const ENEMIES = {
	"normal": {"name": "NORMAL", "hp": 42.0, "speed": 25.0, "armor": 0.0, "base_damage": 8.0, "reward": 12, "radius": 10.0, "color": Color("f0b35a")},
	"rusher": {"name": "RUSHER", "hp": 27.0, "speed": 55.0, "armor": 0.0, "base_damage": 6.0, "reward": 10, "radius": 8.0, "color": Color("ef7068")},
	"heavy": {"name": "HEAVY", "hp": 125.0, "speed": 14.0, "armor": 8.0, "base_damage": 18.0, "reward": 28, "radius": 15.0, "color": Color("a98ce6")},
	"giant": {"name": "GIANT", "hp": 620.0, "speed": 7.0, "armor": 18.0, "base_damage": 45.0, "reward": 90, "radius": 28.0, "color": Color("f04f6b"), "robot_damage": 20.0, "robot_range": 120.0, "robot_cooldown": 2.0}
}

const ROBOT = {"id": "robot_main", "name": "ATLAS-01", "hp": 220.0, "speed": 125.0, "damage": 28.0, "cooldown": 0.65, "range": 110.0, "max_moves": 5,
	"ability_area": {"damage": 28.0, "radius": 72.0, "cooldown": 6.0, "threshold": 3},
	"ability_pierce": {"damage": 105.0, "cooldown": 7.0}}

const WAVES = [
	{"label": "NORMAL / BOTH LANES", "groups": [["normal", 10, 0.75, ["left", "right"]]]},
	{"label": "RUSHER / NORTH PRESSURE", "groups": [["normal", 6, 0.8, ["right"]], ["rusher", 8, 0.5, ["left"]]]},
	{"label": "HEAVY / SOUTH PRESSURE", "groups": [["rusher", 7, 0.45, ["right"]], ["heavy", 5, 1.1, ["left"]]]},
	{"label": "ALL TYPES / GIANT / BOTH LANES", "groups": [["normal", 8, 0.6, ["left", "right"]], ["rusher", 8, 0.42, ["left", "right"]], ["heavy", 6, 0.9, ["left", "right"]], ["giant", 1, 1.0, ["right"]]]}
]
