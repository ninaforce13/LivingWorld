extends StickerItem

func get_use_options(_node, _context_kind:int, _context)->Array:
	return [{
		label = "TRADE_STICKER_UI_USE",
		disabled = false,
		arg = null
	}]

func use(_node, _context_kind:int, _context, arg = null):
	return true
