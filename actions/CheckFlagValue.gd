extends CheckConditionAction
export (String) var bb_name = ""

func conditions_met()->bool:
	if bb_name != "":
		var result = get_bb(bb_name)
		return result
	return check_conditions(self)
