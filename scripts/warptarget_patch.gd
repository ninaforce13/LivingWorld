static func patch():
	var script_path = "res://nodes/warp_region/WarpTarget.gd"
	var patched_script : GDScript = preload("res://nodes/warp_region/WarpTarget.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name WarpTarget")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("	var subtarget_name = \"PlayerTarget\" if index == 0 else \"PartnerTarget\"")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_warp_target"))


	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	WarpTarget.source_code = patched_script.source_code
	var err = WarpTarget.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_warp_target"] = """
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	subtarget_name = npc_manager.set_warp_target(warp_target, subtarget_name, index)
	"""
	return code_blocks[block]

