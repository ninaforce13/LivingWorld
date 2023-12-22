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
	call_deferred("add_child",preload("res://mods/LivingWorld/nodes/CampfireData.tscn").instance())
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
		var target_positions:Array = []
		var newtarget = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget.transform.origin = Vector3(0,0,3.5)
		target_positions.push_back(newtarget)
		parent.add_child(newtarget)
		var newtarget2 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget2.transform.origin = Vector3(0,0,-3.5)
		target_positions.push_back(newtarget2)
		parent.add_child(newtarget2)
		var newtarget3 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget3.transform.origin = Vector3(-2.5,0,2.5)
		target_positions.push_back(newtarget3)
		parent.add_child(newtarget3)
		var newtarget4 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget4.transform.origin = Vector3(2.5,0,2.5)
		parent.add_child(newtarget4)
		target_positions.push_back(newtarget4)
		var newtarget5 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget5.transform.origin = Vector3(-2.5,0,-2.5)
		parent.add_child(newtarget5)
		target_positions.push_back(newtarget5)
		var newtarget6 = preload("res://mods/LivingWorld/nodes/RecruitTarget.tscn").instance()
		newtarget6.transform.origin = Vector3(2.5,0,-2.5)
		parent.add_child(newtarget6)
		target_positions.push_back(newtarget6)

		if has_node("ObjectData"):
			var object_data = get_node("ObjectData")
			var index:int = 0
			for slot in object_data.slots:
				slot.position_target = target_positions[index]
				index += 1
			object_data.campfire = firesprite
	"""
	return code_blocks[block]

