extends Area

func _on_MouseClick_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var camera = WorldSystem.get_level_map().camera
			if !camera.has_node("DebugCameraController"):
				return
			var tracker = WorldSystem.get_level_map().get_node("Tracker")
			tracker.set_targets([get_parent().get_path()])
			tracker.snap_to_target()
			var cam = WorldSystem.get_level_map().camera
			cam.translation = Vector3.ZERO

