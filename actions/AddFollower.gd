extends Action

func _run():
	add_recruit()
	return true
	
func add_recruit():
	var PartnerController = load("res://nodes/partners/PartnerController.tscn")	
	var player
	var npc = get_pawn()
	if WorldSystem.get_level_map().has_node("Player"):
		player = WorldSystem.get_level_map().get_node("Player")
	if not npc.has_node(NodePath("PartnerController")):
		var controller = PartnerController.instance()
		controller.min_distance = 6
		controller.max_distance = 8
		npc.never_pause = true
		controller.name = "PartnerController"
		npc.add_child(controller, true)		
	if npc.has_node("MonsterBehaviour"):
		var idlenode = npc.get_node("MonsterBehaviour")
		npc.remove_child(idlenode)
		idlenode.queue_free()
	var parent = npc.get_parent()
	parent.remove_child(npc)
	WorldSystem.get_level_map().add_child_below_node(player,npc)
	npc.name = "CustomTrainee"
	SaveState.other_data["follower"] = {"recruit":npc.get_node("RecruitData").recruit, "active":true}	
