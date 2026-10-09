extends SceneTree

const SOURCE_DB_PATH := "res://content/menos.sqlite"
const TEST_DB_PATH := "user://catalog_save_rollback_test.sqlite"

func _init() -> void:
	var failures: Array[String] = []
	var source_absolute := ProjectSettings.globalize_path(SOURCE_DB_PATH)
	var test_absolute := ProjectSettings.globalize_path(TEST_DB_PATH)

	ContentCatalogLoader.set_database_path_for_tests("")
	for suffix in ["", "-wal", "-shm"]:
		if FileAccess.file_exists(TEST_DB_PATH + suffix):
			var stale_error := DirAccess.remove_absolute(test_absolute + suffix)
			if stale_error != OK:
				print("CATALOG_SAVE_ROLLBACK_FAIL stale_cleanup=" + suffix + ":" + str(stale_error))
				quit(1)
				return
	var copy_error := DirAccess.copy_absolute(source_absolute, test_absolute)
	if copy_error != OK:
		if FileAccess.file_exists(TEST_DB_PATH):
			DirAccess.remove_absolute(test_absolute)
		print("CATALOG_SAVE_ROLLBACK_FAIL database_copy=" + str(copy_error))
		quit(1)
		return

	ContentCatalogLoader.set_database_path_for_tests(TEST_DB_PATH)
	ObjectPersistence.set_database_path_for_tests(TEST_DB_PATH)

	var before_document: Dictionary = ContentCatalogLoader.load_dictionary_catalog("asset_catalog")
	var before_catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog("visual_assets")
	if before_document.is_empty() or before_catalog.is_empty():
		failures.append("snapshot_load")

	if failures.is_empty():
		var document := before_document.duplicate(true)
		document["__rollback_test_marker"] = {"value": "document_should_not_persist"}
		var catalog := before_catalog.duplicate(true)
		var first_id := str(catalog.keys()[0]) if not catalog.is_empty() else ""
		if first_id.is_empty():
			failures.append("catalog_entry")
		else:
			catalog[first_id] = catalog[first_id].duplicate(true)
			catalog[first_id]["__rollback_test_marker"] = {"value": "catalog_should_not_persist"}

		if failures.is_empty():
			ObjectPersistence.set_atomic_failure_injection_for_tests(true)
			var save_ok := ObjectPersistence.save_catalog_pair_atomic("asset_catalog", document, "visual_assets", catalog)
			ObjectPersistence.set_atomic_failure_injection_for_tests(false)

			var after_document: Dictionary = ContentCatalogLoader.load_dictionary_catalog("asset_catalog")
			var after_catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog("visual_assets")
			if save_ok:
				failures.append("save_should_fail")
			if after_document != before_document:
				failures.append("document_rollback")
			if after_catalog != before_catalog:
				failures.append("catalog_rollback")

	ObjectPersistence.set_atomic_failure_injection_for_tests(false)
	ContentCatalogLoader.set_database_path_for_tests("")
	ObjectPersistence.set_database_path_for_tests("")
	for suffix in ["", "-wal", "-shm"]:
		var cleanup_error := DirAccess.remove_absolute(test_absolute + suffix) if FileAccess.file_exists(TEST_DB_PATH + suffix) else OK
		if cleanup_error != OK:
			failures.append("cleanup_" + suffix.replace("-", ""))

	if failures.is_empty():
		print("CATALOG_SAVE_ROLLBACK_PASS")
		quit(0)
	else:
		print("CATALOG_SAVE_ROLLBACK_FAIL " + ",".join(failures))
		quit(1)
