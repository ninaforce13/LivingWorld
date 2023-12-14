extends ActionValue

func get_value():	
	var pawn = get_pawn()
	var target = pawn.get_node("RecruitData").current_target
	var targetdata = target.get_node("RecruitData")
	for seat in targetdata.targets:
		if !seat.occupied:
			seat.occupied = true
			seat.occupant = pawn
			return seat.seat
	return null

	
