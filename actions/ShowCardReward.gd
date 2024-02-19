extends Action

func _run():
	var scene = load("res://mods/LivingWorld/cardgame/SealedCard.tscn")
	var menu = scene.instance()
	var reward = get_bb("reward")
	menu.reward_monster_path = reward.form
	menu.holocard = reward.holocard
	MenuHelper.add_child(menu)
	yield (menu, "reward_completed")
	menu.queue_free()

	return true
