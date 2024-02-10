extends ActionValue

func get_value():
	var pawn = get_pawn()
	var recruitdata = pawn.get_data()
	var target = recruitdata.engaged_target
	if is_instance_valid(target):
		return target
	else:
		return null
