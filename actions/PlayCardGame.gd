extends Action
var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
func _run():
	var pawn = get_pawn()

	var scene = load("res://mods/LivingWorld/scenes/MiniGame.tscn")
	var menu = scene.instance()
	menu.player_data = jsonparser.get_player_snapshot()
	menu.enemy_data = pawn.get_node("RecruitData").recruit
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	set_bb("win_game",result)
	menu.queue_free()
	return true
