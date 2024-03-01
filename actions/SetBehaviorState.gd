extends Action

func _run():
	var pawn = get_pawn()
	var behavior = pawn.get_behavior()
	behavior.set_state("Fainted")
	return true
