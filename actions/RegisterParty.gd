extends Action

export(bool) var register=false
export(int) var max_occupancy = 4
func _run():
	if register:
		var target = get_target()
		if not target or !target.has_node("RecruitData"):
			return false
		var recruit = get_pawn()
		var recruitdata = recruit.get_node("RecruitData")
		var targetdata = target.get_node("RecruitData")
		if !targetdata.party_is_recruiting(recruitdata):
			return false
		targetdata.add_party_member(recruit, recruitdata)
	else:
		var recruit = get_pawn()
		var recruitdata = recruit.get_node("RecruitData")
		recruitdata.remove_party_member(recruit, recruitdata)
	return true
func get_target():
	return values[0]	
		
