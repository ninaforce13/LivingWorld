extends Action
signal party_disbanded

var pawn
var data_node

func _run():
	pawn = get_pawn()
	data_node = pawn.get_data()
	yield(self,"party_disbanded")
	return false

func _process(delta):
	if data_node:
		if !data_node.has_party() or data_node.party_leader_invalid():
			emit_signal("party_disbanded")
