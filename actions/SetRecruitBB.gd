extends Action

func _run():
	var data = get_pawn().get_data()
	set_bb("has_trade",data.has_trade_offer())
	set_bb("has_follower",SaveState.other_data.LivingWorldData.CurrentFollower.active)
	set_bb("is_resting",data.on_battle_cooldown)
	return true
