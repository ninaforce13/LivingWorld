extends ContentInfo
var recruit_tracker:Array = []
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

func clear_recruit_tracker():
	recruit_tracker.clear()

func add_recruit_spawn(recruit):
	if not recruit_tracker.has(recruit):
		recruit_tracker.append(recruit)

func remove_recruit_spawn(recruit):
	if recruit_tracker.has(recruit):
		recruit_tracker.erase(recruit)

func recruit_exists(recruit)->bool:
	var result:bool = false
	for child in recruit_tracker:
		if child.hash() == recruit.hash():
			result = true
			break
	return result

func filter_recruits(recruits)->Array:
	var filtered_recruits:Array = recruits.duplicate()
	for recruit in recruits:
		if recruit_exists(recruit):
			filtered_recruits.erase(recruit)
	return filtered_recruits


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
	Console.register("clean_data",{
		"description":"Clean save data values",
		"args":[TYPE_STRING],
		"target":[self,"clean_data"]
		})
	Console.register("get_otherdata_keys",{
		"description":"Get key values from Savestate.other_data dictionary",
		"args":[],
		"target":[self,"get_otherdata_keys"]
		})
	Console.register("pause",{
		"description":"Pause World",
		"args":[],
		"target":[self,"pause"]
		})

func pause():
	WorldSystem.get_tree().paused = !WorldSystem.get_tree().paused

func clean_data(key:String):
	if key != "" and SaveState.other_data.has(key):
		SaveState.other_data.erase(key)
		return "Erased %s from SaveState.other_data."%key
	return "%s is not a valid key."%key

func get_otherdata_keys():
	var key_array:Array = []
	for key in SaveState.other_data:
		key_array.push_back(key)
	return key_array
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
			debugnode.queue_free()
