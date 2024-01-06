extends "res://addons/misc_utils/StateMachine.gd"
export (bool) var disabled = true
func _ready():
	set_paused(true)


func set_pawn_path(value:NodePath):
	if disabled:
		return
	pawn_path = value
	if pawn_path.is_empty():
		pawn = get_parent()
	else :
		if is_inside_tree():
			pawn = get_node(pawn_path)

func _enter_tree():
	if disabled:
		return
	if !pawn:
		if pawn_path.is_empty():
			pawn = get_parent()
		else :
			if is_inside_tree():
				pawn = get_node(pawn_path)
	initialize_state()

func initialize_state():
	if disabled:
		return
	if state == "":
		state = default_state
	if state == "" and get_child_count() > 0:
		state = get_child(0).name

	set_process(process_mode == 0)
	set_physics_process(process_mode == 1)
	if get_child_count() > 0:
		yield (Co.safe_yield(self, Co.next_frame()), "completed")
		set_state(state)

func _process(delta):
	if disabled:
		return
	._process(delta)

func set_state(value:String):
	if disabled:
		return
	if !pawn:
		return
	if state_node != null:
		if state_node.has_method("_exit_state"):
			state_node._exit_state()

	var old_state = state
	state = value
	if state == "" or not has_node(state):
		if default_state == "" or not has_node(default_state):
			state_node = get_child(0) if get_child_count() > 0 else null
		else :
			state_node = get_node(default_state)
		state = state_node.name if state_node else ""
	else :
		state_node = get_node(state)

	_before_enter_state(old_state, state)

	if state_node != null:
		if state_node.has_method("_enter_state"):
			state_node._enter_state()

	emit_signal("state_changed", state)
