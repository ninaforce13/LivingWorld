extends CheckConditionAction
var manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
func conditions_met()->bool:
	if root == null:
		setup()
	var pawn = get_pawn()
	var player_index = pawn.player_index
	var index = get_index() - 1
	if manager.get_transformation_index(player_index) == index:
		return false
	return check_conditions(self)
