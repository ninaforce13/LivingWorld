extends CheckConditionAction

export (bool) var interruptible:bool = false
export (float) var time_limit:float = 0.0
export (bool) var reset_on_exit_tree = false
export (float) var combative_weight = 1
export (float) var social_weight = 1
export (float) var loner_weight = 1
export (float) var townie_weight = 1
export (bool) var disable_on_water = false
var in_state:bool = false setget set_in_state
var _timer:float = 0.0
var npcmanager = load("res://mods/LivingWorld/scripts/NPCManager.gd")
func _ready():
	WorldSystem.connect("flags_changed", self, "_world_flags_changed")

func _enter_state():
	if not conditions_met():
		_exit_action(true)
		return
	_timer = time_limit
	set_in_state(true)

func conditions_met()->bool:
	if disable_on_water:
		if get_parent().get("pawn"):
			var pawn = get_parent().pawn
			if pawn.in_water:
				return false
	if !npcmanager.get_setting("CaptainPatrol"):
		return false
	return check_conditions(self)

func _exit_state():
	set_in_state(false)

func set_in_state(value:bool):
	if free_on_exit:
		return
	var was_in_state = in_state
	in_state = value
	blackboard.pawn = get_parent().pawn
	set_paused( not in_state or not WorldSystem.is_ai_enabled())


func _exit_tree():
	if is_running() and not free_on_exit and reset_on_exit_tree:
		call_deferred("reset")

func _world_flags_changed():
	set_paused( not in_state or not WorldSystem.is_ai_enabled())

func update(delta):
	if not is_paused() and not is_running():
		run()
	if not conditions_met():
		get_parent().set_state("")
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


