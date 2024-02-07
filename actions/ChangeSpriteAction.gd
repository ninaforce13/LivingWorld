extends Action
enum FORMS {HUMAN, MONSTER}
export (FORMS) var sprite_form
export (float) var static_amount = 1.0
export (float) var wave_amplitude = 0.2
export (float) var duration = .25
export (String) var random_activation_bb = ""
export (bool) var use_bb = false
export (String) var blackboard_value = "mode"
var index:int = -1
func _run():
	if random_activation_bb != "":
		var result = get_bb(random_activation_bb)
		if !result:
			return true
	index = get_parent().get_index() - 1
	var pawn = get_pawn()
	var sprite = pawn.sprite
	var tween = sprite.controller.tween
	if sprite:
		tween.interpolate_property(sprite,"static_amount",sprite.static_amount,static_amount,duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		tween.interpolate_property(sprite,"wave_amplitude",sprite.wave_amplitude, wave_amplitude,duration*2,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
	if use_bb:
		sprite_form = get_bb(blackboard_value)
	pawn.swap_sprite(sprite_form, index)
	sprite = pawn.sprite
	tween = sprite.controller.tween
	if sprite:
		tween.interpolate_property(sprite,"wave_amplitude",sprite.wave_amplitude,0,duration*2,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
		tween.interpolate_property(sprite,"static_amount",sprite.static_amount,0,duration,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		yield(tween,"tween_completed")
	return true
