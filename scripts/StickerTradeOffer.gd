extends Node
signal trade_completed
export (Dictionary) var offer_snapshot
export (Dictionary) var request_snapshot

func attempt_trade(stickeritem)->bool:
	yield(get_tree(), "idle_frame")
	if is_valid(stickeritem):
		var offer = StickerItem.new()
		offer.set_snapshot(offer_snapshot,1)
		SaveState.inventory.consume_item(stickeritem,1)
		yield(MenuHelper.give_item(offer,1,false),"completed")
		emit_signal("trade_completed")
		return true
	return false

func is_valid(sticker)->bool:
	var sticker_snapshot = sticker.get_snapshot()
	return sticker_snapshot.sticker == request_snapshot.sticker and sticker_snapshot.rarity >= request_snapshot.rarity
