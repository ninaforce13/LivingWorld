extends "res://addons/misc_utils/StateMachine.gd"

export (bool) var in_monster_form = false setget change_forms


func change_forms(value):
	in_monster_form = value
	for child in get_children():
		if child.name == "Dashing":
			child.loop_animation = "dash" if in_monster_form else ""
			child.transition_animation = "transition" if in_monster_form else ""
		if child.name == "Gliding":
			child.initial_animation = "transition" if in_monster_form else ""
			child.loop_animation = "dash" if in_monster_form else "fall"
		if child.name == "Swimming":
			child.initial_animation = "transition" if in_monster_form else ""
			child.loop_animation = "dash" if in_monster_form else "swim"

