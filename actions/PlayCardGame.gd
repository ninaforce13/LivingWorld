extends Action
var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
func _run():
	var pawn = get_pawn()
	var random = Random.new()
	var scene = load("res://mods/LivingWorld/scenes/MiniGame.tscn")
	var menu = scene.instance()
	menu.player_data = jsonparser.get_player_snapshot()
	var recruit_data = pawn.get_node("RecruitData")
	menu.enemy_data = recruit_data.recruit
	if recruit_data.card_deck.empty():
		recruit_data.build_deck()
	menu.enemy_deck = recruit_data.card_deck
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	set_bb("win_game",result)
	menu.queue_free()
	if result:
		var reward_card = random.choice(recruit_data.card_deck)
		manager.add_card_to_collection(reward_card)
		#Play Animation for Reward here
	return true
