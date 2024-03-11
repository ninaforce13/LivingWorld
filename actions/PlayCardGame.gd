extends Action
var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var settings = preload("res://mods/LivingWorld/settings.tres")
var old_audio_volume:Dictionary = {}
func _run():
	set_soundeffect_volume(true)
	var pawn = get_pawn()
	var random = Random.new()
	var scene = load("res://mods/LivingWorld/scenes/MiniGame.tscn")
	var menu = scene.instance()
	menu.player_data = jsonparser.get_player_snapshot()
	var recruit_data = pawn.get_data()
	menu.enemy_data = recruit_data.recruit
	if recruit_data.card_deck.empty():
		recruit_data.build_deck()
	for card in recruit_data.card_deck:
		menu.enemy_deck.push_back(card.duplicate())
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	set_bb("win_game",result)
	set_soundeffect_volume(false)
	menu.queue_free()
	if result:
		var reward_card = random.choice(recruit_data.card_deck)
		reward_card.holocard = random.rand_bool(settings.holocard_rate)
		manager.add_card_to_collection(reward_card)
		set_bb("reward",reward_card)
	return true

func set_soundeffect_volume(mute:bool):
	if mute:
		old_audio_volume = UserSettings.audio_volume.duplicate()
		UserSettings.audio_volume.SoundEffects = 0
	else:
		UserSettings.audio_volume = old_audio_volume.duplicate()
	UserSettings.apply_audio_volume()
