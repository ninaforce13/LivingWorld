extends MessageDialogAction

export (bool) var use_random = false
export (Array,Array,String) var message_array
func _enter_action():
	if use_random:
		messages = []
		var index:int = randi()%message_array.size()
		for message in message_array[index]:
			messages.push_back(message)
