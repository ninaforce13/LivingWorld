extends "res://addons/misc_utils/StateMachine.gd"

export (bool) var in_monster_form = false setget change_forms
var form_name:String setget set_formname
export (Dictionary) var monster_animations
func change_forms(value):
	in_monster_form = value
	for child in get_children():
		if child.name == "Dashing":
			child.loop_animation = get_animation("loop") if in_monster_form else ""
			child.transition_animation = get_animation("transition") if in_monster_form else ""
		if child.name == "Gliding":
			child.initial_animation = get_animation("transition") if in_monster_form else ""
			child.loop_animation = get_animation("loop") if in_monster_form else "fall"
		if child.name == "Swimming":
			child.initial_animation = get_animation("transition") if in_monster_form else ""
			child.loop_animation = get_animation("loop") if in_monster_form else "swim"

func set_formname(value):
	form_name = value

func get_animation(animation_name)->String:
	if monster_animations.has(form_name):
		return monster_animations[form_name].get(animation_name)
	return ""
