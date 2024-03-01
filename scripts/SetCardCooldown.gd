extends Action
export (bool) var value = false
func _run():
	var recruit_data = get_pawn().get_data()
	recruit_data.on_card_cooldown = value
	return true
