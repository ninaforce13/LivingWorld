extends Action

export(bool) var register=false

func _run():
	var target = values[0]
	if not target:
		return false
	if !is_instance_valid(target):
		return false
	var object_data = target.get_node("ObjectData")
	if !object_data:
		return false
	if register:
		if object_data.is_full():
			return false
		object_data.add_occupant(get_pawn())
		set_bb("object_data", object_data)
	else:
		object_data.remove_occupant(get_pawn())
	return true

