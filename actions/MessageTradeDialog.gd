extends MessageDialogAction
var RarityColors:Dictionary = {"Common":Color.lemonchiffon.to_html(),"Uncommon":"1fba33","Rare":"2b9aeb"}
export (bool) var use_random = false
export (Array,Array,String) var message_array
var dialogsprite
var tween:Tween
var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var use_battlesprite:bool = false
func _ready():
	var pawn = get_pawn()
	if pawn.has_node("ConversationSprite"):
		dialogsprite = pawn.get_node("ConversationSprite")
		if dialogsprite:
			dialogsprite.name = "ConversationSprite"
	tween = Tween.new()
	add_child(tween)

func _run():
	var audio = self.audio
	if audio == null and use_pawn_sfx_audio != "":
		var pawn = get_pawn()
		if pawn and pawn.get("sfx"):
			var sfx = pawn.sfx.get(use_pawn_sfx_audio)
			if sfx.size() > 0:
				audio = sfx[randi() % sfx.size()]

	var dlg = GlobalMessageDialog.message_dialog
	dlg.portrait = portrait if !use_battlesprite else null
	dlg.portrait_position = portrait_position
	dlg.audio = audio
	dlg.type_sounds = type_sounds
	dlg.font = null

	if style == 2:
		dlg.font = preload("res://ui/fonts/archangel/archangel_60.tres")
	elif style == 3:
		dlg.font = preload("res://ui/fonts/archangel/archangel_40.tres")

	GlobalMessageDialog.layer = 62 if style != 0 else 64

	var subs = create_subs(self)

	var variant:int = 0
	if text_variant_seed != "" or blackboard.has("text_variant_seed"):
		var bb_seed = blackboard.get("text_variant_seed", 0)
		if not (bb_seed is int):
			bb_seed = str(bb_seed).hash()
		variant ^= bb_seed
		if text_variant_seed != "":
			variant ^= text_variant_seed.hash()
	else :
		variant = randi()

	if SaveState.has_flag("mask_name_" + title):
		dlg.title = "UNKNOWN_NAME"
	else :
		dlg.title = Loc.trvf(title, variant, subs)

	for i in range(messages.size()):
		var message = messages[i]
		var text
		if use_pronouns != PronounMode.DONT_USE:
			text = Loc.trgvf(message, get_pronouns(), variant, subs)
		else :
			text = Loc.trvf(message, variant, subs)

		if style == 2:
			text = SpookyDialog.FORMAT.format([text])




		text = Loc.substitute_mfn(text, SaveState.party.player.pronouns)
		if dialogsprite and use_battlesprite:
			var dlg_messagebox = dlg.get_node("Slider/OverscanMarginContainer/MessageBox")
			dialogsprite.visible = true
			if dlg_messagebox and !dlg_messagebox.has_node("ConversationSprite"):
				dialogsprite.get_parent().remove_child(dialogsprite)
				dlg_messagebox.add_child(dialogsprite)
				dlg_messagebox.move_child(dialogsprite,0)
		if style == 1:
			yield (MenuHelper.show_spooky_dialog(text, audio if i == 0 else null, type_sounds), "completed")
		else :
			yield (GlobalMessageDialog.show_message(text, false, wait_for_confirm or i < messages.size() - 1), "completed")

		dlg.audio = null
	if close_after:
		if dialogsprite and use_battlesprite:
			var dlg_messagebox = dlg.get_node("Slider/OverscanMarginContainer/MessageBox")
			if dlg_messagebox and !dlg_messagebox.has_node("ConversationSprite"):
				dialogsprite.get_parent().remove_child(dialogsprite)
				dlg_messagebox.add_child(dialogsprite)
				dlg_messagebox.move_child(dialogsprite,0)
			dialogsprite.visible = false
	return true

func _exit_action(_result):
	if close_after:
		var dlg = GlobalMessageDialog.message_dialog
		var dlg_messagebox = dlg.get_node("Slider/OverscanMarginContainer/MessageBox")
		if dlg_messagebox.has_node("ConversationSprite"):
			var spritenode = dlg_messagebox.get_node("ConversationSprite")
			dlg_messagebox.remove_child(spritenode)
			get_pawn().add_child(spritenode)
		return GlobalMessageDialog.hide()
func _enter_action():
	var pawn = get_pawn()
	var data = pawn.get_data()
	use_battlesprite = npcmanager.get_setting("BattleSprite") or !data.is_partner
	assign_bb_values()
	if use_random:
		messages = []
		var index:int = randi()%message_array.size()
		for message in message_array[index]:
			messages.push_back(message)

func assign_bb_values():
	var pawn = get_pawn()
	var recruitdata = pawn.get_data()
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

