extends Action

func _run():
	var target = values[0]
	if !target or !is_instance_valid(target):
		return true
	var behavior = target.get_behavior()
	behavior.set_state("Idle")
	return true


