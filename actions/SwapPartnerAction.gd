extends "res://nodes/partners/SwapPartnerAction.gd"

func _run():
	var pawn = get_pawn()
	var current_partner = WorldSystem.get_partner()

	var message = Loc.trgf("PARTNER_SWAP_CONFIRM", pawn.character.pronouns, {
		"name":pawn.character.name
	})

	if yield (MenuHelper.confirm(message), "completed"):
		if yield(MenuHelper.confirm("LIVINGWORLD_TAPESWAP_CONFIRM_TAPE"),"completed"):
			retain_current_party_tapes(current_partner, pawn)
		swap_partners(pawn, current_partner)
		return true
	return false

func retain_current_party_tapes(current_partner, swapping_partner):
	var current_tapes = current_partner.character.tapes.duplicate()
	var stored_tapes = swapping_partner.character.tapes.duplicate()
	current_partner.character.tapes = stored_tapes
	swapping_partner.character.tapes = current_tapes

func swap_partners(pawn, current_partner):
	SaveState.party.heal_character(SaveState.party.partner)
	SaveState.party.current_partner_id = pawn.character.partner_id
	SaveState.party.heal_character(SaveState.party.partner)

	if current_partner:
		WorldPlayerFactory.set_npc_not_player(current_partner)
		root.get_parent().remove_child(root)
		root.blackboard.pawn = current_partner
		current_partner.get_node("Interaction").add_child(root)
		current_partner.add_to_group("spawned_partners")



	WorldPlayerFactory.set_npc_to_player(pawn, 1)
	pawn.remove_from_group("spawned_partners")
