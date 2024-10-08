extends "res://mods/LivingWorld/actions/RecruitBehaviorState.gd"

func reset():
	var pawn = get_pawn()
	if pawn == null or !is_instance_valid(pawn):
		return
	if !pawn.is_inside_tree():
		return
	var recruitdata = pawn.get_data()
	var target = recruitdata.engaged_target
	if !target or !is_instance_valid(target):
		return
	var interaction = pawn.get_node("Interaction")
	if interaction:
		interaction.disabled = false
	pawn.sprite.set_static_amount(0)
	pawn.sprite.set_wave_amplitude(0)
	target.sprite.set_static_amount(0)
	if pawn.use_monster_form:
		yield(revert_human_sprite(pawn),"completed")
	if !is_instance_valid(target) and target == null:
		return
	if !target.is_inside_tree():
		return
	target.set_paused(false)
	target.emote_player.stop()
	target.set_paused(false)
	target.emote_player.stop()
	if target.has_node("PlayerTouchDetector"):
		target.get_node("PlayerTouchDetector").disabled = false
	if target.has_node("ObjectData"):
		var object_data = target.get_node("ObjectData")
		object_data.purge_slots(true)

	if has_bb("beam"):
		var beam = get_bb("beam")
		if is_instance_valid(beam):
			beam.queue_free()

	if free_on_exit:
		return
	var new_actions = []
	for action in get_children():
		new_actions.push_back(action.duplicate())
		remove_child(action)
		action.queue_free()
	for action in new_actions:
		add_child(action)
	num_running = 0

func revert_human_sprite(target):
	if !target or !is_instance_valid(target):
		return
	if !target.is_inside_tree():
		return
	if !target.has_method("swap_sprite"):
		return

	var static_amount = 1.0
	var wave_amplitude = 0.2
	var duration = .25
	var sprite = target.sprite
	var tween = sprite.controller.tween
	if sprite:
		tween.interpolate_property(sprite,"static_amount",sprite.static_amount,static_amount,duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		tween.interpolate_property(sprite,"wave_amplitude",sprite.wave_amplitude, wave_amplitude,duration*2,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
	target.swap_sprite(0)
	sprite = target.sprite
	tween = sprite.controller.tween
	if sprite and tween:
		tween.interpolate_property(sprite,"wave_amplitude",sprite.wave_amplitude,0,duration*2,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		tween.interpolate_property(sprite,"static_amount",sprite.static_amount,0,duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
