extends Action

func _run():
	add_recruit()
	return true

func add_recruit():
	var rangerdata = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
	var FollowerTemplate = preload("res://mods/LivingWorld/nodes/FollowerTemplate.tscn")
	var player = WorldSystem.get_level_map().get_node("Player")
	var npc = get_pawn()
	var template = FollowerTemplate.instance()
	var tapes:Array = []
	var recruitdata = template.get_node("RecruitData")

	template.never_pause = true

	copy_char_config(template,npc,tapes)
	setup_partner_controller(template)

	recruitdata.recruit = npc.get_node("RecruitData").recruit
	if tapes.size() > 0:
		rangerdata.add_tapes_to_data(tapes,recruitdata.recruit)

	set_appearance(template,npc)

	WorldSystem.get_level_map().add_child_below_node(player,template)
	template.warp_near(player.global_transform.origin, false)
	SaveState.other_data.LivingWorldData.CurrentFollower = {"recruit":npc.get_node("RecruitData").recruit, "active":true}

func set_appearance(template,npc):
	template.npc_name = npc.npc_name
	template.sprite_colors = npc.sprite_colors.duplicate()
	template.sprite_part_names = npc.sprite_part_names.duplicate()

func setup_partner_controller(template):
	var PartnerController = preload("res://nodes/partners/PartnerController.tscn")
	if not template.has_node(NodePath("PartnerController")):
		var controller = PartnerController.instance()
		controller.min_distance = 6
		controller.max_distance = 8
		controller.name = "PartnerController"
		template.name = "FollowerRecruit"
		template.add_child(controller, true)

func copy_char_config(template,npc,tapes):
	if npc.has_node("EncounterConfig/CharacterConfig"):
		var config1 = npc.get_node("EncounterConfig/CharacterConfig")
		config1.get_parent().remove_child(config1)
		template.get_node("EncounterConfig").add_child(config1)
		if npc.has_node("EncounterConfig/Sidekick"):
			var tape = npc.get_node("EncounterConfig/Sidekick/Tape6")
			tape.get_parent().remove_child(tape)
			config1.add_child(tape)
		for tape in config1.get_children():
			tapes.push_back(tape._generate_tape(Random.new(),0))
