static func patch():
	var script_path = "res://world/behaviors/generic_npc/BattleNPCBehavior.gd"
	var patched_script : GDScript = preload("res://world/behaviors/generic_npc/BattleNPCBehavior.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("		if on_defeat == 2 or on_defeat == 3 or on_defeat == 4:")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("convert_npc3"))
	code_index = code_lines.find("		if on_defeat == 2 or on_defeat == 3 or on_defeat == 4:")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("convert_npc1"))

	code_index = code_lines.find("func _on_defeated():")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("convert_npc2"))

	code_lines.insert(code_lines.size()-1,get_code("add_function"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["convert_npc1"] = """
			convert_npc()
	"""
	code_blocks["convert_npc2"] = """
	convert_npc()
	"""
	code_blocks["convert_npc3"] = """
		if on_defeat == 0:
			convert_npc()
			pawn.visible = false
			pawn.queue_free()
			return
	"""
	code_blocks["add_function"] = """
func convert_npc():
	var pawn = get_pawn()
	var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
	var recruitdata = npcmanager.get_data_from_npc(pawn)
	var npc = npcmanager.get_npc(recruitdata)
	if !npc.has_node("RecruitBehavior"):
		var new_behavior = load("res://mods/LivingWorld/nodes/recruitbehavior.tscn").instance()
		npc.add_child(new_behavior)
	var behavior = npc.get_behavior()
	npc.transform = pawn.transform
	pawn.get_parent().add_child(npc)
	npc.global_transform.origin = pawn.global_transform.origin
	pawn.visible = false
	npc.spawn_point = pawn.global_transform.origin
	"""
	return code_blocks[block]

