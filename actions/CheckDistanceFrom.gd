extends CheckConditionAction

export (float) var within_distance = 10.0
var triggered:bool = false

func conditions_met()->bool:
	if root == null:
		setup()
	if check_conditions(self):
		var global_pos = get_pawn().global_transform.origin
		for player in WorldSystem.get_players():
			if global_pos.distance_to(player.global_transform.origin) < within_distance and not triggered:
				triggered = true
				return true
			else:
				return false
	return check_conditions(self)



