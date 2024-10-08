extends ActionValue
enum GROUPTYPE {OBJECT, TRAINEE, DOOR}
export (String) var group:String
export (int, "First", "Last", "Random", "All", "Nearest") var mode:int = 0
export (bool) var ignore_limited_space = false
export (GROUPTYPE) var group_type = GROUPTYPE.OBJECT
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
	if !pawn or !is_instance_valid(pawn):
		return null
	if not (pawn is Spatial):
		return null
	var pawn_pos = pawn.global_transform.origin
	var pawn_data
	if pawn.has_method("get_data"):
		pawn_data = pawn.get_data()
	var best = null
	var best_dist = INF
	for node in nodes:
		if node == pawn:
			continue
		if group_type == GROUPTYPE.OBJECT:
			if !node.has_node("ObjectData"):
				continue
			var object_data = node.get_node("ObjectData")
			if object_data.is_full() and !ignore_limited_space:
				continue
			if pawn_data and pawn_data.has_party():
				if !object_data.has_space(pawn_data.get_party_size()) and !ignore_limited_space:
					continue
		if group_type == GROUPTYPE.TRAINEE:
			if !node.has_node("RecruitData"):
				continue
			var data = node.get_data()
			if data.engaged:
				continue
		var dist = node.global_transform.origin.distance_to(pawn_pos)
		if best != null and best.has_node("ObjectData") and node.has_node("ObjectData"):
			if !best.get_node("ObjectData").prioritize and node.get_node("ObjectData").prioritize:
				best_dist = dist
				best = node
		if dist < best_dist:
			if best != null and best.has_node("ObjectData") and node.has_node("ObjectData"):
				if best.get_node("ObjectData").prioritize and !node.get_node("ObjectData").prioritize:
					continue
			best_dist = dist
			best = node
	return best
