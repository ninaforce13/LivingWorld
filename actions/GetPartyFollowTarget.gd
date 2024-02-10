extends ActionValue

func get_value():
	var recruit = get_pawn()
	if recruit.has_node("RecruitData"):
		return recruit.get_data().follow_target
	return recruit
