extends SceneTree

func _init() -> void:
	var failures: Array[String] = []
	var before_document: Dictionary = ContentCatalogLoader.load_dictionary_catalog("asset_catalog")
	var before_catalog: Dictionary = ContentCatalogLoader.load_dictionary_catalog("visual_assets")
	if before_document.is_empty() or before_catalog.is_empty():
		failures.append("snapshot_load")

	var document := before_document.duplicate(true)
	document["__rollback_test_marker"] = {"value": "document_should_not_persist"}
	var catalog := before_catalog.duplicate(true)
	var first_id := str(catalog.keys()[0]) if not catalog.is_empty() else ""
	if first_id.is_empty():
		failures.append("catalog_entry")
	else:
		catalog[first_id] = catalog[first_id].duplicate(true)
		catalog[first_id]["__rollback_test_marker"] = {"value": "catalog_should_not_persist"}

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

	if failures.is_empty():
		print("CATALOG_SAVE_ROLLBACK_PASS")
		quit(0)
	else:
		print("CATALOG_SAVE_ROLLBACK_FAIL " + ",".join(failures))
		quit(1)
