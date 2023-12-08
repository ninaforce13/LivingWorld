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
	print("Patched %s successfully." % script_path)
	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_follower"] = """
	if SaveState.other_data.get("follower"):
		if SaveState.other_data.follower.active:
			var level_map = WorldSystem.get_level_map()
			if level_map:
				var charconfig = level_map.get_node("CustomTrainee/EncounterConfig/CharacterConfig")

				if charconfig and !has_node("FollowerConfig"):
					var new_config = preload("res://mods/LivingWorld/nodes/empty_charconfig.tscn").instance()									
					new_config = charconfig.duplicate()
					new_config.name = "FollowerConfig"
					new_config.copy_human_sprite = ""
					new_config.human_colors = charconfig.human_colors
					new_config.human_part_names = charconfig.human_part_names
					
					var sigtape = new_config.get_node("SignatureTape")
					sigtape = level_map.get_node("CustomTrainee/EncounterConfig/CharacterConfig/SignatureTape").duplicate()
					var randtape1 = new_config.get_node("RandomTapeConfig")
					randtape1 = level_map.get_node("CustomTrainee/EncounterConfig/CharacterConfig/RandomTapeConfig").duplicate()
					var randtape2 = new_config.get_node("RandomTapeConfig2")
					randtape2 = level_map.get_node("CustomTrainee/EncounterConfig/CharacterConfig/RandomTapeConfig2").duplicate()						
					add_child(new_config)	
	"""
	return code_blocks[block]

