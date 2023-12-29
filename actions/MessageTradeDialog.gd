extends MessageDialogAction
var RarityColors:Dictionary = {"Common":Color.lemonchiffon.to_html(),"Uncommon":"1fba33","Rare":"2b9aeb"}
export (bool) var use_random = false
export (Array,Array,String) var message_array
func _enter_action():
	assign_bb_values()
	if use_random:
		messages = []
		var index:int = randi()%message_array.size()
		for message in message_array[index]:
			messages.push_back(message)

func assign_bb_values():
	var pawn = get_pawn()
	var recruitdata = pawn.get_node("RecruitData")
	var trade = recruitdata.trade_offer
	if trade:
		var sticker = StickerItem.new()

		sticker.set_snapshot(trade.offer_snapshot,1)
		var offer = sticker.get_name()
		set_bb("trade_offer",offer)
		set_bb("offer_rarity",get_html_color(sticker.rarity))

		sticker.set_snapshot(trade.request_snapshot,1)
		var request = sticker.get_name()
		set_bb("trade_request",request)
		set_bb("request_rarity",get_html_color(sticker.rarity))

func get_html_color(rarity):
	var color_html = RarityColors.Common
	color_html = RarityColors.Uncommon if rarity == BaseItem.Rarity.RARITY_UNCOMMON else color_html
	color_html = RarityColors.Rare if rarity == BaseItem.Rarity.RARITY_RARE else color_html
	return color_html

