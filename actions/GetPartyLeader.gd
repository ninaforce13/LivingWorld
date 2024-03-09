extends ActionValue

func get_value():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return null
	var data_node = pawn.get_data()
	var leader_node = data_node.get_party_leader()
	if !leader_node:
		data_node.disband_party()
		return null
	return leader_node.get_parent()
