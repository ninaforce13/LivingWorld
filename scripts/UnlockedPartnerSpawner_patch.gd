static func patch():
	var script_path = "res://nodes/partners/UnlockedPartnerSpawner.gd"
	var patched_script : GDScript = preload("res://nodes/partners/UnlockedPartnerSpawner.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("	if get_tree().has_group(character.partner_id):")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("skip_partner_add"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["skip_partner_add"] = """
	var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	if manager.has_active_follower() and manager.get_follower_partner_id() == character.partner_id:
		return
	"""

	return code_blocks[block]

