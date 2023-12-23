extends Action


func _run():
	var pawn = get_pawn()
	var data = pawn.get_node("RecruitData")
	if data:
		data.exit_conversation()
	return true
