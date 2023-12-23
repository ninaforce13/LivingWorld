extends ActionValue

func get_value():
	var pawn = get_pawn()
	var data = pawn.get_node("RecruitData")
	if data.conversation_partners.size() > 0:
		return data.conversation_partners[randi()%data.conversation_partners.size()]
	return null
