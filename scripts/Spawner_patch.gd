static func patch():
	var script_path = "res://world/objects/spawner/Spawner.gd"
	var patched_script : GDScript = preload("res://world/objects/spawner/Spawner.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path) 
			return
		patched_script.source_code = file.get_as_text()
		file.close()
	
	var code_lines:Array = patched_script.source_code.split("\n")		

	var class_name_index = code_lines.find("class_name Spawner")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)		
	
	var code_index = code_lines.find("func _ready():")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_spawner"))

	code_lines.insert(code_lines.size()-1, get_code("setup_recruit_spawner"))
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	Spawner.source_code = patched_script.source_code
	var err = Spawner.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return

	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_spawner"] = """
	call_deferred("setup_recruit_spawner",preload("res://mods/LivingWorld/nodes/RecruitSpawner.tscn").instance())
	"""
	code_blocks["setup_recruit_spawner"] = """
func setup_recruit_spawner(node):
		get_parent().add_child(node)
		node.global_transform = global_transform
		node.aabb = aabb
		node.aabb.size.y += 10
	"""
	return code_blocks[block]

