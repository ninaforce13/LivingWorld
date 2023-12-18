extends ActionValue

export (String) var group:String
export (int, "First", "Last", "Random", "All", "Nearest") var mode:int = 0
export (bool) var ignore_limited_space = false

func get_value():
	var nodes = get_tree().get_nodes_in_group(group)
	if nodes.size() == 0 and mode != 3:
		return null
	
	if mode == 0:
		return nodes[0]
	elif mode == 1:
		return nodes[nodes.size() - 1]
	elif mode == 2:
		return nodes[randi() % nodes.size()]
	elif mode == 4:
		var best_node = get_nearest_node(nodes)		
		return best_node
	assert (mode == 3)
	return nodes

func get_nearest_node(nodes):
	var pawn = get_pawn()
	if not (pawn is Spatial):
		return null
	var pawn_pos = pawn.global_transform.origin
	var best = null
	var best_dist = INF
	for node in nodes:
		if node == pawn:
			continue
		if !node.has_node("ObjectData"):
			continue
		var object_data = node.get_node("ObjectData")
		if object_data.is_full() and !ignore_limited_space:
			continue	
		var dist = node.global_transform.origin.distance_to(pawn_pos)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best
