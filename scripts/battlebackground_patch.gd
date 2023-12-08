static func patch():
	var script_path = "res://battle/backgrounds/BattleBackground.gd"
	var patched_script : GDScript = preload("res://battle/backgrounds/BattleBackground.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path) 
			return
		patched_script.source_code = file.get_as_text()
		file.close()
	
	var code_lines:Array = patched_script.source_code.split("\n")		
	
	var code_index = code_lines.find("		orig_fog_color = environment.fog_color")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_battleslot"))

		
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return
	print("Patched %s successfully." % script_path)
	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_battleslot"] = """
	if SaveState.other_data.has("follower"):
		if SaveState.other_data.follower.active:
			var player1slot = get_node("BattleSlotPlayer1")
			var enemy1slot = get_node("BattleSlotEnemy1")
			var player2slot = get_node("BattleSlotPlayer2")
			var enemy3slot = get_node("BattleSlotEnemy3")
			var followerslot = preload("res://mods/RangerArena/BattleSlotFollower.tscn").instance()
			var extra_enemy_slot = preload("res://mods/RangerArena/BattleSlotEnemy.tscn").instance()
			add_child_below_node(player2slot, followerslot)
			add_child_below_node(enemy3slot, extra_enemy_slot)
			followerslot.translation = player1slot.translation + Vector3(-12, 0,0)
			extra_enemy_slot.translation = enemy1slot.translation + Vector3(12, 0,0)
	"""
	return code_blocks[block]


