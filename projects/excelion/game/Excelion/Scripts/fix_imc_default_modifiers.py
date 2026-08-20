# Fix script for IMC_Default modifiers in UE 5.4
import unreal

def fix_imc_default():
    unreal.log("=== FIXING IMC_DEFAULT MODIFIERS FOR WASD ===")

    imc_path = "/Game/Input/IMC_Default"
    imc = unreal.EditorAssetLibrary.load_asset(imc_path)
    if not imc:
        unreal.log_error(f"[FAIL] Could not load {imc_path}")
        return False

    ia_move = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Move")
    ia_look = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Look")
    ia_attack = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Attack")
    ia_dash = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Dash")

    if not (ia_move and ia_look and ia_attack and ia_dash):
        unreal.log_error("[FAIL] Missing input action assets")
        return False

    # Clear existing mappings
    imc.unmap_all()

    def make_key(name):
        k = unreal.Key()
        k.set_editor_property("key_name", name)
        return k

    key_w = make_key("W")
    key_s = make_key("S")
    key_a = make_key("A")
    key_d = make_key("D")
    key_mouse2d = make_key("Mouse2D")
    key_lmb = make_key("LeftMouseButton")
    key_space = make_key("SpaceBar")

    # Determine Swizzle Enum YXZ order
    swizzle_order_yxz = None
    if hasattr(unreal, "InputAxisSwizzle") and hasattr(unreal.InputAxisSwizzle, "YXZ"):
        swizzle_order_yxz = unreal.InputAxisSwizzle.YXZ
    elif hasattr(unreal, "EInputAxisSwizzle") and hasattr(unreal.EInputAxisSwizzle, "YXZ"):
        swizzle_order_yxz = unreal.EInputAxisSwizzle.YXZ

    unreal.log(f"[INFO] Using Swizzle YXZ Enum: {swizzle_order_yxz}")

    # 1. W -> Swizzle YXZ
    m_w = imc.map_key(ia_move, key_w)
    mod_w = unreal.InputModifierSwizzleAxis()
    if swizzle_order_yxz is not None:
        mod_w.set_editor_property("order", swizzle_order_yxz)
    m_w.set_editor_property("modifiers", [mod_w])

    # 2. S -> Swizzle YXZ + Negate
    m_s = imc.map_key(ia_move, key_s)
    mod_s_swizzle = unreal.InputModifierSwizzleAxis()
    if swizzle_order_yxz is not None:
        mod_s_swizzle.set_editor_property("order", swizzle_order_yxz)
    mod_s_negate = unreal.InputModifierNegate()
    m_s.set_editor_property("modifiers", [mod_s_swizzle, mod_s_negate])

    # 3. D -> No modifier
    m_d = imc.map_key(ia_move, key_d)
    m_d.set_editor_property("modifiers", [])

    # 4. A -> Negate
    m_a = imc.map_key(ia_move, key_a)
    mod_a_negate = unreal.InputModifierNegate()
    m_a.set_editor_property("modifiers", [mod_a_negate])

    # 5. Look / Attack / Dash
    imc.map_key(ia_look, key_mouse2d)
    imc.map_key(ia_attack, key_lmb)
    imc.map_key(ia_dash, key_space)

    # Save asset
    imc.modify()
    unreal.EditorAssetLibrary.save_loaded_asset(imc)
    unreal.EditorAssetLibrary.save_asset(imc_path, only_if_is_dirty=False)
    unreal.log(f"[PASS] Successfully saved fixed {imc_path}!")

    # -------------------------------------------------------------
    # READ-BACK VERIFICATION
    # -------------------------------------------------------------
    reloaded_imc = unreal.EditorAssetLibrary.load_asset(imc_path)
    mappings = reloaded_imc.get_editor_property("mappings") if hasattr(reloaded_imc, "get_editor_property") else []
    unreal.log(f"[READBACK] Re-loaded mappings count: {len(mappings)}")

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

        unreal.log(f"[VERIFIED MAPPING {idx}] Key={key_name}, Action={act_name}, Modifiers={mod_details}")

    return True

if __name__ == "__main__":
    fix_imc_default()
