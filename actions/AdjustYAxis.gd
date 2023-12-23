extends Action
export (bool) var positive_move = false
export (float) var relative_movement = 0.25
func _run():
	var pawn = get_pawn()
	var pos = Vector3.ZERO
	relative_movement = relative_movement * -1 if not positive_move else relative_movement
	pos.y = relative_movement
	pawn.global_transform.origin += pos
	return true
