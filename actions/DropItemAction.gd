extends Action

export (Resource) var loot_table
export (int) var max_value = 100
export (int) var max_num = 1

const ItemDrop = preload("res://world/core/ItemDrop.tscn")
func _run():
	var item = loot_table.generate_rewards(Random.new(), max_value, max_num)
	drop_item(item[0].item, item[0].amount)
	return true

func drop_item(item:BaseItem, amount:int):
	var location = get_pawn()
	assert (location != null)
	var item_drop = ItemDrop.instance()
	item_drop.item = item
	item_drop.item_amount = amount
	item_drop.transform = location.transform
	location.get_parent().add_child(item_drop)
