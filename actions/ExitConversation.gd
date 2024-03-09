extends Action

func _run():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return true
	if !pawn.is_inside_tree():
		return true
	var data = pawn.get_data()
	if data:
		data.exit_conversation()
	if data.has_party() and !data.is_leader:
		var behavior = pawn.get_behavior()
		behavior.set_state("Party")

	return true
