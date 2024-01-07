extends "res://addons/misc_utils/StateMachine.gd"
enum PERSONALITY{COMBATIVE,SOCIAL,LONER,TOWNIE}
export (PERSONALITY) var personality
export (String) var previous_state = "Idle"
export (float) var time_limit = 15.0
export (Array) var randomized_states

var _timer:float = 0.0
var random:Random = Random.new()
func _ready():
	_timer = time_limit
	yield (get_parent(), "ready")
	assert (get_parent() is NPC)
	get_parent().connect("resumed", self, "set_paused", [false])
	get_parent().connect("paused", self, "set_paused", [true])
	set_randomized_states()

func set_randomized_states():
	randomized_states.clear()
	var weight_name
	if personality == PERSONALITY.COMBATIVE:
		weight_name = "combative_weight"
	if personality == PERSONALITY.SOCIAL:
		weight_name = "social_weight"
	if personality == PERSONALITY.LONER:
		weight_name = "loner_weight"
	if personality == PERSONALITY.TOWNIE:
		weight_name = "townie_weight"
	for child in get_children():
		if child.get(weight_name):
			randomized_states.push_back({"state":child.name,"weight":child.get(weight_name)})

func _process(delta):
	if state == "Idle" and time_limit > 0.0:
		_timer -= delta
		if _timer < 0.0:
			set_randomized_states()
			if !randomized_states.size() > 0:
				return
			var filtered_states = randomized_states.duplicate()
			filter_invalid_states(filtered_states)
			if previous_state != "Idle":
				var remove_index:int = 0
				for filtered_state in filtered_states:
					if filtered_state.state == "Idle":
						filtered_states.remove(remove_index)
						break
					remove_index+=1
				if !filtered_states.size() > 0:
					previous_state = "Idle"
					return
			var choice = random.weighted_choice(filtered_states)
			set_state(choice.state)
			_timer = time_limit
	._process(delta)

func filter_invalid_states(filtered_states:Array):
	for child in get_children():
		if child.has_method("conditions_met"):
			if not child.conditions_met():
				for child_state in filtered_states:
					if child_state.state == child.name:
						filtered_states.erase(child_state)
						break

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
	if !is_interruptible(state_node):
		return
	if conditions_met("Magnetism"):
		set_state("Magnetism")

func kill_npc(_detection):
	set_state("Kill")

func warp_npc(_detection):
	var pawn = get_parent()
	pawn.warp_to(_detection.position)

func get_state_node(statename):
	if has_node(statename):
		return get_node(statename)
	return null

func conditions_met(statename)->bool:
	var new_state = get_state_node(statename)
	if new_state:
		if new_state.has_method("conditions_met"):
			return new_state.conditions_met()
	return true

func _on_MonsterDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	if will_flee():
		var pawn = get_parent()
		var recruitdata = pawn.get_node("RecruitData")
		recruitdata.engaged_target = detection
		set_state("Flee")
		return
	if conditions_met("EngageEnemy"):
		var pawn = get_parent()
		var recruitdata = pawn.get_node("RecruitData")
		recruitdata.engaged_target = detection
		set_state("EngageEnemy")


func _on_TalkingNPCDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	var pawn = get_parent()
	var own_data = pawn.get_node("RecruitData")
	var partner_data = detection.get_node("RecruitData")

	own_data.conversation_partners.push_back(detection)
	if partner_data.conversation_partners.size() > 0:
		for partner in partner_data.conversation_partners:
			if !own_data.conversation_partners.has(partner):
				own_data.conversation_partners.push_back(partner)

	partner_data.add_conversation_partner(pawn)
	set_state("Conversation")


func _on_RecruitData_engaging():
	set_state("Conversation")

func will_flee()->bool:
	if personality == PERSONALITY.COMBATIVE:
		return false
	return random.rand_bool(0.75)

func _on_BootlegDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	var recruitdata = pawn.get_node("RecruitData")
	recruitdata.engaged_target = detection
	set_state("BootlegBehavior")


func _on_RogueFusionDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	if will_flee():
		var pawn = get_parent()
		var recruitdata = pawn.get_node("RecruitData")
		recruitdata.engaged_target = detection
		set_state("Flee")
		return
	set_state("FindRogues")


func _on_MerchantDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	var recruitdata = pawn.get_node("RecruitData")
	recruitdata.engaged_target = detection
	set_state("Shop")



func _on_DefeatedDetector_detected(detection):
	if !is_interruptible(state_node):
		return
	var recruitdata = pawn.get_node("RecruitData")
	recruitdata.engaged_target = detection
	set_state("Revive")
