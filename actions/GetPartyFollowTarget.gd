extends ActionValue

func get_value():
	var recruit = get_pawn()
	if !recruit or !is_instance_valid(recruit):
		return null
	if recruit.has_node("RecruitData"):
		return recruit.get_data().follow_target
	return recruit
