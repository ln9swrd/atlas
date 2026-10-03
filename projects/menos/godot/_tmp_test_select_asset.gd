extends SceneTree

func _init() -> void:
    var packed := load("res://editor/content_editor.tscn") as PackedScene
    var root := packed.instantiate()
    root.set_process(true)
    get_root().add_child(root)
    await process_frame
    root._open_robot_editor()
    await process_frame
    var robot = root.current_editor
    var out := ""
    out += "ROBOT\n"
    robot._open_sprite_dialog("animation:idle")
    await process_frame
    await process_frame
    print("STATE path=", ImageEditorState.selected_path, " target=", ImageEditorState.selection_target, " pending=", ImageEditorState.selection_pending)
    print("EDITOR SCENE=", root.current_editor_scene)
    var image_editor = root.current_editor
    print("IMAGE current_path=", image_editor.current_path)
    print("IMAGE current_image_null=", image_editor.current_image == null)
    print("IMAGE current_image_size=", image_editor.current_image.get_width() if image_editor.current_image != null else -1, "x", image_editor.current_image.get_height() if image_editor.current_image != null else -1)
    out += "STATE path=%s target=%s pending=%s\n" % [ImageEditorState.selected_path, ImageEditorState.selection_target, ImageEditorState.selection_pending]
    out += "SCENE=%s\n" % root.current_editor_scene
    out += "IMAGE current_path=%s null=%s\n" % [image_editor.current_path, image_editor.current_image == null]
    out += "IMAGE size=%s\n" % (str(Vector2i(image_editor.current_image.get_width(), image_editor.current_image.get_height())) if image_editor.current_image != null else "NONE")
    out += "IMAGE indices=%s,%s\n" % [image_editor.catalog_target_index, image_editor.current_index]
    var f := FileAccess.open("user://tmp_select_asset_result.txt", FileAccess.WRITE)
    f.store_string(out)
    f.close()
    quit()
