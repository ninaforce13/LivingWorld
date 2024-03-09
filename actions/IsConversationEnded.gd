extends ActionValue

func get_value():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return true
	if !pawn.is_inside_tree():
		return true
	var data = pawn.get_data()
	return data.conversation_partners.size() == 0
