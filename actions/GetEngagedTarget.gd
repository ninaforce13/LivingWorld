extends ActionValue

func get_value():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return null
	if !pawn.is_inside_tree():
		return null
	var recruitdata = pawn.get_data()
	var target = recruitdata.engaged_target
	if !target or !is_instance_valid(target):
		return null
	if !target.is_inside_tree():
		return null

	return target

