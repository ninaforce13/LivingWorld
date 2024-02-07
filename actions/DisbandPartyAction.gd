extends Action

func _run():
	var pawn = get_pawn()
	var data_node = pawn.get_node("RecruitData")
	if data_node:
		if data_node.has_party():
			data_node.disband_party()
	return true
