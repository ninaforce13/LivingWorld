extends Node


var humannpc_script = preload("res://world/npc/HumanNPC.gd")

func _ready():
	if not HumanLayersHelper.human_templates:
		HumanLayersHelper.setup()
	var parent = get_parent()
	if parent.get_script() == humannpc_script:
		parent.randomize_sprite()
