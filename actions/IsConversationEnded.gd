extends ActionValue

func get_value():
	var pawn = get_pawn()
	var data = pawn.get_node("RecruitData")
	return data.conversation_partners.size() == 0
