extends DecoratorAction

export (bool) var always_succeed:bool = false
export (bool) var invert:bool = false

func conditions_met()->bool:
	if root == null:
		setup()
	return check_conditions(self)

func check_conditions(_conds)->bool:		  
	if SaveState.other_data.has("follower"):
		return SaveState.other_data.follower.active if not invert else !SaveState.other_data.follower.active
	return false if not invert else true

func run():
	if not conditions_met():
		return always_succeed
	return .run()
