# [READ-ONLY TEST SCRIPT] Verify Editor Python Connection
# This script tests if Cline can communicate with Unreal Editor via Python Script Plugin
# DO NOT MODIFY THIS FILE - Read-only verification only

import unreal

def main():
    # Output unique identifier for tracking
    test_id = "[CLINE_UE_PYTHON_TEST_20260821]"
    
    try:
        # Basic import test
        lines = [test_id]
        lines.append(f"[TEST A] Python Script Plugin Import Test - unreal module loaded successfully")
        
        # Current project info if available
        try:
            world_settings = unreal.get_world()
            if world_settings:
                lines.append(f"[TEST B] Editor is running")
                lines.append(f"[TEST C] Project/World Name: {world_settings.get_path_name()}")
            else:
                lines.append("[TEST B] Editor state unknown (no active world)")
        except Exception as e:
            lines.append(f"[TEST B] Error getting world info: {e}")
        
        # List some actors to verify connection
        try:
            actors = unreal.EditorLevelLibrary.GetActorsOfClassIn(
                class_type_to_filter=unreal.ActorClass,
                levels=(world_settings,) if world_settings else (),
                filter_flags=unreal.LevelActorFilterFlags | unreal.LevelActorFilterFlags()
            )
            lines.append(f"[TEST D] Found {len(actors)} actors in active level(s)")
        except Exception as e:
            lines.append(f"[TEST D] Actor listing skipped: {e}")
        
        # Write log output
        output_text = "\n".join(lines)
        unreal.log(output_text)
        
        # Also write to file for later inspection if needed
        try:
            import os
            test_file = "/mnt/d/Atlas/projects/excelion/game/Excelion/Temp/editor_python_test_result.txt"
            os.makedirs(os.path.dirname(test_file), exist_ok=True)
            
            with open(test_file, "w", encoding="utf-8") as f:
                f.write(f"# Editor Python Connection Test\n# Run ID: {test_id}\n")
                f.write(output_text + "\n")
        except Exception as e:
            unreal.log_error(f"Failed to write result file: {e}")
            
    except Exception as e:
        # Critical error - plugin may not be running or accessible
        lines = [test_id, f"[ERROR] Failed to execute Python script in Editor: {e}"]
        output_text = "\n".join(lines)
        unreal.log(output_text)

if __name__ == "__main__":
    main()