extends SceneTree

func _init() -> void:
	var picker := ColorPickerButton.new()
	var log := FileAccess.open("res://_tmp_colorpicker_result.txt", FileAccess.WRITE)
	log.store_line("DEFAULT=" + picker.color.to_html(true))
	picker.color = Color("ff0000ff")
	log.store_line("SET=" + picker.color.to_html(true))
	picker.color = Color("3366ccff")
	log.store_line("SET2=" + picker.color.to_html(true))
	log.close()
	quit()
