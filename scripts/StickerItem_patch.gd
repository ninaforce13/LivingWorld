static func patch():
	var script_path = "res://data/item_scripts/StickerItem.gd"
	var patched_script : GDScript = preload("res://data/item_scripts/StickerItem.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name StickerItem")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func get_use_options(_node, context_kind:int, context)->Array:")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_use_option"))

	code_index = code_lines.find("	usable_contexts = ContextKind.CONTEXT_TAPE | ContextKind.CONTEXT_WORLD")
	if code_index > 0:
		code_lines[code_index] = get_code("add_usable_context")

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	StickerItem.source_code = patched_script.source_code
	var err = StickerItem.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_use_option"] = """
	if context_kind == 99:
		return [{"label":"TRADE_STICKER_UI_USE","disabled":false, "arg":""}]
	"""

	code_blocks["add_usable_context"] = """
	usable_contexts = ContextKind.CONTEXT_TAPE | ContextKind.CONTEXT_WORLD | 99
	"""
	return code_blocks[block]

