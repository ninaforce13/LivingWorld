extends Action
export (bool) var activate = false
func _run():
	var target = get_target()
	var parent = target.get_parent()
	if not activate:
		if target.has_node("RecruitData"):
			var recruitdata = target.get_node("RecruitData")
			if recruitdata.occupants.size() != 0:
				 return true
	if parent:
		if parent.has_node("Fire Sprite"):
			parent.get_node("Fire Sprite").visible = activate
			if activate:
				print("Lighting campfire...")
			else:
				print("Putting out campfire...")
	return true
	
func get_target():
	return values[0]
