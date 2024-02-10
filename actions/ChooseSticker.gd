extends Action

func _run():
	var result = yield (MenuHelper.show_inventory(99, ["stickers"], false), "completed")
	if result != null:
		assert (result.item.item is StickerItem)
		var recruitdata = get_pawn().get_data()
		var trade_result = yield(recruitdata.trade_offer.attempt_trade(result.item.item),"completed")
		set_bb("valid_trade",trade_result)
	return true
