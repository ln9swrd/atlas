import unreal

actors = unreal.EditorLevelLibrary.get_all_level_actors()
print("ACTOR_COUNT =", len(actors))

for actor in actors:
    print(actor.get_name())
