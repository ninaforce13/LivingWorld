extends Node

signal engaging
const max_partners = 2
var follow_target = null
var engaged_target = null
var conversation_partners:Array = []
var engaged:bool = false setget set_engage
var recruit
var on_battle_cooldown:bool = false

func _ready():
	WorldSystem.time.connect("date_changed", self, "_on_date_changed")

func set_engage(value):
	engaged = value
	if engaged:
		emit_signal("engaging")

func add_conversation_partner(partner):
	if !full_conversation():
		if conversation_partners.size() > 0:
			var partner_data = conversation_partners[0].get_node("RecruitData")
			if !partner_data.conversation_partners.has(partner):
				partner_data.conversation_partners.push_back(partner)
		if !conversation_partners.has(partner):
			conversation_partners.push_back(partner)
		if not engaged:
			set_engage(true)

func remove_conversation_partner(node):
	for partner in conversation_partners:
		if partner == node:
			conversation_partners.erase(node)
			break

func exit_conversation():
	var pawn = get_parent()
	set_engage(false)
	for partner in conversation_partners:
		if is_instance_valid(partner):
			var partner_data = partner.get_node("RecruitData")
			partner_data.remove_conversation_partner(pawn)
	conversation_partners.clear()


func full_conversation()->bool:
	return conversation_partners.size() >= max_partners

func _on_date_changed():
	on_battle_cooldown = false

