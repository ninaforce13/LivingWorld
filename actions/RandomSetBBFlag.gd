extends Action

export (String) var bb_name = ""
export (float) var activation_chance = 0.5
var random:Random
func _run():
	set_bb(bb_name, randf() < activation_chance)
	return true
