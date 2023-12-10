extends ContentInfo

var levelmap_patch = preload("LevelMap_patch.gd")
var encounterconfig_patch = preload("encounter_config_patch.gd")
var warptarget_patch = preload("warptarget_patch.gd")
var warpregion_patch = preload("warp_region_patch.gd")
var battlebackground_patch = preload("battlebackground_patch.gd")
var npcspawner = preload("res://mods/LivingWorld/scripts/Spawner_patch.gd")

func _init():
	Console.register("add_recruit", {
			"description":"Adds debug recruit follower.", 
			"args":[TYPE_BOOL], 
			"target":[self, "add_recruit"]
		})	
	levelmap_patch.patch()
	encounterconfig_patch.patch()
	warpregion_patch.patch()
	warptarget_patch.patch()
	battlebackground_patch.patch()
	npcspawner.patch()
	
func add_recruit():
	WorldSystem.get_level_map().spawn_recruit()	
