extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	StageManager.begin_run("single", "stage_01")
	var main_scene: PackedScene = load("res://main.tscn")
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	var controller = main.get_node("GameController")
	controller.wave_auto_start_delay = 999.0
	controller.start_wave()
	var played: bool = controller._voice_pilot_played
	assert(played)
	var players := controller.get_children().filter(func(node): return node is AudioStreamPlayer)
	assert(players.size() > 0)
	var player: AudioStreamPlayer = players[players.size() - 1]
	assert(player.stream != null)
	assert(player.playing)
	assert(player.stream.resource_path == "res://sound/VOICE_PILOT_FACTION_01_ATTACK_01_KO.wav")
	assert(not controller._play_voice_pilot_once())
	print("VOICE_RUNTIME_INTEGRATION_PASS players=%d stream=%s" % [players.size(), player.stream.resource_path])
	quit(0)
