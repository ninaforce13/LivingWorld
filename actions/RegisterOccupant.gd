extends Action

export(bool) var register=false
export(int) var max_occupancy = 4
func _run():
	var target = values[0]
	if not target:
		return false
	var recruitdata = get_pawn().get_node("RecruitData")
	if recruitdata.occupants.size() > 0:
		if target.has_node("RecruitData"):
			var targetdata = target.get_node("RecruitData")
			if recruitdata.occupants.has(targetdata.recruit):
				return false
	if target.has_node("RecruitData"):
		var targetdata = target.get_node("RecruitData")
		if not register:			
			if targetdata.occupants.has(recruitdata.recruit):
				targetdata.occupants.erase(recruitdata.recruit)
			for seat in targetdata.targets:
				if seat.occupant == get_pawn():
					seat.occupied = false
					seat.occupant = null
		else:			
			if targetdata.occupants.size() >= max_occupancy:
				return false
			if targetdata.occupants.size() + recruitdata.occupants.size() + 1 > max_occupancy:
				return false
			targetdata.occupants.push_back(recruitdata.recruit)
			for recruit in recruitdata.occupants:
				targetdata.occupants.push_back(recruit.data.recruit)	
			
	return true

