extends Action


func _run():
	var target = get_target()
	var recruit = get_pawn().get_node("RecruitData").recruit
	if target.has_node("RecruitData"):
		var recruitdata = target.get_node("RecruitData")
		if recruitdata.occupants.has(recruit):
			recruitdata.occupants.erase(recruit)
func get_target():
	return values[0]	
		
