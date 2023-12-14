extends ActionValue

export (String) var group:String
export (int, "First", "Last", "Random", "All", "Nearest") var mode:int = 0
export (bool) var limited_space = false
export (int) var max_occupancy = 4

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
		return get_nearest_node(nodes)
	assert (mode == 3)
	return nodes

func get_nearest_node(nodes):
	var recruitdata = get_pawn().get_node("RecruitData")
	if not (get_pawn() is Spatial):
		return null
	var pawn_pos = get_pawn().global_transform.origin
	var best = null
	var best_dist = INF
	for node in nodes:
		if node == get_pawn():
			continue
		if limited_space and node.has_node("RecruitData"):
			var node_data = node.get_node("RecruitData")
			if node_data.occupants.size() >= max_occupancy and !node_data.occupants.has(recruitdata.recruit):
				continue
			if recruitdata.occupants.size() + node_data.occupants.size() + 1 > max_occupancy:
				continue
		var dist = node.global_transform.origin.distance_to(pawn_pos)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best
