extends ActionValue
export (String) var bb_name:String = ""
func get_value():
	var target = get_bb(bb_name)
	var object_data = target.get_node("ObjectData")
	var slot = object_data.get_own_slot(get_pawn())
	if slot:
		return slot.position_target
	return null


