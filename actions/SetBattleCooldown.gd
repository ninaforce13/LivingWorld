extends Action
export (bool) var value = false
func _run():
	var recruit_data = get_pawn().get_node("RecruitData")
	recruit_data.on_battle_cooldown = value
	return true
