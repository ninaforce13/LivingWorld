static func patch():
	var script_path = "res://nodes/encounter_config/EncounterConfig.gd"
	var patched_script : GDScript = preload("res://nodes/encounter_config/EncounterConfig.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")
	var class_name_index = code_lines.find("class_name EncounterConfig")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func get_config():")
	if code_index >= 0:
		code_lines.insert(code_index+1,get_code("add_follower"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	EncounterConfig.source_code = patched_script.source_code
	var err = EncounterConfig.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_follower"] = """
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	npc_manager.remove_old_configs(self)
	if (add_characters & AddCharacters.PLAYER) != 0:
		if npc_manager.engaged_recruits_nearby(self):
			npc_manager.add_extra_fighters(self)

		npc_manager.add_follower_to_encounter(self)
	"""
	return code_blocks[block]

