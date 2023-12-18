extends ContentInfo

var levelmap_patch = preload("LevelMap_patch.gd")
var encounterconfig_patch = preload("encounter_config_patch.gd")
var warptarget_patch = preload("warptarget_patch.gd")
var warpregion_patch = preload("warp_region_patch.gd")
var battlebackground_patch = preload("battlebackground_patch.gd")
var npcspawner = preload("res://mods/LivingWorld/scripts/Spawner_patch.gd")
var roguefusions = preload("res://mods/LivingWorld/scripts/RogueFusions_patch.gd")
var campsite = preload("res://mods/LivingWorld/scripts/Camping_patch.gd")
func _init():
	add_debug_commands()
	levelmap_patch.patch()
	encounterconfig_patch.patch()
	warpregion_patch.patch()
	warptarget_patch.patch()
	battlebackground_patch.patch()
	npcspawner.patch()
	campsite.patch()
	roguefusions.patch()
	
func add_debug_commands():
	Console.register("debug_camera", {
			"description":"Adds debug camera controls.", 
			"args":[TYPE_BOOL], 
			"target":[self, "add_debug_camera"]
		})			
	Console.register("my_pos", {
			"description":"Prints player's current global position Vector3", 
			"args":[], 
			"target":[self, "get_my_pos"]
		})		

func get_my_pos():
	var player = WorldSystem.get_player()
	print("Player current @%s"%str(player.global_transform.origin))
	
func add_debug_camera(value):
	var camera = WorldSystem.get_level_map().camera
	
	if value:
		var debugnode = preload("res://mods/LivingWorld/nodes/DebugCameraController.tscn").instance()	
		camera.add_child(debugnode)
		debugnode.set_player_control(false)
	else:
		if camera.has_node("DebugCameraController"):
			var debugnode = camera.get_node("DebugCameraController")
			debugnode.reset_camera()
			debugnode.set_player_control(true)
			camera.remove_child(debugnode)
