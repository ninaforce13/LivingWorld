extends Action

func _run():
	var target = values[0]
	var data_node = target.get_data()
	data_node.set_engage(true)
	return true
