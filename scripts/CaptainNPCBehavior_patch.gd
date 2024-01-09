static func patch():
	var script_path = "res://world/behaviors/generic_npc/CaptainNPCBehavior.gd"
	var patched_script : GDScript = preload("res://world/behaviors/generic_npc/CaptainNPCBehavior.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("func _ready():")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_mod_nodes"))

	code_lines.insert(code_lines.size()-1,get_code("new_functions"))
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_mod_nodes"] = """
	call_deferred("add_mod_data")
	"""
	code_blocks["new_functions"] = """
func add_mod_data():
	var CoinQuest = preload("res://data/quests/captain_quests/CaptainCleeOGetCoinQuest.tscn")
	var pawn = get_parent()
	if pawn.npc_name == "CAPTAIN_CLEEO_NAME" and !SaveState.quests.is_completed(CoinQuest):
		return
	if pawn.npc_name == "CAPTAIN_ZEDD_NAME":
		return
	var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	npcmanager.mod_pawns(pawn)
	"""
	return code_blocks[block]

