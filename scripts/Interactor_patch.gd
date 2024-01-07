static func patch():
	var script_path = "res://world/player/Interactor.gd"
	var patched_script : GDScript = preload("res://world/player/Interactor.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("	pawn.sprite.scene.layers.set_flag(\"carrying\", true)")
	if code_index > 0:
		code_lines[code_index] = get_code("check_pawn1")

	code_index = code_lines.find("	pawn.sprite.scene.layers.set_flag(\"carrying\", false)")
	if code_index > 0:
		code_lines[code_index] = get_code("check_pawn2")
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["check_pawn1"] = """
	if pawn.sprite.scene.get("layers"):
		pawn.sprite.scene.layers.set_flag(\"carrying\", true)
	"""
	code_blocks["check_pawn2"] = """
	if pawn.sprite.scene.get("layers"):
		pawn.sprite.scene.layers.set_flag(\"carrying\", false)
	"""
	return code_blocks[block]


