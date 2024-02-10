
static func has_active_follower()->bool:
	if not has_savedata():
		initialize_savedata()
	if DLC.mods_by_id.has("Ap7Dungeon"):
		var dungeondata = DLC.get_node("Ap7Dungeon/DungeonData")
		if dungeondata:
			var dungeon = dungeondata.get_current_dungeon()
			if dungeon != null:
				return false

	if SaveState.other_data.LivingWorldData.get("CurrentFollower"):
		return SaveState.other_data.LivingWorldData.CurrentFollower.active
	return false

static func get_partner_by_id(partner_id):
	var partners = get_partner_dictionary()
	return partners[partner_id]

static func get_follower_partner_id()->String:
	return SaveState.other_data.LivingWorldData.CurrentFollower.partner_id

static func get_current_follower()->Dictionary:
	return SaveState.other_data.LivingWorldData.CurrentFollower.recruit

static func is_follower_custom()->bool:
	return SaveState.other_data.LivingWorldData.CurrentFollower.custom

static func is_follower_partner()->bool:
	return SaveState.other_data.LivingWorldData.CurrentFollower.partner_id != ""

static func set_follower_custom(value:bool):
	SaveState.other_data.LivingWorldData.CurrentFollower.custom = value

static func set_follower(data:Dictionary,custom:bool,partner_id=""):
	SaveState.other_data.LivingWorldData.CurrentFollower = {"recruit":data, "active":true,"custom":custom, "partner_id":partner_id}

static func reset_follower():
	SaveState.other_data.LivingWorldData.CurrentFollower = {"recruit":{}, "active":false,"custom":false,"partner_id":""}

static func has_savedata()->bool:
	var result:int = 0
	if SaveState.other_data.has("LivingWorldData"):
		result += 1
		if SaveState.other_data.LivingWorldData.has("ExtraEncounterConfig"):
			result += 1
		if SaveState.other_data.LivingWorldData.has("CurrentFollower"):
			result += 1
			if SaveState.other_data.LivingWorldData.CurrentFollower.has("recruit"):
				result+=1
			if SaveState.other_data.LivingWorldData.CurrentFollower.has("active"):
				result+=1
			if SaveState.other_data.LivingWorldData.CurrentFollower.has("custom"):
				result+=1
			if SaveState.other_data.LivingWorldData.CurrentFollower.has("partner_id"):
				result+=1
		if SaveState.other_data.LivingWorldData.has("Transformations"):
			result += 1
			if SaveState.other_data.LivingWorldData.Transformations.has("player1"):
				result += 1
			if SaveState.other_data.LivingWorldData.Transformations.has("player2"):
				result += 1
		if SaveState.other_data.LivingWorldData.has("CardGame"):
			result+=1

	return result == 11

static func initialize_savedata():
	var collection = initialize_card_collection()
	SaveState.other_data["LivingWorldData"] = {"ExtraEncounterConfig":{"extra_slots":0},
												"CurrentFollower":{"recruit":{}, "active":false,"custom":false,"partner_id":""},
												"Transformations":{"player1":{"form_index":-1},"player2":{"form_index":-1}},
												"CardGame":{"collection":collection}}

static func initialize_card_collection()->Dictionary:
	var result:Dictionary = {}
	var random = Random.new(SaveState.random_seed)
	var item:Dictionary = {"path":"","amount":0,"deck":0,"bestiary_index":0}
	var basic_forms = MonsterForms.basic_forms.values()
	var debut_forms = MonsterForms.pre_evolution.values()
	var options:Array = []
	for i in range(20):
		options = debut_forms if i < 15 else basic_forms
		var form = random.choice(options)
		var key = Loc.tr(form.name).to_lower()
		if result.has(key):
			result[key].deck += 1
			continue
		item.path = form.resource_path
		item.amount = 0
		item.deck = 1
		item.bestiary_index = form.bestiary_index
		result[key] = item.duplicate()
	return result

static func get_card_collection()->Dictionary:
	var result:Dictionary
	return SaveState.other_data.LivingWorldData.CardGame.collection

static func add_card_to_collection(card):
	var key = get_card_key(card)
	var collection = get_card_collection()
	if has_card(card):
		collection[key].amount += 1
	else:
		collection[key] = set_card_data(card)

static func has_card(card_data)->bool:
	var key = get_card_key(card_data)
	var collection = get_card_collection()
	return collection.has(key)

static func get_card_key(card_data)->String:
	var form = load(card_data.form)
	var key = str(Loc.tr(form.name)).to_lower()
	return key

static func set_card_data(card_data)->Dictionary:
	var form = load(card_data.form)
	var result:Dictionary = {
		"path":card_data.form,
		"amount":1,
		"deck":0,
		"bestiary_index":form.bestiary_index
		}
	return result

static func get_setting(setting_name):
	var config:ConfigFile = _load_settings_file()
	var value
	if setting_name == "JoinEncounters":
		value = config.get_value("battle","join_raids",true)
	if setting_name == "MagnetismEnabled":
		value = config.get_value("behavior","magnetism",true)
	if setting_name == "NPCPopulation":
		value = config.get_value("world","population",1)
	if setting_name == "CaptainPatrol":
		value = config.get_value("behavior","captain_patrol",true)
	if setting_name == "CustomTrainees":
		value = config.get_value("world","custom_trainee",true)
	if setting_name == "BackupStatus":
		value = config.get_value("battle","backup_status",true)
	if setting_name == "BattleSprite":
		value = config.get_value("world","battle_sprite",false)
	if setting_name == "EnemyCardThought":
		value = config.get_value("card","enemy_thinking",true)
	return value

static func _load_settings_file()->ConfigFile:
	var settings_path = "user://LivingWorldSettings.cfg"
	var config = ConfigFile.new()
	var file = File.new()
	if file.file_exists(settings_path):
		if config.load(settings_path) != OK:
			push_error("Unable to load settings file " + settings_path)
	return config

static func get_follower_config(other_recruit):
	var ai_nostatus = preload("res://mods/LivingWorld/nodes/RecruitAINoStatus.tscn")
	var ai_status = preload("res://mods/LivingWorld/nodes/RecruitAI.tscn")
	var recruit = other_recruit
	var mod = DLC.mods_by_id["LivingWorldMod"]
	var new_config = mod.empty_charconfig.instance()
	var rangerdata = mod.rangerdataparser
	new_config.team = 0
	var tape_nodes:Array = []
	for tape in new_config.get_children():
		tape_nodes.push_back(tape)
	rangerdata.set_char_config(new_config,recruit,tape_nodes)
	new_config.name = "FollowerConfig"
	var status:bool = get_setting("BackupStatus")
	new_config.ai = ai_status if status else ai_nostatus
	return new_config

static func add_battle_slots(battlebackground):
	if !has_savedata():
		initialize_savedata()
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
	var mod = DLC.mods_by_id["LivingWorldMod"]
	var rangerdata = mod.rangerdataparser
	var PartnerController = mod.partnercontroller
	var FollowerTemplate = mod.followertemplate
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
	template.get_data().recruit = current_recruit
	return template

static func is_idle_partner_available(partner_names,idle_partners)->bool:
	if idle_partners.empty():
		return true
	partner_names = filter_partners(partner_names,idle_partners)
	if partner_names.empty():
		return false
	return true

static func get_partner_names(quests:Dictionary)->Array:
	var result:Array = []
	if SaveState.quests.is_completed(quests.frankie):
		result.push_back("vin")
		result.push_back("frankie")
	if SaveState.quests.is_completed(quests.sunny):
		result.push_back("sunny")
	result.push_back("kayleigh")
	result.push_back("meredith")
	result.push_back("viola")
	result.push_back("eugene")
	result.push_back("felix")
	result.push_back("dog")

	return result

static func remove_duplicate_partner():
	var level = WorldSystem.get_level_map()
	var idle_partners = level.get_tree().get_nodes_in_group("idle_partners")
	var current_partner = SaveState.party.get_partner()
	for npc in idle_partners:
		if npc.character.partner_id == current_partner.partner_id:
			npc.get_parent().remove_child(npc)
			npc.queue_free()

static func is_true_partner(partner_id)->bool:
	if partner_id == "vin":
		return false
	if partner_id == "frankie":
		return false
	if partner_id == "sunny":
		return false
	return true

static func filter_partners(options:Array,idle_partners)->Array:
	var result:Array = options.duplicate()
	var current_partner = SaveState.party.get_partner()
	result.erase(current_partner.partner_id)
	if is_follower_partner():
		result.erase(get_follower_partner_id())
	for item in result:
		if is_true_partner(item) and !SaveState.party.is_partner_unlocked(item):
			result.erase(item)
	for partner in idle_partners:
		if options.has(partner.character.partner_id):
			result.erase(partner.character.partner_id)
	return result

static func get_partner_dictionary()->Dictionary:
	var mod = DLC.mods_by_id["LivingWorldMod"]
	return mod.partners

static func create_npc(forced_personality,supress_abilities):
	var random = Random.new()
	var level = WorldSystem.get_level_map()
	var idle_partners = level.get_tree().get_nodes_in_group("idle_partners")
	var settings = preload("res://mods/LivingWorld/settings.tres")
	var frankie_quest = preload("res://data/quests/noticeboard/FrankieAndVinQuest.tscn")
	var sunny_quest = preload("res://data/quests/sidequests/SunnyQuest.tscn")
	var quests:Dictionary = {"frankie":frankie_quest,"sunny":sunny_quest}
	var partner_names = get_partner_names(quests)
	var recruit
	if partner_can_spawn(random,settings,partner_names,idle_partners):
		var options = filter_partners(partner_names,idle_partners)
		var partners = get_partner_dictionary()
		random.shuffle(options)
		var selection = random.choice(options)
		recruit = partners[selection].instance()
	else:
		recruit = get_npc(null,random)

	var behavior = recruit.get_behavior()
	behavior.personality = forced_personality if forced_personality >= 0 else random.rand_int(behavior.PERSONALITY.size())
	recruit.supress_abilities = supress_abilities

	return recruit

static func get_data_from_npc(npc):
	var mod = DLC.mods_by_id["LivingWorldMod"]
	var recruitdata = mod.rangerdataparser.get_empty_recruit()
	if npc.npc_name != "":
		recruitdata.name = npc.npc_name
	recruitdata.human_part_names = to_json(npc.sprite_part_names)
	recruitdata.human_colors = to_json(npc.sprite_colors)
	if npc.character:
		recruitdata.stats = npc.character.get_snapshot()
	if npc.has_node("EncounterConfig"):
		var encounter = npc.get_node("EncounterConfig")
		var characters = encounter.get_character_nodes()
		var tapes = []
		var index:int = 0
		for c in characters:
			for tape in c.get_tape_nodes():
				var newtape = tape._generate_tape(Random.new(),0)
				recruitdata["tape"+str(index)] = newtape.get_snapshot()
				index+=1
	return recruitdata

static func get_unlocked_partners_id()->Array:
	return SaveState.party.unlocked_partners


static func filter_custom_recruits(recruits)->Array:
	var result:Array = []
	var current_follower:Dictionary = get_current_follower() if has_active_follower() else {}
	var level = WorldSystem.get_level_map()
	var grouped_recruits:Array = level.get_tree().get_nodes_in_group("custom_recruits")
	result = recruits.duplicate()
	var orig_count = result.size()
	if !current_follower.empty():
		for item in result:
			if compare_dictionaries(item,current_follower):
				result.erase(item)

	for recruit in grouped_recruits:
		var data = recruit.get_data().recruit
		for item in result:
			if compare_dictionaries(item,data):
				result.erase(item)
	var diff = orig_count - result.size()
	return result

static func compare_dictionaries(data_a:Dictionary,data_b:Dictionary)->bool:
	for key in data_a:
		if !data_b.has(key):
			return false
		if typeof(data_a[key]) == TYPE_DICTIONARY and typeof(data_b[key]) == TYPE_DICTIONARY:
			if !compare_dictionaries(data_a[key],data_b[key]):
				return false
		elif typeof(data_a[key]) == TYPE_ARRAY and typeof(data_b[key]) == TYPE_ARRAY:
			if !compare_arrays(data_a[key],data_b[key]):
				return false
		elif data_a[key] != data_b[key]:
			return false
	return true

static func compare_arrays(array1:Array,array2:Array)->bool:
	if array1.size() != array2.size():
		return false
	for i in range (0,array1.size()):
		if typeof(array1[i]) == TYPE_DICTIONARY and typeof(array2[i]) == TYPE_DICTIONARY:
			if !compare_dictionaries(array1[i],array2[i]):
				return false
		elif typeof(array1[i]) == TYPE_ARRAY and typeof(array2[i]) == TYPE_ARRAY:
			if !compare_arrays(array1[i],array2[i]):
				return false
		elif array1[i] != array2[i]:
			return false
	return true

static func recruit_can_spawn()->bool:
	var mod = DLC.mods_by_id["LivingWorldMod"]
	if !get_setting("CustomTrainees"):
		return false
	var random = Random.new()
	var result:bool = random.rand_bool(mod.settings.custom_recruit_rate)
	return result

static func partner_can_spawn(random:Random,settings,partner_names,idle_partners)->bool:
	if not is_idle_partner_available(partner_names,idle_partners):
		return false
	var result:bool = random.rand_bool(settings.partner_rate)
	return result

static func get_npc(recruitdata=null,random = Random.new()):
	var mod = DLC.mods_by_id["LivingWorldMod"]
	var name_generator = preload("res://mods/LivingWorld/scripts/NameGenerator.gd")
	var rangerdata = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var npc_template = mod.npc_template

	var datapath = rangerdata.get_directory()
	var files:Array = rangerdata.get_files(datapath)
	var custom_recruits:Array = rangerdata.read_json(files)
	var recruit = rangerdata.get_empty_recruit() if recruitdata == null else recruitdata
	var npc = npc_template.instance()
	var filtered_recruits = filter_custom_recruits(custom_recruits)
	var use_custom:bool = recruitdata != null

	if recruit_can_spawn() and not filtered_recruits.empty() and not recruitdata:
		recruit = random.choice(filtered_recruits)
		npc.add_to_group("custom_recruits")
		use_custom = true

	var recruitdata_node = npc.get_data()
	var char_config:Node = npc.get_node("EncounterConfig/CharacterConfig")
	var tape_nodes:Array = []

	recruit.name = name_generator.generate() if not use_custom else recruit.name

	for tape in char_config.get_children():
		tape_nodes.push_back(tape)

	rangerdata.set_char_config(char_config,recruit,tape_nodes)
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
	var newtarget = DLC.mods_by_id["LivingWorldMod"].warptarget_template
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
	var mod = DLC.mods_by_id["LivingWorldMod"]
	var settings = mod.settings
	var spawner_scene = mod.spawner
	if settings.levelmap_spawners.has(region_name):
		for location in settings.levelmap_spawners[region_name].locations:
			if !level.has_node(location.name):
				var spawner = spawner_scene.instance()
				spawner.get_child(0).ignore_visibility = location.ignore_visibility
				spawner.get_child(0).forced_personality = location.forced_personality
				spawner.get_child(0).supress_abilities = location.supress_abilities
				level.add_child(spawner)
				spawner.global_transform.origin = location.pos
				spawner.name = location.name


static func mod_pawns(pawn):
	if !pawn.has_node("RecruitData") or !pawn.has_node("RecruitBehavior"):
		var datanode = preload("res://mods/LivingWorld/nodes/RecruitData.tscn").instance()
		var behaviornode = preload("res://mods/LivingWorld/behaviors/captain_behavior.tscn").instance()

		datanode.is_captain = true
		pawn.add_child(datanode)
		pawn.add_child(behaviornode)

static func is_player_transformed(playerindex=0)->bool:
	if !has_savedata():
		initialize_savedata()
	if playerindex == 1:
		return SaveState.other_data.LivingWorldData.Transformations.player2.form_index != -1

	return SaveState.other_data.LivingWorldData.Transformations.player1.form_index != -1
static func set_player_form(npc,playerindex = 0):
	if playerindex == 0:
		npc.swap_sprite(1,SaveState.other_data.LivingWorldData.Transformations.player1.form_index)
	if playerindex == 1:
		npc.swap_sprite(1,SaveState.other_data.LivingWorldData.Transformations.player2.form_index)

static func set_transformation_index(index,playerindex = 0):
	if !has_savedata():
		initialize_savedata()
	if playerindex == 0:
		SaveState.other_data.LivingWorldData.Transformations.player1.form_index = index
	if playerindex == 1:
		SaveState.other_data.LivingWorldData.Transformations.player2.form_index = index

static func get_transformation_index(playerindex = 0)->int:
	if !has_savedata():
		initialize_savedata()
	var index:int = -1
	if playerindex == 0:
		index = SaveState.other_data.LivingWorldData.Transformations.player1.form_index
	if playerindex == 1:
		index = SaveState.other_data.LivingWorldData.Transformations.player2.form_index
	return index

