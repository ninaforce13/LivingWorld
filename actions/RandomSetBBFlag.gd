extends Action

export (String) var bb_name = ""
export (float) var activation_chance = 0.5
var random:Random
func _run():
	random = Random.new()
	set_bb(bb_name, random.rand_bool(activation_chance))
	return true
