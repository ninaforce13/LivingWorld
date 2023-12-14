extends Action

func _run():
	var target = values[0]
	var data = get_pawn().get_node("RecruitData")
	if target:
		data.current_target = target
	return true
	
