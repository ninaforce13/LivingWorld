extends ActionValue

func get_value():
	var pawn = get_pawn()
	var data_node = pawn.get_node("RecruitData")
	var leader_node = data_node.get_party_leader()
	if !leader_node:
		print("party leader not found")
		data_node.disband_party()
		return null
	return leader_node.get_parent()
