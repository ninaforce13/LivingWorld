extends MessageDialogAction

export (bool) var use_random = false
export (Array,Array,String) var message_array
export (bool) var disable_sprite = false
var dialogsprite
var tween:Tween
var npcmanager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var use_battlesprite:bool = false

func _ready():
	var pawn = get_pawn()
	if pawn.has_node("ConversationSprite") and !disable_sprite:
		dialogsprite = pawn.get_node("ConversationSprite")
	tween = Tween.new()
	add_child(tween)
func _enter_action():
	generate_frankie_values()
	var pawn = get_pawn()
	var data = pawn.get_data()
	use_battlesprite = (npcmanager.get_setting("BattleSprite") or !data.is_partner) and !disable_sprite
	if use_random:
		messages = []
		var index:int = randi()%message_array.size()
		for message in message_array[index]:
			messages.push_back(message)
	if dialogsprite and use_battlesprite:
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
			dialogsprite.visible = true
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(-550,0),Vector2(0,0),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
		if style == 1:
			yield (MenuHelper.show_spooky_dialog(text, audio if i == 0 else null, type_sounds), "completed")
		else :
			yield (GlobalMessageDialog.show_message(text, false, wait_for_confirm or i < messages.size() - 1), "completed")

		dlg.audio = null
	if close_after:
		if dialogsprite and use_battlesprite:
			tween.interpolate_property(dialogsprite,"rect_position",Vector2(0,0),Vector2(1800,0),0.05,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
			dialogsprite.visible = false
	return true

func _exit_action(_result):
	if close_after:
		return GlobalMessageDialog.hide()

func generate_frankie_values():
	var first_word:Array = [
		"Super",
		"Ultimate",
		"Fantasmical",
		"Plus",
		"Extreme",
		"Isekai",
		"Grand",
		"Cassette"]
	var second_word:Array = [
		"Smash",
		"Slam",
		"Crash",
		"Power",
		"Crush",
		"Zaap",
		"Fusion",
		"Grid",
		"Protagonist"]
	var third_word:Array = [
		"Ultra",
		"Mod",
		"Attack",
		"Stance",
		"Pose",
		"Special"]
	var snap = SaveState.other_data.get("frankie_starter")
	var form
	if snap:
		if snap.has("custom_form") and snap.custom_form != "":
			form = load(snap.custom_form) as MonsterForm
			if !form:
				form = load(snap.form) as MonsterForm
		else:
			form = load(snap.form) as MonsterForm
	if form:
		set_bb("frankie_tape",Loc.tr(form.description))

	var space:String = " "
	var random = Random.new()
	var name_length = random.rand_range_int(2,3)
	var attack_name:String
	for i in range (name_length):
		if i == 0:
			attack_name = random.choice(first_word)
		if i == 1:
			attack_name = attack_name + space + random.choice(second_word)
		if i == 2:
			attack_name = attack_name + space + random.choice(third_word)
	set_bb("frankie_attack",attack_name)

