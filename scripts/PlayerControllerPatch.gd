static func patch():
	var script_path = "res://world/player/PlayerController.gd"
	var patched_script : GDScript = preload("res://world/player/PlayerController.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name PlayerController")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("	if event.is_action_pressed(\"interact\"):")
	if code_index > 0:
		code_lines.insert(code_index,get_code("add_key"))


	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	PlayerController.source_code = patched_script.source_code
	var err = PlayerController.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_key"] = """
	if event.is_action_pressed("livingworldmod_transform"):
		if pawn.has_method("player_transform"):
			pawn.player_transform()
	"""
	return code_blocks[block]


