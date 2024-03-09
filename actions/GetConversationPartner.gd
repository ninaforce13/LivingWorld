extends ActionValue
export (bool) var direct_target = false
var random:Random = Random.new()
func get_value():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return null
	if !pawn.is_inside_tree():
		return null
	var data = pawn.get_data()
	if !data:
		return null
	data.check_partners()
	if data.conversation_partners.size() > 0:
		var choice = random.choice(data.conversation_partners)
		if direct_target:
			return choice
		var points:Array = []
		points.push_back(choice.global_transform.origin + (Vector3.FORWARD * 4))
		points.push_back(choice.global_transform.origin + (Vector3.BACK * 4))
		points.push_back(choice.global_transform.origin + (Vector3.LEFT * 4))
		points.push_back(choice.global_transform.origin + (Vector3.RIGHT * 4))
		var conversation_point = get_nearest_point(points)
		return conversation_point
	return null

func get_nearest_point(nodes):
	var pawn = get_pawn()
	var best = null
	var best_dist = INF
	for node in nodes:
		var dist = pawn.global_transform.origin.distance_to(node)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best
