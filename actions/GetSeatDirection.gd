extends ActionValue
export (String) var bb_name:String = ""
func get_value():
	var target = get_bb(bb_name)
	if !target or !is_instance_valid(target):
		return null
	if !target.is_inside_tree():
		return null
	var object_data = target.get_node("ObjectData")
	if !object_data:
		object_data = target.get_parent().get_node("ObjectData")
	var slot = object_data.get_own_slot(get_pawn())
	if slot:
		return slot.face_direction
	return null


