extends Action
export (bool) var use_heal = false
const RecordSuccess = preload("res://mods/LivingWorld/nodes/OverworldRecordedSuccess.tscn")
const ReviveEffect = preload("res://mods/LivingWorld/nodes/revive_effect.tscn")
func _run():
	var target = values[0]
	if !is_instance_valid(target):
		return false
	var record_vfx = RecordSuccess.instance() if not use_heal else ReviveEffect.instance()
	var anim = record_vfx.get_node("AnimationPlayer")
	add_child(record_vfx)
	record_vfx.global_transform.origin = target.global_transform.origin
	anim.play("animation_1")
	yield(anim,"animation_finished")
	record_vfx.queue_free()
	return true

