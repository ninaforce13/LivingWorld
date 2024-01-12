extends Node
enum ObjectType {CAMP, ROGUEFUSION, WILD_ENCOUNTER, MERCHANT}
export (ObjectType) var object_type
export (int) var max_slots = 4
export (NodePath) var fire
var purge_timer:float = 15.0
var timer:float = 0.0
var slots:Array = []
var campfire = null
func _ready():
	if fire:
		campfire = get_node(fire)
	timer = purge_timer
	for i in range(0,max_slots):
		slots.push_back({"occupant":null,"occupied":false,"position_target":null,"npc_data":null})

func add_occupant(node):
	for slot in slots:
		if !slot.occupied:
			slot.occupant = node
			slot.occupied = true
			slot.npc_data = node.get_node("RecruitData").recruit
			break
	if !is_empty():
		set_campfire(true)

func remove_occupant(node):
	var slot = get_own_slot(node)
	if slot:
		clear_slot(slot)
	if is_empty():
		set_campfire(false)

func is_full()->bool:
	var count:int = 0
	for slot in slots:
		if slot.occupied:
			count+=1
	return count == max_slots

func is_empty()->bool:
	var count:int = 0
	for slot in slots:
		if slot.occupied:
			count+=1
	return count == 0

func occupied_atleast(threshold:int)->bool:
	var count:int = 0
	for slot in slots:
		if slot.occupied:
			count+=1
	return count >= threshold

func get_own_slot(occupant):
	for slot in slots:
		if slot.occupant == occupant:
			return slot
	return null

func clear_slot(slot):
	slot.occupant = null
	slot.occupied = false
	slot.npc_data = null

func _process(delta):
	if timer > 0.0:
		timer -= delta
		if timer <= 0.0:
			purge_slots()
			timer = purge_timer

func purge_slots(force_purge:bool = false):
	for slot in slots:
		if slot.occupant != null:
			if !is_instance_valid(slot.occupant) or !slot.occupant.is_inside_tree():
				clear_slot(slot)
				continue
			var occupant_data = slot.occupant.get_node("RecruitBehavior")
			if occupant_data:
				if occupant_data.state != "FindCamp" and object_type == ObjectType.CAMP:
					clear_slot(slot)
				if (occupant_data.state != "FindRogues" and occupant_data.state != "Patrol") and object_type == ObjectType.ROGUEFUSION:
					clear_slot(slot)
				if occupant_data.state != "EngageEnemy" and object_type == ObjectType.WILD_ENCOUNTER:
					clear_slot(slot)
					get_parent().get_node("Interaction").disabled = false
		if slot.occupant == null and slot.occupied:
			clear_slot(slot)
		if force_purge:
			clear_slot(slot)
	if is_empty():
		set_campfire(false)

func set_campfire(value):
	if campfire and object_type == ObjectType.CAMP:
		campfire.visible = value
