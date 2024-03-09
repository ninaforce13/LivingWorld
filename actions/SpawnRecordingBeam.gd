extends Action
export (float) var hold_duration
export (bool) var reset = false
const RecordingBeam = preload("res://nodes/battle_vfx/beams/recording/RecordingBeam.tscn")
var beam = null
func _run():
	var pawn = get_pawn()
	if !pawn or !is_instance_valid(pawn):
		return true
	if reset:
		if pawn.has_node("RecordingBeamVfx"):
			beam = pawn.get_node("RecordingBeamVfx")
			if beam:
				pawn.remove_child(beam)
				beam.queue_free()
		return true
	var target = values[0]
	if !is_instance_valid(target):
		return true
	beam = RecordingBeam.instance()
	beam.name = "RecordingBeamVfx"
	set_bb("beam",beam)
	beam.hold_duration = hold_duration
	var dist = pawn.global_transform.origin.distance_to(target.global_transform.origin)
	beam.target_length = dist
	pawn.add_child(beam)
	beam.global_transform.origin.y += 1
	beam.global_transform = beam.global_transform.looking_at(target.global_transform.origin + (Vector3.UP * 2),Vector3.UP)
	free_beam(beam)
	return true

func free_beam(beam):
	yield(beam,"beam_finished")
	if is_instance_valid(get_pawn()):
		get_pawn().remove_child(beam)
		beam.queue_free()
	else:
		if is_instance_valid(beam):
			beam.queue_free()

