extends Action
export (bool) var disabled = false

func _run():
	var target = values[0]
	if target.has_node("PlayerTouchDetector"):
		target.get_node("PlayerTouchDetector").disabled = disabled
	if target.has_node("Interaction"):
		target.get_node("Interaction").disabled = disabled
	return true
