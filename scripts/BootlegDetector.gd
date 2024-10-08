extends "res://world/core/Detector.gd"

func is_valid_detection(_detection)->bool:
	if get_parent().state_machine.state == "Defeated":
		return false
	if !_detection.has_node("ObjectData"):
		return false
	if !_detection.has_node("EncounterConfig"):
		return false
	if _detection.has_node("EncounterConfig"):
		var encounter = _detection.get_node("EncounterConfig")
		if encounter.get_bootlegs().size() == 0:
			return false
	return true

