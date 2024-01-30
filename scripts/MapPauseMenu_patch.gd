static func patch():
	var script_path = "res://menus/map_pause/MapPauseMenu.gd"
	var patched_script : GDScript = preload("res://menus/map_pause/MapPauseMenu.gd")

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
		code_lines.insert(code_index+1,get_code("add_cards_button"))

	code_lines.insert(code_lines.size()-1,get_code("add_newfunction"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_cards_button"] = """
	var cards_button:Button = inventory_button.duplicate()
	cards_button.disconnect("pressed", self, "_on_InventoryButton_pressed")
	buttons.add_child_below_node(inventory_button,cards_button)
	cards_button.connect("pressed",self,"_on_cardbutton_pressed")
	cards_button.text = "LIVINGWORLD_UI_CARDCOLLECTION"
	"""
	code_blocks["add_newfunction"] = """
func _on_cardbutton_pressed():
	var scene = load("res://mods/LivingWorld/menus/CardCollectionMenu.tscn")
	var menu = scene.instance()
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	menu.queue_free()
	"""
	return code_blocks[block]

