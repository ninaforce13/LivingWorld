
static func has_active_follower()->bool:
	if not has_savedata():
		initialize_savedata()
	if SaveState.other_data.LivingWorldData.get("CurrentFollower"):
		return SaveState.other_data.LivingWorldData.CurrentFollower.active
	return false

static func is_current_follower(recruit)->bool:
	return SaveState.other_data.LivingWorldData.CurrentFollower.recruit == recruit

static func get_current_follower()->Dictionary:
	return SaveState.other_data.LivingWorldData.CurrentFollower.recruit

static func has_savedata()->bool:
	var result:int = 0
	if SaveState.other_data.has("LivingWorldData"):
		result += 1
		if SaveState.other_data.LivingWorldData.has("ExtraEncounterConfig"):
			result += 1
		if SaveState.other_data.LivingWorldData.has("CurrentFollower"):
			result += 1
		if SaveState.other_data.LivingWorldData.has("Settings"):
			result += 1
			if SaveState.other_data.LivingWorldData.Settings.has("JoinEncounters"):
				result += 1
			if SaveState.other_data.LivingWorldData.Settings.has("MagnetismEnabled"):
				result += 1
			if SaveState.other_data.LivingWorldData.Settings.has("NPCPopulation"):
				result += 1

	return result == 7

static func initialize_savedata():
	SaveState.other_data["LivingWorldData"] = {"ExtraEncounterConfig":{"extra_slots":0},
												"CurrentFollower":{"recruit":{}, "active":false},
												"Settings":{"JoinEncounters":true,
															"MagnetismEnabled":true,
															"NPCPopulation":3}}

static func get_setting(setting_name):
	if !has_savedata():
		initialize_savedata()
	if SaveState.other_data.LivingWorldData.Settings.has("setting_name"):
		return SaveState.other_data.LivingWorldData.Settings[setting_name]
	return null

static func get_follower_config(other_recruit):
	var recruit = other_recruit
	var new_config = load("res://mods/LivingWorld/nodes/empty_charconfig.tscn").instance()
	var rangerdata = load("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	new_config.team = 0
	var tape_nodes:Array = []
	for tape in new_config.get_children():
		tape_nodes.push_back(tape)
	rangerdata.set_char_config(new_config,recruit,tape_nodes)
	new_config.name = "FollowerConfig"
	new_config.ai = preload("res://mods/LivingWorld/nodes/RecruitAINoStatus.tscn")
	return new_config

static func add_battle_slots(battlebackground):
	if !SaveState.other_data.LivingWorldData.has("ExtraEncounterConfig"):
		SaveState.other_data.LivingWorldData["ExtraEncounterConfig"] = {"extra_slots":0}
	if SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots <= 0:
		return
	if SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots > 3:
		SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots = 3
	var player1slot = battlebackground.get_node("BattleSlotPlayer1") if battlebackground.has_node("BattleSlotPlayer1") else null
	var player2slot = battlebackground.get_node("BattleSlotPlayer2") if battlebackground.has_node("BattleSlotPlayer2") else null
	var player3slot = battlebackground.get_node("BattleSlotPlayer3") if battlebackground.has_node("BattleSlotPlayer3") else null
	var enemy1slot = battlebackground.get_node("BattleSlotEnemy1") if battlebackground.has_node("BattleSlotEnemy1") else null
	var enemy2slot = battlebackground.get_node("BattleSlotEnemy2") if battlebackground.has_node("BattleSlotEnemy2") else null
	var enemy3slot = battlebackground.get_node("BattleSlotEnemy3") if battlebackground.has_node("BattleSlotEnemy3") else null
	if not player1slot:
		return
	var index:int = 0
	for _i in range (0, SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots):
		var followerslot = preload("res://mods/LivingWorld/nodes/BattleSlotFollower.tscn").instance()
		var extra_enemy_slot = preload("res://mods/LivingWorld/nodes/BattleSlotEnemy.tscn").instance()
		var offset:int = 4
		var translation_slot = player1slot
		var enemytranslation_slot = enemy1slot
		if index == 1:
			translation_slot = player2slot
			enemytranslation_slot = enemy2slot
		if index == 2:
			battlebackground.add_child_below_node(player2slot, followerslot)
			battlebackground.add_child_below_node(enemy2slot, extra_enemy_slot)
			followerslot.transform.origin = player3slot.transform.origin + Vector3(2,0,0)
			extra_enemy_slot.transform.origin = enemy3slot.transform.origin - Vector3(2,0,0)
			player3slot.transform.origin += Vector3(10,0,0)
			enemy3slot.transform.origin -= Vector3(10,0,0)
			index+=1
			continue

		battlebackground.add_child_below_node(player2slot, followerslot)
		battlebackground.add_child_below_node(enemy2slot, extra_enemy_slot)
		followerslot.translation = translation_slot.translation + Vector3(-12 +(offset*index), 0,0)
		extra_enemy_slot.translation = enemytranslation_slot.translation + Vector3(12-(offset*index), 0,0)
		index+=1
	if SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots > 0:
		battlebackground.battle_camera.wide_mode = true

static func spawn_recruit(levelmap, current_recruit = null):
	var rangerdata = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var PartnerController = load("res://nodes/partners/PartnerController.tscn")
	var FollowerTemplate = load("res://mods/LivingWorld/nodes/FollowerTemplate.tscn")
	var player
	if levelmap.has_node("Player"):
		player = levelmap.get_node("Player")
	var template = FollowerTemplate.instance()

	if not template.has_node(NodePath("PartnerController")):
		var controller = PartnerController.instance()
		controller.min_distance = 6
		controller.max_distance = 8
		template.never_pause = true
		controller.name = "PartnerController"
		template.name = "FollowerRecruit"
		template.add_child(controller, true)
	rangerdata.set_npc_appearance(template,current_recruit)

	WorldSystem.get_level_map().add_child_below_node(player,template)
	template.warp_near(player.global_transform.origin, false)
	if levelmap.has_node("Player"):
		player = levelmap.get_node("Player")
	template.warp_near(player.global_transform.origin, false)
	template.get_node("RecruitData").recruit = current_recruit
	return template

static func create_npc(spawner, node, forced_personality,supress_abilities):
	var random = Random.new()
	var recruit = get_npc()

	if !recruit.has_node("RecruitBehavior"):
		var new_behavior = preload("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
		recruit.add_child(new_behavior)
	var behavior = recruit.get_node("RecruitBehavior")
	behavior.personality = forced_personality if forced_personality >= 0 else random.rand_int(behavior.PERSONALITY.size())
	recruit.transform = node.transform
	recruit.supress_abilities = supress_abilities
	spawner.get_parent().add_child(recruit)

	return recruit
static func get_npc(recruitdata=null):
	var Mod = DLC.mods_by_id["LivingWorldMod"]
	var settings = preload("res://mods/LivingWorld/settings.tres")
	var name_generator = preload("res://mods/LivingWorld/scripts/NameGenerator.gd")
	var rangerdata = load("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var datapath = rangerdata.get_directory()
	var files:Array = rangerdata.get_files(datapath)
	var custom_recruits:Array = rangerdata.read_json(files)
	var recruit = rangerdata.get_empty_recruit() if recruitdata == null else recruitdata
	var npc = load("res://mods/LivingWorld/nodes/RecruitTemplate.tscn").instance()
	var filtered_recruits = Mod.filter_recruits(custom_recruits)
	var use_custom:bool = recruitdata != null
	if randf() <= settings.custom_recruit_rate and filtered_recruits.size() > 0 and not recruitdata:
		recruit = filtered_recruits[randi()%filtered_recruits.size()]
		Mod.add_recruit_spawn(recruit)
		use_custom = true

	var recruitdata_node = npc.get_node("RecruitData")
	var char_config:Node = npc.get_node("EncounterConfig/CharacterConfig")
	var sidekick_config:Node = npc.get_node("EncounterConfig/Sidekick")
	var tape_nodes:Array = []

	recruit.name = name_generator.generate() if not use_custom else recruit.name

	for tape in char_config.get_children():
		tape_nodes.push_back(tape)
	for tape in sidekick_config.get_children():
		tape_nodes.push_back(tape)

	rangerdata.set_char_config(char_config,recruit,tape_nodes)
	sidekick_config.base_character = char_config.base_character
	rangerdata.set_npc_appearance(npc, recruit)

	if recruitdata_node and recruit:
		recruitdata_node.recruit = recruit

	return npc

static func engaged_recruits_nearby(encounter)->bool:
	var allow_recruits = get_setting("JoinEncounters")
	if !allow_recruits:
		return false
	var parent = encounter.get_parent()
	if !parent.has_node("ObjectData"):
		parent = parent.get_parent()
	if parent.has_node("ObjectData"):
		return !parent.get_node("ObjectData").is_empty()
	return false

static func add_extra_fighters(encounter):
	var parent = encounter.get_parent()
	if !parent.has_node("ObjectData"):
		parent = parent.get_parent()
	if parent.has_node("ObjectData"):
		for slot in parent.get_node("ObjectData").slots:
			if !slot.occupied:
				continue
			var newconfig = get_follower_config(slot.npc_data)
			encounter.add_child(newconfig)
			newconfig.add_to_group("trainee_allies")
			SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots += 1
static func add_follower_to_encounter(encounter):
	if has_active_follower():
		var newconfig = get_follower_config(get_current_follower())
		encounter.add_child(newconfig)
		newconfig.add_to_group("trainee_allies")

static func remove_old_configs(encounter):
	SaveState.other_data.LivingWorldData.ExtraEncounterConfig.extra_slots = 0
	for child in encounter.get_children():
		if child.is_in_group("trainee_allies"):
			encounter.remove_child(child)

static func set_warp_target(warp_target, subtarget_name, index):
	var newtarget = load("res://mods/LivingWorld/nodes/warptarget.tscn")
	if index > 1:
		if !warp_target.has_node("FollowerTarget") and warp_target.has_node("PartnerTarget"):
			var partner_target = warp_target.get_node("PartnerTarget")
			var follower_target = newtarget.instance()
			warp_target.add_child(follower_target)
			follower_target.transform = partner_target.transform
			follower_target.translation.x += 2
		subtarget_name = "FollowerTarget"
	return subtarget_name

static func add_spawner(region_name,level):
	var settings = load("res://mods/LivingWorld/settings.tres")
	var spawner_scene = load("res://mods/LivingWorld/nodes/RecruitSpawner.tscn")
	if settings.levelmap_spawners.has(region_name):
		for location in settings.levelmap_spawners[region_name].locations:
			if !level.has_node(location.name):
				print("adding %s to %s"%[location.name, region_name])
				var spawner = spawner_scene.instance()
				level.add_child(spawner)
				spawner.global_transform.origin = location.pos
				spawner.name = location.name
				spawner.ignore_visibility = location.ignore_visibility
				spawner.forced_personality = location.forced_personality
				spawner.supress_abilities = location.supress_abilities
#				yield(Co.wait(2),"completed")


