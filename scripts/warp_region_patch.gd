static func patch():
	var script_path = "res://nodes/warp_region/WarpRegion.gd"
	var patched_script : GDScript = preload("res://nodes/warp_region/WarpRegion.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path) 
			return
		patched_script.source_code = file.get_as_text()
		file.close()
	
	var code_lines:Array = patched_script.source_code.split("\n")		

	var class_name_index = code_lines.find("class_name WarpRegion")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)		
	
	var code_index = code_lines.find("		if size.x >= 5.0 and count == 2:")
	if code_index > 0:
		code_lines[code_index] = get_code("add_warp_target")

		
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	WarpRegion.source_code = patched_script.source_code
	var err = WarpRegion.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return
	print("Patched %s successfully." % script_path)
	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_warp_target"] = """
		if size.x >= 5.0 and count > 1:
	"""
	return code_blocks[block]

