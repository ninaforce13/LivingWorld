extends LootTable

export (float) var random_sticker_chance = 0.05

func generate_rewards(rand:Random, max_value:int, max_num:int = - 1)->Array:
	
	
	
	
	if fixed_max_value > 0:
		max_value = fixed_max_value
	if fixed_max_num > 0:
		max_num = fixed_max_num
	
	var remaining_value = max_value
	var rewards = []
	
	var has_non_stickers = items.size() > 0 or guaranteed_items.size() > 0
	
	if max_stickers != 0 and (random_sticker_chance > 0.0 and randf() < random_sticker_chance):
		var moves:Array
		if sticker_tags.size() == 0:
			if allow_unsellable_stickers:
				moves = BattleMoves.all_stickers.duplicate()
			else :
				moves = BattleMoves.sellable_stickers.duplicate()
		else :
			if allow_unsellable_stickers:
				moves = BattleMoves.get_stickers_for_tag(rand.choice(sticker_tags)).duplicate()
			else :
				moves = BattleMoves.get_sellable_stickers_for_tag(rand.choice(sticker_tags)).duplicate()
		rand.shuffle(moves)
		for move in moves:
			var move_value = StickerItem.appraise_move(move)
			if rewards.size() == 0 or move_value <= remaining_value / 2:
				var item = ItemFactory.generate_item(move, rand)
				assert (item != null)
				
				if upgrade_sticker_rarity and rand.rand_int(100) < upgrade_sticker_rarity_chance:
					item = ItemFactory.upgrade_rarity(item, rand)
					assert (item != null)
				
				remaining_value -= item.value
				rewards.push_back({item = item, amount = 1})
				if has_non_stickers and remaining_value <= max_value / 2:
					remaining_value = max_value / 2
					break
				if remaining_value <= 0:
					break
				if max_stickers >= 0 and rewards.size() >= max_stickers:
					break
	
	for i in range(guaranteed_items.size()):
		var item = guaranteed_items[i]
		var amount = - 1
		if i < guaranteed_item_amounts.size() and guaranteed_item_amounts[i] > 0:
			amount = guaranteed_item_amounts[i]
		_child_loot(rewards, item, rand, remaining_value, 1, amount)
	
	if remaining_value > 0 and (max_num == - 1 or rewards.size() < max_num):
		if rand.rand_bool(rare_item_chance) and rare_items.size() > 0:
			var item = rand.choice(rare_items)
			_child_loot(rewards, item, rand, remaining_value, 1)
	
	if remaining_value > 0 and (max_num == - 1 or rewards.size() < max_num):
		var shuffled_items = items.duplicate()
		rand.shuffle(shuffled_items)
		
		while shuffled_items.size() > 0 and remaining_value > 0 and (max_num == - 1 or rewards.size() < max_num):
			var item = shuffled_items.pop_front()
			remaining_value -= _child_loot(rewards, item, rand, remaining_value, max_num - rewards.size())
		
	return rewards
