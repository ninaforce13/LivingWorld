extends ActionValue

const up = Vector2(0, - 1)
const up_right = Vector2(1, -1)
const up_left = Vector2(-1, -1)
const left = Vector2( - 1, 0)
const right = Vector2(1, 0)
const down = Vector2(0, 1)
const down_right = Vector2(1, 1)
const down_left = Vector2(-1, 1)


const cardinals = [up, right, down, left, down_left, down_right, up_left, up_right]

export (float) var spawn_point_return_threshold:float = 64.0

func get_value():
	if spawn_point_return_threshold > 0.0:
		var spawn_point = get_pawn().spawn_point
		var pos = get_pawn().global_transform.origin
		if randf() < pos.distance_to(spawn_point) / spawn_point_return_threshold:
			return Direction.get_nearest_xz(spawn_point - pos)

	return cardinals[randi() % cardinals.size()]
