extends CheckConditionAction
export (bool) var invert = false

func conditions_met()->bool:
	if root == null:
		setup()
	if check_conditions(self):
		var recruitdata = get_pawn().get_node("RecruitData")
		return recruitdata.on_battle_cooldown if not invert else !recruitdata.on_battle_cooldown
	return check_conditions(self)
