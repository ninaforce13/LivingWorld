extends Action

func _run():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return true
	if !pawn.is_inside_tree():
		return true
	if !pawn.has_node("RecruitData"):
		return true
	var data_node = pawn.get_data()
	var data = data_node.recruit
	if !data_node.has_party():
		data_node.form_party()
	return true


