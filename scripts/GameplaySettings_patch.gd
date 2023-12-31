static func patch():
	var script_path = "res://menus/settings/GameplayPanel.gd"
	var patched_script : GDScript = preload("res://menus/settings/GameplayPanel.gd")

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
		code_lines.insert(code_index+1,get_code("add_inputs"))
		code_lines.insert(code_index-1,get_code("add_global_vars"))

	code_index = code_lines.find("	UserSettings.ai_smartness = ai_smartness_input.selected_value")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_save"))
	code_index = code_lines.find("func is_dirty()->bool:")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_dirty_check"))

	code_lines.insert(code_lines.size()-1,get_code("add_functions"))
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_global_vars"] = """
var join_encounters_input
var use_magnetism_input
var modmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	"""

	code_blocks["add_save"] = """
	save_mod_settings()
	"""

	code_blocks["add_inputs"] = """
	add_mod_fields()
	"""

	code_blocks["add_dirty_check"] = """
	if modmanager.has_savedata():
		if join_encounters_input.selected_value != SaveState.other_data.LivingWorldData.Settings.JoinEncounters:
			return true
		if use_magnetism_input.selected_value != SaveState.other_data.LivingWorldData.Settings.MagnetismEnabled:
			return true
	"""

	code_blocks["add_functions"] = """
func add_mod_fields():
	if inputs:
		var autosavelbl = inputs.get_node("AutosaveLabel")
		var autosaveinput = inputs.get_node("AutosaveInput")
		join_encounters_input = preload("res://nodes/menus/ArrowOptionList.tscn").instance()
		use_magnetism_input = preload("res://nodes/menus/ArrowOptionList.tscn").instance()
		var join_encounters_label = Label.new()
		var use_magnetism_label = Label.new()
		join_encounters_label = autosavelbl.duplicate()
		use_magnetism_label = autosavelbl.duplicate()
		join_encounters_label.text = "LIVINGWORLD_SETTINGS_UI_ENCOUNTERS"
		use_magnetism_label.text = "LIVINGWORLD_SETTINGS_UI_MAGNETISM"
		join_encounters_input.values.push_back(true)
		use_magnetism_input.values.push_back(true)
		join_encounters_input.values.push_back(false)
		use_magnetism_input.values.push_back(false)
		join_encounters_input.value_labels.push_back("Enabled")
		use_magnetism_input.value_labels.push_back("Enabled")
		join_encounters_input.value_labels.push_back("Disabled")
		use_magnetism_input.value_labels.push_back("Disabled")
		inputs.add_child_below_node(inputs.get_node("VibrationInput"),join_encounters_label)
		inputs.add_child_below_node(inputs.get_node("VibrationInput"),use_magnetism_label)
		inputs.add_child_below_node(join_encounters_label,join_encounters_input)
		inputs.add_child_below_node(use_magnetism_label,use_magnetism_input)
		if modmanager.has_savedata():
			join_encounters_input.selected_value = SaveState.other_data.LivingWorldData.Settings.JoinEncounters
			use_magnetism_input.selected_value = SaveState.other_data.LivingWorldData.Settings.MagnetismEnabled
func save_mod_settings():
	if !modmanager.has_savedata():
		modmanager.initialize_savedata()
	SaveState.other_data.LivingWorldData.Settings.JoinEncounters = join_encounters_input.selected_value
	SaveState.other_data.LivingWorldData.Settings.MagnetismEnabled = use_magnetism_input.selected_value

	"""
	return code_blocks[block]

