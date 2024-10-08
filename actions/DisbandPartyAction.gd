extends Action

func _run():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return true
	var data_node = pawn.get_data()
	if data_node:
		if data_node.has_party():
			data_node.disband_party()
	return true
