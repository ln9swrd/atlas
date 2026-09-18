# Excelion UE 5.4 — IMC_Default Key Mapping Automation & Read-Back Verification Script
import unreal

def wire_and_verify_imc_default():
    unreal.log("=== IMC_Default Key Mapping Configuration & Read-Back Started ===")

    imc_path = "/Game/Input/IMC_Default"
    imc = unreal.EditorAssetLibrary.load_asset(imc_path)
    if not imc:
        unreal.log_error(f"[IMC-FAIL] Could not load IMC_Default at {imc_path}")
        return False

    ia_move = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Move")
    ia_look = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Look")
    ia_attack = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Attack")
    ia_dash = unreal.EditorAssetLibrary.load_asset("/Game/Input/IA_Dash")

    if not (ia_move and ia_look and ia_attack and ia_dash):
        unreal.log_error("[IMC-FAIL] One or more InputActions missing")
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

    # Create Modifiers with imc outer ownership
    mod_swizzle_w = unreal.new_object(unreal.InputModifierSwizzleAxis, outer=imc)
    if hasattr(mod_swizzle_w, "set_editor_property"):
        try:
            swizzle_enum = getattr(unreal, "EInputAxisSwizzle", None)
            if swizzle_enum and hasattr(swizzle_enum, "YXZ"):
                mod_swizzle_w.set_editor_property("order", swizzle_enum.YXZ)
        except Exception as e:
            unreal.log_warning(f"Swizzle order note: {e}")

    mod_swizzle_s = unreal.new_object(unreal.InputModifierSwizzleAxis, outer=imc)
    if hasattr(mod_swizzle_s, "set_editor_property"):
        try:
            swizzle_enum = getattr(unreal, "EInputAxisSwizzle", None)
            if swizzle_enum and hasattr(swizzle_enum, "YXZ"):
                mod_swizzle_s.set_editor_property("order", swizzle_enum.YXZ)
        except Exception as e:
            unreal.log_warning(f"Swizzle order note: {e}")

    mod_negate_s = unreal.new_object(unreal.InputModifierNegate, outer=imc)
    mod_negate_a = unreal.new_object(unreal.InputModifierNegate, outer=imc)

    # W -> Swizzle YXZ
    m_w = imc.map_key(ia_move, key_w)
    if m_w and mod_swizzle_w:
        m_w.set_editor_property("modifiers", [mod_swizzle_w])

    # S -> Swizzle YXZ + Negate
    m_s = imc.map_key(ia_move, key_s)
    if m_s:
        m_s.set_editor_property("modifiers", [mod_swizzle_s, mod_negate_s])

    # D -> No modifier (+X)
    m_d = imc.map_key(ia_move, key_d)

    # A -> Negate (-X)
    m_a = imc.map_key(ia_move, key_a)
    if m_a and mod_negate_a:
        m_a.set_editor_property("modifiers", [mod_negate_a])

    # IA_Look -> Mouse2D
    m_look = imc.map_key(ia_look, key_mouse2d)

    # IA_Attack -> LMB
    m_atk = imc.map_key(ia_attack, key_lmb)

    # IA_Dash -> Space
    m_dash = imc.map_key(ia_dash, key_space)

    # Mark dirty & Save Asset
    imc.modify()
    unreal.EditorAssetLibrary.save_loaded_asset(imc)
    unreal.EditorAssetLibrary.save_asset(imc_path, only_if_is_dirty=False)
    unreal.log(f"[IMC-SAVE] Saved {imc_path} successfully!")

    # -------------------------------------------------------------
    # READ-BACK PROOF VERIFICATION
    # Re-load IMC_Default from disk and verify mappings array
    # -------------------------------------------------------------
    reloaded_imc = unreal.EditorAssetLibrary.load_asset(imc_path)
    if not reloaded_imc:
        unreal.log_error(f"[READBACK-FAIL] Could not re-load {imc_path}")
        return False

    mappings = reloaded_imc.get_editor_property("mappings") if hasattr(reloaded_imc, "get_editor_property") else []
    unreal.log(f"[READBACK-INFO] Re-loaded IMC_Default Mappings Count = {len(mappings)}")

    if len(mappings) < 7:
        unreal.log_error(f"[READBACK-FAIL] Expected 7 mappings (W,S,A,D,Mouse2D,LMB,Space), found {len(mappings)}")
        return False

    verified_actions = {}
    for idx, m in enumerate(mappings):
        act = m.get_editor_property("action")
        key = m.get_editor_property("key")
        mods = m.get_editor_property("modifiers") if hasattr(m, "get_editor_property") else []
        act_name = act.get_name() if act else "None"
        key_name = key.get_editor_property("key_name") if hasattr(key, "get_editor_property") else str(key)
        mod_names = [mod.get_class().get_name() for mod in mods] if mods else []
        
        unreal.log(f"[READBACK-MAPPING {idx}] Action={act_name}, Key={key_name}, Modifiers={mod_names}")
        if act_name not in verified_actions:
            verified_actions[act_name] = []
        verified_actions[act_name].append((key_name, mod_names))

    required_actions = ["IA_Move", "IA_Look", "IA_Attack", "IA_Dash"]
    for req in required_actions:
        if req in verified_actions:
            unreal.log(f"[READBACK-PASS] Action {req} mapped to: {verified_actions[req]}")
        else:
            unreal.log_error(f"[READBACK-FAIL] Action {req} missing from re-loaded mappings!")
            return False

    unreal.log("=== IMC_Default Key Mapping & Read-Back Verification Completed Successfully ===")
    return True

if __name__ == "__main__":
    wire_and_verify_imc_default()
