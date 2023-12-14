static func patch():
	var script_path = "res://world/objects/campsite/Camping.gd"
	var patched_script : GDScript = preload("res://world/objects/campsite/Camping.gd")

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
		code_lines.insert(code_index+1,get_code("add_to_group"))

	code_lines.insert(code_lines.size()-1,get_code("add_firesprite"))	
	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return
	
static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_to_group"] = """
	add_to_group("campfires")
	call_deferred("add_child",preload("res://mods/LivingWorld/nodes/RecruitData.tscn").instance())
	call_deferred("add_firesprite")
	"""
	
	code_blocks["add_firesprite"] = """
func add_firesprite():
	if !has_node("Fire Sprite"):
		return
	var firesprite = preload("res://mods/LivingWorld/nodes/FireSprite.tscn").instance()
	get_parent().add_child(firesprite)
	firesprite.global_transform.origin = get_node("Fire Sprite").global_transform.origin
	var parent = get_parent()
	if parent.has_node("PlayerTarget"):
		var basetarget = parent.get_node("PlayerTarget")
		var basetarget2 = parent.get_node("PartnerTarget")

		var newtarget = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget.transform.origin = basetarget.transform.origin
		parent.add_child(newtarget)
		var newtarget2 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget2.transform.origin = basetarget2.transform.origin
		parent.add_child(newtarget2)
		var newtarget3 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget3.transform.origin = Vector3(-2.5,0,2.5)
		parent.add_child(newtarget3)		
		var newtarget4 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget4.transform.origin = Vector3(2.5,0,2.5)
		parent.add_child(newtarget4)		
		var newtarget5 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget5.transform.origin = Vector3(-2.5,0,-2.5)
		parent.add_child(newtarget5)		
		var newtarget6 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget6.transform.origin = Vector3(2.5,0,-2.5)
		parent.add_child(newtarget6)		
		
		if has_node("RecruitData"):
			var recruitdata = get_node("RecruitData")
			recruitdata.targets.push_back({"seat":newtarget,"occupied":false,"occupant":null})
			recruitdata.targets.push_back({"seat":newtarget2,"occupied":false,"occupant":null})
			recruitdata.targets.push_back({"seat":newtarget3,"occupied":false,"occupant":null})
			recruitdata.targets.push_back({"seat":newtarget4,"occupied":false,"occupant":null})
			recruitdata.targets.push_back({"seat":newtarget5,"occupied":false,"occupant":null})
			recruitdata.targets.push_back({"seat":newtarget6,"occupied":false,"occupant":null})
	"""	
	return code_blocks[block]

