import unreal
import time

def test_tick():
    world = unreal.EditorLevelLibrary.get_editor_world()
    bp_char_class = unreal.load_object(None, "/Game/Blueprints/BP_ExcelionCharacter.BP_ExcelionCharacter_C")
    player = unreal.EditorLevelLibrary.spawn_actor_from_class(bp_char_class, unreal.Vector(0, 0, 100), unreal.Rotator(0, 0, 0))
    score_comp = player.get_component_by_class(unreal.SCoreComponent)
    
    unreal.log(f"[TEST] Initial CurrentHeat={score_comp.get_editor_property('current_heat')}, CurrentSCore={score_comp.get_editor_property('current_s_core')}")
    score_comp.add_heat(100.0)
    unreal.log(f"[TEST] After AddHeat(100): CurrentHeat={score_comp.get_editor_property('current_heat')}, IsOverheated={score_comp.get_editor_property('is_overheated')}")
    
    # Check if time.sleep or EditorLevelLibrary allows ticks
    for i in range(5):
        time.sleep(0.5)
        # Check if score_comp tick has updated
        h = score_comp.get_editor_property('current_heat')
        s = score_comp.get_editor_property('current_s_core')
        unreal.log(f"[TEST Tick {i+1}] Heat={h}, SCore={s}")

    unreal.EditorLevelLibrary.destroy_actor(player)

if __name__ == "__main__":
    test_tick()
