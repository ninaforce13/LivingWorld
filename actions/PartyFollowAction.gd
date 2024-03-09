extends FollowAction
export (int) var true_distance = 3
func _enter_action():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return
	var data_node = pawn.get_data()
	var pos = data_node.get_party_position(data_node.recruit)
	min_distance = true_distance + (pos * 2)
