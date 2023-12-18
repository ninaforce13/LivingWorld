extends ActionValue

export (String) var group:String
export (float) var distance = 10
export (bool) var inverted = false
func get_value():
	var nodes = get_tree().get_nodes_in_group(group)
	if nodes.size() == 0:
		return true

	var best_node = get_nearest_node(nodes)		
	if best_node == null:
		return true
	var node_distance = get_pawn().global_transform.origin.distance_to(best_node.global_transform.origin)
	var result = node_distance <= distance if !inverted else node_distance > distance
	if node_distance <= distance:
		var object_data = best_node.get_node("ObjectData")
		result = object_data.is_empty()
			
	return result

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
		var dist = node.global_transform.origin.distance_to(pawn_pos)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best
