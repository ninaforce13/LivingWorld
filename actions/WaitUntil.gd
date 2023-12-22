extends Action
signal triggered
export (float) var base_seconds:float = 1.0
export (float) var random_seconds:float = 0.0
var _timer:float = 0.0

func _run():
	_timer = base_seconds + randf() * random_seconds
	yield (self, "triggered")
	return true

func _process(delta):
	if _timer > 0.0:
		_timer -= delta
		if _timer <= 0.0 or is_condition_met():
			_timer = 0.0
			emit_signal("triggered")

func is_condition_met()->bool:
	get_values()
	var result = values[0]
	return result

func get_values():
	values = []
	for child in get_children():
		if child is ActionValue:
			if child.root == null:
				child.setup()
			values.push_back(child.get_value())

