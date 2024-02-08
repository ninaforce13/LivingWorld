extends CheckConditionAction

func conditions_met()->bool:
	if root == null:
		setup()
	var pawn = get_pawn()
	if pawn.has_node("RecruitData"):
		var data_node = pawn.get_node("RecruitData")
		return data_node.has_party()

	return check_conditions(self)
