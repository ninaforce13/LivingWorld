extends Action

func _run():
	var target = values[0]
	var behavior = target.get_behavior()
	behavior.set_state("Idle")
	return true


