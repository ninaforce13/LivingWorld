extends ContentInfo
const settings_path = "user://LivingWorldSettings.cfg"
var recruit_tracker:Array = []
var levelmap_patch = preload("LevelMap_patch.gd")
var encounterconfig_patch = preload("encounter_config_patch.gd")
var warptarget_patch = preload("warptarget_patch.gd")
var warpregion_patch = preload("warp_region_patch.gd")
var battlebackground_patch = preload("battlebackground_patch.gd")
var npcspawner = preload("res://mods/LivingWorld/scripts/Spawner_patch.gd")
var roguefusions = preload("res://mods/LivingWorld/scripts/RogueFusions_patch.gd")
var campsite = preload("res://mods/LivingWorld/scripts/Camping_patch.gd")
var inventorydetail = preload("res://mods/LivingWorld/scripts/inventorydetail_patch.gd")
var stickeritem_patch = preload("res://mods/LivingWorld/scripts/StickerItem_patch.gd")
var playercontroller = preload("res://mods/LivingWorld/scripts/PlayerControllerPatch.gd")
var interactor = preload("res://mods/LivingWorld/scripts/Interactor_patch.gd")
var captainbehavior = preload("res://mods/LivingWorld/scripts/CaptainNPCBehavior_patch.gd")
var usersettings = preload("res://mods/LivingWorld/scripts/UserSettings_patch.gd")
var mappausemenu = preload("res://mods/LivingWorld/scripts/MapPauseMenu_patch.gd")
var conditionallayer = preload("res://mods/LivingWorld/scripts/ConditionalLayer_patch.gd")
var battlenpcbehavior = preload("res://mods/LivingWorld/scripts/BattleNPCBehavior_patch.gd")
var unlockedpartnerspawner = preload("res://mods/LivingWorld/scripts/UnlockedPartnerSpawner_patch.gd")

var partners:Dictionary = {}
const npc_template = preload("res://mods/LivingWorld/nodes/RecruitTemplate.tscn")
const warptarget_template = preload("res://mods/LivingWorld/nodes/warptarget.tscn")
const settings = preload("res://mods/LivingWorld/settings.tres")
const spawner = preload("res://mods/LivingWorld/nodes/RecruitSpawner.tscn")
const empty_charconfig = preload("res://mods/LivingWorld/nodes/empty_charconfig.tscn")
const rangerdataparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
const partnercontroller = preload("res://nodes/partners/PartnerController.tscn")
const followertemplate = preload("res://mods/LivingWorld/nodes/FollowerTemplate.tscn")

func _init():
	levelmap_patch.patch()
	encounterconfig_patch.patch()
	warpregion_patch.patch()
	warptarget_patch.patch()
	battlebackground_patch.patch()
	npcspawner.patch()
	campsite.patch()
	roguefusions.patch()
	inventorydetail.patch()
	stickeritem_patch.patch()
	playercontroller.patch()
	interactor.patch()
	captainbehavior.patch()
	usersettings.patch()
	mappausemenu.patch()
	conditionallayer.patch()
	battlenpcbehavior.patch()
	unlockedpartnerspawner.patch()


	yield(SceneManager.preloader,"singleton_setup_completed")
	add_keyboard_shortcuts()
	add_debug_commands()
	preload_partners()

func preload_partners():
	partners["vin"] = preload("res://mods/LivingWorld/partner_templates/Vin.tscn")
	partners["frankie"] = preload("res://mods/LivingWorld/partner_templates/Frankie.tscn")
	partners["kayleigh"] = preload("res://mods/LivingWorld/partner_templates/Kayleigh.tscn")
	partners["dog"] = preload("res://mods/LivingWorld/partner_templates/Barkley.tscn")
	partners["felix"] = preload("res://mods/LivingWorld/partner_templates/Felix.tscn")
	partners["eugene"] = preload("res://mods/LivingWorld/partner_templates/Eugene.tscn")
	partners["meredith"] = preload("res://mods/LivingWorld/partner_templates/Meredith.tscn")
	partners["viola"] = preload("res://mods/LivingWorld/partner_templates/Viola.tscn")
	partners["sunny"] = preload("res://mods/LivingWorld/partner_templates/Sunny.tscn")

func add_keyboard_shortcuts():
	var inputeventkey = InputEventKey.new()
	var inputeventjoy = InputEventJoypadButton.new()
	inputeventkey.scancode = KEY_T
	inputeventjoy.button_index = JOY_R3
	InputMap.add_action("livingworldmod_transform")
	InputMap.action_add_event("livingworldmod_transform",inputeventkey)
	InputMap.action_add_event("livingworldmod_transform",inputeventjoy)

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
		"description":"Remove other_data values in SaveState",
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
	Console.register("add_spawner",{
		"description":"Adds the current location as a recruit spawner [name,ignore visibility,personality(enum values {combative, social, loner, townie}),supress_abilities]",
		"args":[TYPE_STRING,TYPE_BOOL,TYPE_INT,TYPE_BOOL],
		"target":[self,"add_location_spawner"]
		})
	Console.register("export_player",{
		"description":"Exports the player character as a JSON into the arena_archives folder",
		"args":[],
		"target":[self,"export_player"]
	})
	Console.register("spawn_test",{
		"description":"Spawns a LivingWorld NPC for testing.",
		"args":[],
		"target":[self,"spawn_npc"]
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
	print("Player current @%s in region %s in current scene %s"%[str(player.global_transform.origin), WorldSystem.get_level_map().region_settings.region_name, str(SceneManager.current_scene)])

func add_location_spawner(location_name:String,ignore_visibility:bool=false,personality=-1,supress_abilities:bool = false):
	var settings = load("res://mods/LivingWorld/settings.tres")
	var player = WorldSystem.get_player()
	var region_name = WorldSystem.get_level_map().region_settings.region_name
	if !settings.levelmap_spawners.has(region_name):
		settings.levelmap_spawners[region_name] = {"locations":[]}
	for location in settings.levelmap_spawners[region_name].locations:
		if location.name == location_name:
			return ("Location name already exists.")
	settings.levelmap_spawners[region_name].locations.push_back({"name":location_name,"pos":player.global_transform.origin,"ignore_visibility":ignore_visibility,"forced_personality":personality, "supress_abilities":supress_abilities})
	var err = ResourceSaver.save("res://mods/LivingWorld/settings.tres",settings)
	if err == OK:
		return ("Saved %s for region %s at position %s with ignore_visibility set to %s personality set to %s abiilities supressed %s"%[location_name,region_name,player.global_transform.origin,ignore_visibility,personality,supress_abilities])
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
func export_player():
	var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var playersnap = jsonparser.get_player_snapshot()
	if playersnap:
		return jsonparser.save_json(playersnap)
	return false

func spawn_npc():
	var npc_template = preload("res://mods/LivingWorld/nodes/RecruitTemplate.tscn")
	var rangerdataparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var npc = npc_template.instance()
	npc.get_data().recruit = rangerdataparser.get_empty_recruit()

	WorldSystem.get_level_map().add_child(npc)
	npc.global_transform.origin = WorldSystem.get_player().global_transform.origin
