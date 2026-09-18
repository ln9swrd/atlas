# Scratch inspection script for IA_Move and IMC_Default
import unreal

def inspect_assets():
    unreal.log("=== INSPECTING IA_MOVE AND IMC_DEFAULT ASSETS ===")
    
    ia_move = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Move")
    if not ia_move:
        unreal.log_error("[FAIL] Could not load /Game/Input/IA_Move")
        return
        
    val_type = ia_move.get_editor_property("value_type") if hasattr(ia_move, "get_editor_property") else None
    unreal.log(f"[IA_Move ASSET] Loaded IA_Move: {ia_move.get_name()}, ValueType: {val_type}")
    
    imc = unreal.EditorAssetLibrary.load_asset("/Game/Input/IMC_Default")
    if not imc:
        unreal.log_error("[FAIL] Could not load /Game/Input/IMC_Default")
        return

    mappings = imc.get_editor_property("mappings") if hasattr(imc, "get_editor_property") else []
    unreal.log(f"[IMC_Default ASSET] Total mappings count: {len(mappings)}")
    
    for idx, m in enumerate(mappings):
        act = m.get_editor_property("action")
        key = m.get_editor_property("key")
        mods = m.get_editor_property("modifiers") if hasattr(m, "get_editor_property") else []
        act_name = act.get_name() if act else "None"
        key_name = key.get_editor_property("key_name") if hasattr(key, "get_editor_property") else str(key)
        
        mod_details = []
        for mod in mods:
            cls_name = mod.get_class().get_name()
            extra = ""
            if isinstance(mod, unreal.InputModifierSwizzleAxis):
                order = mod.get_editor_property("order") if hasattr(mod, "get_editor_property") else "N/A"
                extra = f" (order={order})"
            mod_details.append(f"{cls_name}{extra}")
            
        unreal.log(f"[MAPPING {idx}] Action={act_name}, Key={key_name}, Modifiers={mod_details}")

if __name__ == "__main__":
    inspect_assets()
