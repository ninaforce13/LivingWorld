extends DecoratorAction

export (bool) var interruptible:bool = true
export (float) var time_limit:float = 0.0
export (bool) var reset_on_exit_tree = false
export (float) var weight = 0.0

var in_state:bool = false setget set_in_state
var _timer:float = 0.0

func _ready():
	WorldSystem.connect("flags_changed", self, "_world_flags_changed")
#	set_in_state(false)

func _enter_state():
	_timer = time_limit
	set_in_state(true)

func _exit_state():
	exit_conversation()
	set_in_state(false)

func exit_conversation():
	var pawn = get_pawn()
	var data = pawn.get_data()
	if data:
		data.exit_conversation()

func set_in_state(value:bool):
	if free_on_exit:
		return
	var was_in_state = in_state
	in_state = value
	blackboard.pawn = get_parent().pawn
	set_paused( not in_state or not WorldSystem.is_ai_enabled())
#	if was_in_state and not in_state and is_running():
#		call_deferred("reset")


func _exit_tree():
	if is_running() and not free_on_exit and reset_on_exit_tree:
		call_deferred("reset")

func _world_flags_changed():
	set_paused( not in_state or not WorldSystem.is_ai_enabled())

func update(delta):
	if not is_paused() and not is_running():
		run()
	if time_limit > 0.0:
		_timer -= delta
		if _timer < 0.0:
			get_parent().set_state("")

func _exit_action(result):
	if not result and not free_on_exit:
		get_parent().set_state("")

func reset():
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

