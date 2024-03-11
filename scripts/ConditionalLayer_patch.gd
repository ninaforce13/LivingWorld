static func patch():
	var script_path = "res://world/core/ConditionalLayer.gd"
	var patched_script : GDScript = preload("res://world/core/ConditionalLayer.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name ConditionalLayer")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func _check_conditions()->bool:")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_sunny_check"))


	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	ConditionalLayer.source_code = patched_script.source_code
	var err = ConditionalLayer.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_sunny_check"] = """
	var sunny_quest = preload("res://data/quests/sidequests/SunnyQuest.tscn")
	if require_quest == sunny_quest and SaveState.quests.is_completed(sunny_quest) and name != "ConditionalLayer_EugeneSunnyDate":
		if !require_flags.has("livingworld_blocked"):
			require_flags.push_back("livingworld_blocked")
	else:
		if require_flags.has("livingworld_blocked"):
			require_flags.erase("livingworld_blocked")
	"""

	return code_blocks[block]

