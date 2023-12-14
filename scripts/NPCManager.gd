
static func has_active_follower()->bool:
	if SaveState.other_data.get("follower"):
		return SaveState.other_data.follower.active
	return false

static func is_current_follower(recruit)->bool:
	return SaveState.other_data.follower.recruit == recruit

static func get_follower_config(other_recruit = null):				
	var recruit = SaveState.other_data.follower.recruit if other_recruit == null else other_recruit
	var new_config = preload("res://mods/LivingWorld/nodes/empty_charconfig.tscn").instance()
	new_config.character_name = recruit.name
	new_config.team = 0
	var char_stats:Character = Character.new()
	new_config.base_character = char_stats
	new_config.base_character.base_max_hp = 120
	new_config.name = "FollowerConfig"
	new_config.copy_human_sprite = ""
	var colors:Dictionary = recruit.human_colors if typeof( recruit.human_colors) == TYPE_DICTIONARY else JSON.parse(recruit.human_colors).result
	var parts:Dictionary = recruit.human_part_names if typeof(recruit.human_part_names) == TYPE_DICTIONARY else JSON.parse(recruit.human_part_names).result				
	new_config.human_part_names = parts
	new_config.human_colors = colors	
	return new_config
	
static func add_battle_slots(battlebackground):
	if !SaveState.other_data.has("ExtraEncounterConfig"):
		SaveState.other_data["ExtraEncounterConfig"] = {"extra_slots":0}
	if SaveState.other_data.ExtraEncounterConfig.extra_slots <= 0:
		return
	if SaveState.other_data.ExtraEncounterConfig.extra_slots > 3:
		SaveState.other_data.ExtraEncounterConfig.extra_slots = 3
	var player1slot = battlebackground.get_node("BattleSlotPlayer1") if battlebackground.has_node("BattleSlotPlayer1") else null
	var player2slot = battlebackground.get_node("BattleSlotPlayer2") if battlebackground.has_node("BattleSlotPlayer2") else null
	var player3slot = battlebackground.get_node("BattleSlotPlayer3") if battlebackground.has_node("BattleSlotPlayer3") else null
	var enemy1slot = battlebackground.get_node("BattleSlotEnemy1") if battlebackground.has_node("BattleSlotEnemy1") else null
	var enemy2slot = battlebackground.get_node("BattleSlotEnemy2") if battlebackground.has_node("BattleSlotEnemy2") else null
	var enemy3slot = battlebackground.get_node("BattleSlotEnemy3") if battlebackground.has_node("BattleSlotEnemy3") else null
	if not player1slot:
		return
	var index:int
	for i in range (0, SaveState.other_data.ExtraEncounterConfig.extra_slots):			
		var followerslot = preload("res://mods/LivingWorld/nodes/BattleSlotFollower.tscn").instance()
		var extra_enemy_slot = preload("res://mods/LivingWorld/nodes/BattleSlotEnemy.tscn").instance()
			
		var translation_slot = player1slot
		var enemytranslation_slot = enemy1slot
		if index == 1:
			translation_slot = player2slot
			enemytranslation_slot = enemy2slot
		if index == 2:
			translation_slot = player3slot	
			enemytranslation_slot = enemy3slot
		battlebackground.add_child_below_node(player2slot, followerslot)
		battlebackground.add_child_below_node(enemy2slot, extra_enemy_slot)
		followerslot.translation = translation_slot.translation + Vector3(-12 +(4*index), 0,0)
		extra_enemy_slot.translation = enemytranslation_slot.translation + Vector3(12-(4*index), 0,0)	
		index+=1

static func spawn_recruit(levelmap, current_recruit = null):	
	var recruitdata_node	
	var rangerdata = load("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var datapath = rangerdata.get_directory()
	var files:Array = rangerdata.get_files(datapath)	
	var recruits:Array = rangerdata.read_json(files)	
	var recruit = recruits[randi()%recruits.size()]	if current_recruit == null else current_recruit	
	var PartnerController = load("res://nodes/partners/PartnerController.tscn")	
	var player
	if levelmap.has_node("Player"):
		player = levelmap.get_node("Player")	
	var npc = preload("res://mods/LivingWorld/nodes/RecruitTemplate.tscn").instance()	
	if not npc.has_node(NodePath("PartnerController")):
		var controller = PartnerController.instance()
		controller.min_distance = 6
		controller.max_distance = 8
		npc.never_pause = true
		controller.name = "PartnerController"
		npc.add_child(controller, true)
	if recruit:
		var char_config:Node = npc.get_node("EncounterConfig/CharacterConfig")
		char_config.character_name = recruit.name
		char_config.pronouns = recruit.pronouns
		char_config.team = 0
		var char_stats:Character = Character.new()
			
		char_config.base_character = char_stats
		char_config.base_character.base_max_hp = 120
		var colors:Dictionary = recruit.human_colors if typeof(recruit.human_colors) == TYPE_DICTIONARY else JSON.parse(recruit.human_colors).result
		var parts:Dictionary = recruit.human_part_names if typeof(recruit.human_part_names) == TYPE_DICTIONARY else JSON.parse(recruit.human_part_names).result				
		npc.sprite_part_names = parts
		npc.sprite_colors = colors
		char_config.human_part_names = parts
		char_config.human_colors = colors
		npc.pronouns = recruit.pronouns
		npc.npc_name = recruit.name
	levelmap.add_child(npc, true)
	npc.warp_near(player.global_transform.origin, false)
	if recruitdata_node:
		recruitdata_node.recruit = recruit
	SaveState.other_data["follower"] = {"recruit":recruit, "active":true}
	return npc
	
static func create_npc(spawner, node):	
	var recruit = get_npc()
	var monbehavior = preload("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
	recruit.add_child(monbehavior)
	recruit.transform = node.transform
	spawner.get_parent().add_child(recruit)
	if UserSettings.graphics_world_streaming == 0 and recruit.has_method("beam_in"):
		recruit.beam_in()
	
	if recruit is KinematicBody:
		var orig_xform = recruit.transform
		var collision = recruit.move_and_collide(Vector3(0, - 100, 0), false)
		if not collision:
			recruit.transform = orig_xform	

	return recruit
static func get_npc():
	var rangerdata = load("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var datapath = rangerdata.get_directory()
	var files:Array = rangerdata.get_files(datapath)	
#	var recruits:Array = rangerdata.read_json(files)	
#	var recruit = recruits[randi()%recruits.size()]	
	var recruit = rangerdata.get_empty_recruit()
	var npc = preload("res://mods/LivingWorld/nodes/RecruitTemplate.tscn").instance()	
	if recruit:
		var recruitdata_node = npc.get_node("RecruitData")
		var char_config:Node = npc.get_node("EncounterConfig/CharacterConfig")
		char_config.character_name = recruit.name
		char_config.pronouns = recruit.pronouns
		char_config.team = 0
		var char_stats:Character = Character.new()
			
		char_config.base_character = char_stats
		char_config.base_character.base_max_hp = 120		
		npc.sprite_part_names = recruit.human_part_names if typeof(recruit.human_part_names) == TYPE_DICTIONARY else JSON.parse(recruit.human_part_names).result
		npc.sprite_colors = recruit.human_colors if typeof(recruit.human_colors) == TYPE_DICTIONARY else JSON.parse(recruit.human_colors).result
		char_config.human_part_names = recruit.human_part_names if typeof(recruit.human_part_names) == TYPE_DICTIONARY else JSON.parse(recruit.human_part_names).result
		char_config.human_colors = recruit.human_colors if typeof(recruit.human_colors) == TYPE_DICTIONARY else JSON.parse(recruit.human_colors).result
		npc.pronouns = recruit.pronouns
		npc.npc_name = recruit.name
		
		recruitdata_node.recruit = recruit
	
	return npc	

static func engaged_recruits_nearby(encounter)->bool:
	var parent = encounter.get_parent().get_parent()
	if parent.has_node("RecruitData"):
		return parent.get_node("RecruitData").occupants.size() > 0
	return false

static func add_extra_fighters(encounter):
	var parent = encounter.get_parent().get_parent()
	if parent.has_node("RecruitData"):
		for recruit in parent.get_node("RecruitData").occupants:
			var newconfig = get_follower_config(recruit)
			encounter.add_child(newconfig)		
			newconfig.add_to_group("trainee_allies")
			if !SaveState.other_data.has("ExtraEncounterConfig"):
				SaveState.other_data["ExtraEncounterConfig"] = {"extra_slots":0}
			SaveState.other_data.ExtraEncounterConfig.extra_slots += 1

static func remove_old_configs(encounter):
	SaveState.other_data["ExtraEncounterConfig"] = {"extra_slots":0}
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
