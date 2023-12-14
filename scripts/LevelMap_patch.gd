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
	
#
#	code_index = code_lines.find("	if warp_target:")
#	if code_index > 0:
#		code_lines.insert(code_index-1,get_code("warp_recruit")) 

	
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
	
	if npc_manager.has_active_follower() and !has_node("CustomTrainee"):
		npc_manager.spawn_recruit(self, SaveState.other_data.follower.recruit)
	if npc_manager.has_active_follower() and has_node("CustomTrainee"):
		var custom_recruit = get_node("CustomTrainee")
		warp_entities.push_back(custom_recruit)
	"""
	
	code_blocks["respawn_recruit"] = """
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	if npc_manager.has_active_follower() and !has_node("CustomTrainee"):
		npc_manager.spawn_recruit(self, SaveState.other_data.follower.recruit)
	"""
	
	code_blocks["add_spawner"] = """

	call_deferred("check_for_spawner",preload("res://mods/LivingWorld/nodes/RecruitSpawner.tscn").instance())

	"""
	
	return code_blocks[block]

