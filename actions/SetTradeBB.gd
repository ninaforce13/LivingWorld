extends Action

func _run():
	var data = get_pawn().get_node("RecruitData")
	set_bb("has_trade",data.has_trade_offer())
	return true
