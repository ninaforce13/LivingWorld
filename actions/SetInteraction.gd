extends Action
export (bool) var disabled = false
func _run():
	var target = values[0]
	if target and is_instance_valid(target):
		var interaction = target.get_node("Interaction")
		if interaction:
			interaction.disabled = disabled
	return true
