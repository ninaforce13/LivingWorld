extends Action
enum FORMS {HUMAN, MONSTER}
export (FORMS) var sprite_form
export (float) var static_amount = 1.0
export (float) var wave_amplitude = 0.2
export (float) var duration = .5
export (String) var random_activation_bb = ""
func _run():
	if random_activation_bb != "":
		var result = get_bb(random_activation_bb)
		if !result:
			return true
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
	pawn.swap_sprite(sprite_form)
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
