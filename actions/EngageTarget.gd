extends Action

func _run():
	var target = values[0]
	if !target or !is_instance_valid(target):
		return true
	if !target.is_inside_tree():
		return true
	var data_node = target.get_data()
	data_node.set_engage(true)
	return true
