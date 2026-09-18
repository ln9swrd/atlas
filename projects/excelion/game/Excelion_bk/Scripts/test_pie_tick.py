import unreal
import time

def test_pie_tick():
    unreal.log("=== Testing PIE Simulate Ticking ===")
    if hasattr(unreal.EditorLevelLibrary, "editor_play_simulate"):
        unreal.EditorLevelLibrary.editor_play_simulate()
        unreal.log("[TEST] Started editor_play_simulate()")
    else:
        unreal.log("[TEST] editor_play_simulate not available")

    # Load BP class
    bp_char_class = unreal.load_object(None, "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C")
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    score_comp = player.get_component_by_class(unreal.SCoreComponent)
    
    if score_comp:
        score_comp.add_heat(100.0)
        unreal.log(f"[TEST Initial] Heat={score_comp.get_editor_property('current_heat')}, IsOverheated={score_comp.get_editor_property('is_overheated')}")
        
        # Test ticking via SystemLibrary or sleep loop
        for i in range(4):
            time.sleep(1.0)
            h = score_comp.get_editor_property('current_heat')
            s = score_comp.get_editor_property('current_s_core')
            unreal.log(f"[TEST Tick {i+1}s] Heat={h}, SCore={s}")

    unreal.EditorLevelLibrary.destroy_actor(player)

if __name__ == "__main__":
    test_pie_tick()
