extends Action
func _run():
	var player = values[0]
	var partner = WorldSystem.get_partner()
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
		if object_data.get_own_slot(partner):
			var partner_seat_pos = object_data.get_own_slot(partner).position_target
			object_data.remove_occupant(partner)
			partner.warp_to(partner_seat_pos + Vector3.BACK * 3)
			partner.state_machine.set_state("Idle")
		return true

	object_data.add_occupant(player)
	var seat = object_data.get_own_slot(player)
	player.warp_to(seat.position_target)
	player.set_direction(seat.face_direction)
	player.state_machine.set_state("Sitting")
	if !object_data.is_full():
		object_data.add_occupant(partner)
		var partner_seat = object_data.get_own_slot(partner)
		partner.warp_to(partner_seat.position_target)
		partner.set_direction(partner_seat.face_direction)
		partner.state_machine.set_state("Sitting")
	return true

