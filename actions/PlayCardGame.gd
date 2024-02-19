extends Action
var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
var settings = preload("res://mods/LivingWorld/settings.tres")
var seed_value = 8675309
func _run():
	var pawn = get_pawn()
	seed_value ^= SaveState.random_seed
	var random = Random.new(seed_value)
	var scene = load("res://mods/LivingWorld/scenes/MiniGame.tscn")
	var menu = scene.instance()
	menu.player_data = jsonparser.get_player_snapshot()
	var recruit_data = pawn.get_data()
	menu.enemy_data = recruit_data.recruit
	if recruit_data.card_deck.empty():
		recruit_data.build_deck()
	menu.enemy_deck = recruit_data.card_deck
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	set_bb("win_game",result)
	menu.queue_free()
	if result:
		var holocard:bool = false
		var reward_card = random.choice(recruit_data.card_deck)
		if random.rand_bool(settings.holocard_rate):
			reward_card.holocard = true
			holocard = true
		manager.add_card_to_collection(reward_card,holocard)
		set_bb("reward",reward_card)
	return true
