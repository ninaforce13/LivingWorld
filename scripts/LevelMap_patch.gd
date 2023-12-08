static func patch():
	var script_path = "res://world/core/LevelMap.gd"
	var patched_script : GDScript = preload("res://world/core/LevelMap.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path) 
			return
		patched_script.source_code = file.get_as_text()
		file.close()
	
	var code_lines:Array = patched_script.source_code.split("\n")		
	
	var class_name_index = code_lines.find("class_name LevelMap")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)		
		
	code_lines[code_lines.size()-1] = get_code("spawn_recruit")
	
	var code_index = code_lines.find("	if SaveState.party.is_partner_unlocked(SaveState.party.current_partner_id):")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("respawn_recruit"))
	
	code_index = code_lines.find("	if warp_target:")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("warp_recruit")) 
		
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	LevelMap.source_code = patched_script.source_code
	var err = LevelMap.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return
	print("Patched %s successfully." % script_path)
	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["warp_recruit"] = """
	if SaveState.other_data.has("follower"):
		if SaveState.other_data.follower.active and !has_node("CustomTrainee"):
			spawn_recruit(SaveState.other_data.follower.recruit)
		if SaveState.other_data.follower.active and has_node("CustomTrainee"):
			var custom_recruit = get_node("CustomTrainee")
			warp_entities.push_back(custom_recruit)
	"""
	
	code_blocks["respawn_recruit"] = """
	if SaveState.other_data.has("follower"):
		if SaveState.other_data.follower.active and !has_node("CustomTrainee"):
			spawn_recruit(SaveState.other_data.follower.recruit)
	"""
	code_blocks["spawn_recruit"] = """
func spawn_recruit(current_recruit = null):	
	var rangerdata = load("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var datapath = rangerdata.get_directory()
	var files:Array = rangerdata.get_files(datapath)	
	var recruits:Array = rangerdata.read_json(files)	
	var recruit = recruits[randi()%recruits.size()]	if current_recruit == null else current_recruit	
	var PartnerController = load("res://nodes/partners/PartnerController.tscn")	
	var player
	if has_node("Player"):
		player = get_node("Player")	
	var npc = preload("res://mods/LivingWorld/nodes/RecruitTemplate.tscn").instance()	
	if not npc.has_node(NodePath("PartnerController")):
		var controller = PartnerController.instance()
		controller.min_distance = 6
		controller.max_distance = 8
		npc.never_pause = true
		controller.name = "PartnerController"
		npc.add_child(controller, true)
	if recruit:
		var tape1 = npc.get_node("EncounterConfig/CharacterConfig/SignatureTape")
		var tape2 = npc.get_node("EncounterConfig/CharacterConfig/RandomTapeConfig")
		var tape3 = npc.get_node("EncounterConfig/CharacterConfig/RandomTapeConfig2")
		var char_config:Node = npc.get_node("EncounterConfig/CharacterConfig")
		char_config.character_name = recruit.name
		char_config.pronouns = recruit.pronouns
		char_config.team = 0
		var char_stats:Character = Character.new()
		if recruit.has("stats"):
			if recruit["stats"].size() > 0:
				char_stats.set_snapshot(recruit["stats"],1)
			
		char_config.base_character = char_stats
		if not recruit.has("stats"):
			char_config.base_character.base_max_hp = 120
		var index:int = 0
		for key in recruit:
			if str(key) == "tape"+str(index):
				if recruit[key].favorite:
					tape1.tape_snapshot = recruit[key]
					var snapshot = rangerdata.get_custom_monster(recruit[key])
					var form = load(snapshot.form)
					if form:
						char_config.base_character.partner_signature_species = form
				else:
					tape2.monster_profile.push_back(recruit[key])
					tape3.monster_profile.push_back(recruit[key])
				index += 1 
		npc.sprite_part_names = JSON.parse(recruit.human_part_names).result
		npc.sprite_colors = JSON.parse(recruit.human_colors).result
		char_config.human_part_names = JSON.parse(recruit.human_part_names).result
		char_config.human_colors = JSON.parse(recruit.human_colors).result
		npc.pronouns = recruit.pronouns
		npc.npc_name = recruit.name
	add_child(npc, true)
	npc.warp_near(player.global_transform.origin, false)
	
	SaveState.other_data["follower"] = {"recruit":recruit, "active":true}	
		"""
	return code_blocks[block]

