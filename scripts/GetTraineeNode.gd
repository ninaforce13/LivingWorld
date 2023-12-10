extends ActionValue

export (NodePath) var path:NodePath
export (String) var node_name:String

func set_detection_path(_path):
	path = _path.get_path()
func get_value():
	var pawn = get_pawn()
	if path.is_empty():
		if has_node(node_name):
			return get_node(node_name)
		if is_instance_valid(pawn) and pawn.has_node(node_name):
			return pawn.get_node(node_name)
		return get_current_scene().get_node(node_name)
	if has_node(path):
		return get_node(path)
	if is_instance_valid(pawn) and pawn.has_node(path):
		return pawn.get_node(path)
	return get_current_scene().get_node(path)
