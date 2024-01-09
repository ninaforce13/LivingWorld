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

	var code_index = code_lines.find("	if SaveState.party.is_partner_unlocked(SaveState.party.current_partner_id):")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("respawn_recruit"))


	code_index = code_lines.find("func set_region_settings(value:RegionSettings):")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_spawner"))

	code_lines.insert(code_lines.size()-1,get_code("setup_recruit_spawner"))

	code_index = code_lines.find("	var npc = WorldPlayerFactory.create_player(player_index)")
	if code_index > 0:
		code_lines[code_index] = get_code("change_player")

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


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["warp_recruit"] = """

	if npc_manager.has_active_follower() and !has_node("FollowerRecruit"):
		npc_manager.spawn_recruit(self, npc_manager.get_current_follower())
	if npc_manager.has_active_follower() and has_node("FollowerRecruit"):
		var custom_recruit = get_node("FollowerRecruit")
		warp_entities.push_back(custom_recruit)
	"""

	code_blocks["change_player"] = """
	var npc = create_modded_player(player_index)
	"""

	code_blocks["respawn_recruit"] = """
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	if npc_manager.has_active_follower() and !has_node("FollowerRecruit"):
		npc_manager.spawn_recruit(self, npc_manager.get_current_follower())
	"""

	code_blocks["add_spawner"] = """
	if value:
		call_deferred("setup_recruit_spawner",value.region_name)

	"""
	code_blocks["setup_recruit_spawner"] = """
func setup_recruit_spawner(current_regionname):
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	npc_manager.add_spawner(current_regionname,self)

func create_modded_player(player_index:int):
	var npc = preload("res://mods/LivingWorld/nodes/PlayerMonster.tscn").instance()
	npc.character = SaveState.party.characters[player_index]

	if player_index == 0:
		npc.name = "Player"
		npc.add_to_group("player_character")
	else :
		npc.name = "Partner"

	WorldPlayerFactory.set_npc_to_player(npc, player_index)
	return npc
	"""

	return code_blocks[block]

