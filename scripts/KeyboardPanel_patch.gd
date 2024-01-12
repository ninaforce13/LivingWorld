static func patch():
	var script_path = "res://menus/settings/KeyboardPanel.gd"
	var patched_script : GDScript = preload("res://menus/settings/KeyboardPanel.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("	reset()")
	if code_index > 0:
		code_lines.insert(code_index-1,get_code("add_input"))

	code_index = code_lines.find("	settings = KeyboardSettings.new()")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_setting_init"))
	code_index = code_lines.find("	settings = UserSettings.keyboard_settings.duplicate()")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_setting_init"))
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_input"] = """
	_add_heading("LIVINGWORLD_SETTINGS_UI_KEYBOARD_SECTION")
	_add_input("livingworldmod_transform")
	"""

	code_blocks["add_setting_init"] = """
	if !settings.map.has("livingworldmod_transform"):
		settings.map["livingworldmod_transform"] = [KEY_T]
	"""
	return code_blocks[block]


