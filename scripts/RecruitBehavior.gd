extends "res://addons/misc_utils/StateMachine.gd"

export (String) var previous_state = "Idle" 
export (float) var time_limit = 15.0
export (Array, String) var randomized_states = []
var _timer:float = 0.0
func _ready():
	_timer = time_limit
	yield (get_parent(), "ready")
	assert (get_parent() is NPC)
	get_parent().connect("resumed", self, "set_paused", [false])
	get_parent().connect("paused", self, "set_paused", [true])

func _process(delta):
	if state == "Idle" and time_limit > 0.0:
		_timer -= delta
		if _timer < 0.0:
			if !randomized_states.size() > 0:
				return
			var filtered_states = randomized_states.duplicate()
			if previous_state != "Idle": 
				filtered_states.erase(previous_state)
				if !filtered_states.size() > 0:
					previous_state = "Idle"
					return
			var statename = filtered_states[randi()%filtered_states.size()]
			set_state(statename)
			_timer = time_limit
	._process(delta)
func is_interruptible(state_node):
	return not (state_node is ActionBase) or state_node.interruptible

func _before_enter_state(old_state:String, new_state:String):

	var pawn = get_parent()
	pawn.direction = Direction.get(Direction.get_nearest(pawn.direction))
	previous_state = old_state

#func _exit_tree():
#	set_state("")

func set_paused(value:bool):
	.set_paused(value)
	
func set_play_with_magnets(_detection):
	set_state("Magnetism")
	
func kill_npc(_detection):
	set_state("Kill")
	
func warp_npc(_detection):
	var pawn = get_parent()
	pawn.warp_to(_detection.position)
