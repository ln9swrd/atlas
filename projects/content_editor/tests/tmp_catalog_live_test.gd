extends SceneTree
func _init():
 var root=load("res://editor/map_editor.tscn").instantiate()
 get_root().add_child(root)
 await process_frame
 var rows=root.get_node("MainLayout/Inspector/VBox/AssetScroll/AssetRows")
 var btns=rows.find_children("*","Button",true,false)
 var picked=false
 for b in btns:
  if b is Button and "Basic Meadow" in b.text:
   b.pressed.emit()
   picked=true
   break
 print("PICKED=",picked," ASSET=",root.canvas.selected_catalog_asset.get("asset_id",""))
 root.get_node("MainLayout/Inspector/VBox/BtnPlaceCatalogAsset").pressed.emit()
 print("EDIT_MODE=",root.canvas.edit_mode," SELECTED=",root.canvas.selected_catalog_asset.get("asset_id",""))
 var before=root.canvas.map_data.get("tiles",{}).get("Ground",{}).size()
 root.canvas.paint_tile_at(Vector2(16,74))
 var after=root.canvas.map_data.get("tiles",{}).get("Ground",{}).size()
 print("GROUND_BEFORE=",before," AFTER=",after)
 print("TEST_PASS=",picked and root.canvas.edit_mode=="PAINT" and after>before)
 quit()
