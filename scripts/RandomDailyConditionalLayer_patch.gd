static func patch():
	var script_path = "res://world/core/RandomDailyConditionalLayer.gd"
	var patched_script : GDScript = preload("res://world/core/RandomDailyConditionalLayer.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name RandomDailyConditionalLayer")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func _check_conditions()->bool:")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("skip_spawn"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	RandomDailyConditionalLayer.source_code = patched_script.source_code
	var err = RandomDailyConditionalLayer.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["skip_spawn"] = """
	var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	if seed_value == "frankie_in_town_hall" and manager.has_active_follower() and manager.get_follower_partner_id() == "frankie":
		return false
	if seed_value == "vin_in_town_hall" and manager.has_active_follower() and manager.get_follower_partner_id() == "vin":
		return false
	"""

	return code_blocks[block]

