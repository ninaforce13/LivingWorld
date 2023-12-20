extends CheckConditionAction
export (String) var bb_name = ""
export (bool) var inverted = false
func conditions_met()->bool:
	if bb_name != "":
		var result = get_bb(bb_name)
		return result if not inverted else !result
	return check_conditions(self)
