extends Area

func _on_MouseClick_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var tracker = WorldSystem.get_level_map().get_node("Tracker")						
			tracker.set_targets([get_parent().get_path()])
			tracker.snap_to_target()
			var cam = WorldSystem.get_level_map().camera
			cam.translation = Vector3.ZERO
		
