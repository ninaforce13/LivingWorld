extends Action
func _run():
	var player = values[0]
	var object_data = values[1]
	if not object_data or not player:
		return false
	if !is_instance_valid(object_data):
		return false
	var player_data = player.get_data()

	if object_data.is_full() and object_data.get_own_slot(player) == null:
		return false
	if object_data.get_own_slot(player):
		var seat_pos = object_data.get_own_slot(player).position_target
		object_data.remove_occupant(player)
		player.warp_to(seat_pos + Vector3.BACK * 3)
		player.state_machine.set_state("Idle")
		return true

	object_data.add_occupant(player)
	var seat = object_data.get_own_slot(player)
	player.warp_to(seat.position_target)
	player.set_direction(seat.face_direction)
	player.state_machine.set_state("Sitting")

	return true

