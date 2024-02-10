extends Node
enum ObjectType {CAMP, ROGUEFUSION, WILD_ENCOUNTER, MERCHANT, TREE, SEAT}
export (ObjectType) var object_type
export (int) var max_slots = 4
export (NodePath) var fire
export (Array,String) var targets
var purge_timer:float = 15.0
var timer:float = 0.0
var slots:Array = []
var campfire = null
export (bool) var prioritize:bool = false
func _ready():
	if fire:
		campfire = get_node(fire)
	timer = purge_timer
	for i in range(0,max_slots):
		slots.push_back({"occupant":null,"occupied":false,"position_target":null,"npc_data":null,"face_direction":Direction.down})
	if object_type == ObjectType.SEAT or object_type == ObjectType.TREE:
		set_seats()
func add_occupant(node):
	for slot in slots:
		if !slot.occupied:
			slot.occupant = node
			slot.occupied = true
			slot.npc_data = node.get_data().recruit
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
			if object_type == ObjectType.TREE or object_type == ObjectType.SEAT:
				if slot.occupant.global_transform.origin.distance_to(slot.position_target) > 3.0:
					clear_slot(slot)
					continue
			var occupant_data = slot.occupant.get_behavior()
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

func is_player(target)->bool:
	var player = WorldSystem.get_player()
	return target == player

func set_campfire(value):
	if campfire and object_type == ObjectType.CAMP:
		campfire.visible = value

func has_space(required_slots:int)->bool:
	var count:int = 0
	for slot in slots:
		if slot.occupant != null:
			count+=1
	return (max_slots - count) >= required_slots

func set_seats():
	var index:int = 0
	for slot in slots:
		var pos:Position3D = get_parent().get_node(targets[index])
		slot.position_target = pos.global_translation
		if object_type == ObjectType.TREE:
			if index == 0:
				slot.face_direction = Direction.left
			if index == 1:
				slot.face_direction = Direction.right
			if index == 2:
				slot.face_direction = Direction.down
		if object_type == ObjectType.SEAT:
			slot.face_direction = Direction.down
		index+=1
