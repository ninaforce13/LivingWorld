extends Action

func _run():
	if SaveState.other_data.has("follower"):
		SaveState.other_data.follower.active = false
	return true
