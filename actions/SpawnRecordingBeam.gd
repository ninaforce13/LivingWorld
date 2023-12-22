extends Action
export (float) var hold_duration
const RecordingBeam = preload("res://nodes/battle_vfx/beams/recording/RecordingBeam.tscn")

func _run():
	var pawn = get_pawn()
	var target = values[0]
	var beam = RecordingBeam.instance()
	set_bb("beam",beam)
	beam.hold_duration = hold_duration
	var dist = pawn.global_transform.origin.distance_to(target.global_transform.origin)
	beam.target_length = dist
	pawn.add_child(beam)
	beam.global_transform.origin.y += 1
	beam.global_transform.looking_at(target.global_transform.origin,Vector3.UP)
	beam.rotate_object_local(Vector3.UP,PI)
#	yield(beam, "beam_finished")
#	beam.queue_free()
	return true

#func _process(delta):
#	if has_bb("beam"):
#		var beam = get_bb("beam")
#		var target = values[0]
#		if target != null and is_instance_valid(target):
#			beam.transform.origin = Vector3.ZERO
#			var dist = get_pawn().global_transform.origin.distance_to(target.global_transform.origin)
#			beam.target_length = dist
#			beam.global_transform.looking_at(target.global_transform.origin,Vector3.UP)
#			beam.rotate_object_local(Vector3.UP,PI)
