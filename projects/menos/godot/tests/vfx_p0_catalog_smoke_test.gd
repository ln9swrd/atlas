extends SceneTree

func _init() -> void:
	var failures: Array[String] = []
	var repo = load("res://scripts/vfx_definition_repository.gd")
	var definition_script = load("res://scripts/vfx_definition.gd")
	if repo == null or definition_script == null:
		print("VFX_P0_CATALOG_SMOKE_FAIL script_load")
		quit(1)
		return
	if not repo.ensure_schema():
		failures.append("ensure_schema")
	var definition = definition_script.new()
	definition.id = "test.vfx.p0"
	definition.name = "P0 Test VFX"
	definition.category = "test"
	definition.schema_version = 1
	definition.revision = 1
	definition.status = "Draft"
	definition.visual_resource_refs = ["robot.asura.attack"]
	definition.priority = 3
	if not repo.save_definition(definition):
		failures.append("save_definition")
	repo.reload()
	var loaded = repo.get_definition(definition.id)
	if loaded == null:
		failures.append("reload_definition")
	elif loaded.visual_resource_refs != definition.visual_resource_refs:
		failures.append("resource_reference")
	elif loaded.schema_version != 1:
		failures.append("schema_version")
	var raw_catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog("vfx_definitions")
	if not raw_catalog.has(definition.id):
		failures.append("sqlite_catalog_entry")
	if not repo.delete_definition(definition.id):
		failures.append("cleanup_definition")
	if failures.is_empty():
		print("VFX_P0_CATALOG_SMOKE_PASS")
		quit(0)
	else:
		print("VFX_P0_CATALOG_SMOKE_FAIL " + ",".join(failures))
		quit(1)
