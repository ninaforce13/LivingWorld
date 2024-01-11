extends MessageDialogAction

export (bool) var use_random = false
export (Array,Array,String) var message_array
var dialogsprite
var tween:Tween
func _ready():
	var pawn = get_pawn()
	if pawn.has_node("ConversationSprite"):
		dialogsprite = pawn.get_node("ConversationSprite")
	tween = Tween.new()
	add_child(tween)
func _enter_action():
	if use_random:
		messages = []
		var index:int = randi()%message_array.size()
		for message in message_array[index]:
			messages.push_back(message)
	if dialogsprite:
		var spritecont = dialogsprite.get_node("MarginContainer/MonsterSpriteContainer1/Viewport/BattleSlot/SpriteContainer")
		spritecont.idle = "inactive"
		if dialogsprite.visible:
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(0,0),Vector2(1800,0),0.05,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()

func _run():
	var audio = self.audio
	if audio == null and use_pawn_sfx_audio != "":
		var pawn = get_pawn()
		if pawn and pawn.get("sfx"):
			var sfx = pawn.sfx.get(use_pawn_sfx_audio)
			if sfx.size() > 0:
				audio = sfx[randi() % sfx.size()]

	var dlg = GlobalMessageDialog.message_dialog
	dlg.portrait = portrait
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
		if dialogsprite:
			dialogsprite.visible = true
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(-550,0),Vector2(0,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
		if style == 1:
			yield (MenuHelper.show_spooky_dialog(text, audio if i == 0 else null, type_sounds), "completed")
		else :
			yield (GlobalMessageDialog.show_message(text, false, wait_for_confirm or i < messages.size() - 1), "completed")

		dlg.audio = null
	if close_after:
		if dialogsprite:
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(0,0),Vector2(1800,0),0.05,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
			dialogsprite.visible = false
	return true

func _exit_action(_result):
	if close_after:
		return GlobalMessageDialog.hide()

