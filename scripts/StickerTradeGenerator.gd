const StickerTradeOffer = preload("res://mods/LivingWorld/scripts/StickerTradeOffer.gd")
const booby_trap = preload("res://data/battle_moves/booby_trap.tres")
const bad_forecast = preload("res://data/battle_moves/bad_forecast.tres")
static func generate():
	var trade = StickerTradeOffer.new()

	var random = Random.new()
	var filtered_stickers = BattleMoves.all_stickers.duplicate()
	filtered_stickers.erase(booby_trap)
	filtered_stickers.erase(bad_forecast)

	var rand_move = filtered_stickers[random.rand_int()%filtered_stickers.size()]
	var rarity = random.rand_range_int(0,2)
	var sticker = ItemFactory.create_sticker(rand_move,random, rarity)
	trade.request_snapshot = sticker.get_snapshot()

	rarity = random.rand_range_int(sticker.rarity,2)
	rand_move = filtered_stickers[random.rand_int()%filtered_stickers.size()]
	sticker = ItemFactory.create_sticker(rand_move,random, rarity)
	trade.offer_snapshot = sticker.get_snapshot()

	return trade

