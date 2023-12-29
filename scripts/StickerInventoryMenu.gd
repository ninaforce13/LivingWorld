extends "res://menus/BaseMenu.gd"

export (NodePath) var inventory_path:NodePath = NodePath("/root/SaveState/Inventory") setget set_inventory_path
export (bool) var immediate_item_use:bool = true setget set_immediate_item_use
export (Array, String) var tab_filter:Array = []

onready var detail_panel = find_node("DetailPanel")
onready var inventory_tabs = find_node("InventoryTabs")
onready var cog_tween = $CogTween
onready var cog = $Scroller / Cog
onready var cog_shadow = $Scroller / CogShadow
onready var mouse_blocker = $MouseBlocker
onready var sort_button = find_node("SortButton")
onready var filter_button = find_node("FilterButton")
onready var recycle_button = find_node("RecycleButton")
onready var bulk_recycle_button = find_node("BulkRecycleButton")

var inventory = null
var context = null setget set_context
var items_in_use = []

func _ready():
	set_immediate_item_use(immediate_item_use)
	set_context(context)
	set_inventory_path(inventory_path)

	if inventory_tabs.has_node(SaveState.inventory.focus_tab):
		inventory_tabs.current_tab = inventory_tabs.get_node(SaveState.inventory.focus_tab).get_index()

func grab_focus():
	if not mouse_blocker.visible:
		if detail_panel.should_have_focus():
			detail_panel.grab_focus()
		else :
			var tab = inventory_tabs.get_current_tab_control()
			tab.grab_focus()

	_update_filter_button()

func set_context(value):
	context = value
	if detail_panel:
		detail_panel.context = value
		$BackButtonPanel.back_text_override = "UI_BUTTON_CANCEL" if context != null else ""

func set_immediate_item_use(value:bool):
	immediate_item_use = value
	if detail_panel:
		detail_panel.immediate_item_use = immediate_item_use

func set_inventory_path(value:NodePath):
	inventory_path = value
	if is_inside_tree():
		set_inventory(get_node(inventory_path))

func set_inventory(value):
	inventory = value
	if is_inside_tree():
		refresh()

func refresh():
	for tab in inventory_tabs.get_children():
		inventory_tabs.remove_child(tab)
		tab.queue_free()

	for category in inventory.get_children():
		if tab_filter.size() != 0 and not tab_filter.has(category.name):
			continue
		var tab = preload("res://menus/inventory/InventoryTab.tscn").instance()
		tab.name = category.name
		tab.context = context
		tab.items_in_use = items_in_use
		tab.set_items_path(category.get_path())
		tab.connect("canceled", self, "cancel")
		tab.connect("tab_switch_request", self, "_on_tab_switch_request")
		tab.connect("item_focused", self, "_on_item_focused")
		tab.connect("item_selected", self, "_on_item_selected")
		inventory_tabs.add_child(tab)
		inventory_tabs.set_tab_title(inventory_tabs.get_child_count() - 1, "")
	update_tab_icons()

func update_tab_icons():
	_update_filter_button()
	for i in range(inventory_tabs.get_child_count()):
		var tab = inventory_tabs.get_child(i)
		var foreground = inventory_tabs.current_tab == i
		inventory_tabs.set_tab_icon(i, tab.get_tab_icon(foreground))

func _on_tab_switch_request(direction:int):
	if inventory_tabs.get_tab_count() == 0:
		return
	var orig_tab = inventory_tabs.current_tab
	inventory_tabs.current_tab = (inventory_tabs.current_tab + direction + inventory_tabs.get_tab_count()) % inventory_tabs.get_tab_count()
	SaveState.inventory.focus_tab = inventory_tabs.get_current_tab_control().items.name
	if inventory_tabs.get_tab_count() == 1:
		inventory_tabs.get_current_tab_control().grab_focus()
	rotate_cog(inventory_tabs.current_tab - orig_tab)

func rotate_cog(num_stops:int):
	cog_tween.stop_all()
	cog_tween.remove_all()
	cog_tween.interpolate_property(cog, "rect_rotation", cog.rect_rotation, cog.rect_rotation + num_stops * 45.0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	cog_tween.interpolate_property(cog_shadow, "rect_rotation", cog.rect_rotation, cog.rect_rotation + num_stops * 45.0, 0.25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	cog_tween.start()

func _on_item_focused(item):
	detail_panel.set_item_node(item)

func _on_item_selected(item):
	.set_item_node(item)
	detail_panel.grab_focus()

func _update_filter_button():
	filter_button.disabled = not inventory_tabs.get_current_tab_control().user_filterable
	filter_button.visible = not filter_button.disabled

	var tab = inventory_tabs.get_current_tab_control()
	if tab.user_filter.size() > 0:
		filter_button.set_text(Loc.trf("UI_INVENTORY_FILTER_APPLIED", {num = tab.user_filter.size()}))
	else :
		filter_button.set_text("UI_INVENTORY_FILTER")

	bulk_recycle_button.disabled = not (tab.user_filter.size() > 0 and tab.filtered_count > 0)
	bulk_recycle_button.visible = not bulk_recycle_button.disabled

func _on_InventoryTabs_tab_changed(tab:int):
	if is_inside_tree():
		detail_panel.set_item_node(null)
		inventory_tabs.get_child(tab).refresh()
		inventory_tabs.get_child(tab).grab_focus()
		_update_filter_button()
		update_tab_icons()

func _on_item_used(item, arg):
	if immediate_item_use:
		var tab = inventory_tabs.get_current_tab_control()
		tab.refresh()
		tab.grab_focus()
	else :
		choose_option({
			"item":item,
			"arg":arg
		})

func _on_item_discarded(_item, _amount):
	var tab = inventory_tabs.get_current_tab_control()
	tab.refresh()
	tab.grab_focus()

func _on_DetailPanel_canceled():
	inventory_tabs.get_current_tab_control().grab_focus()

func _on_DetailPanel_reorder_requested():
	var tab = inventory_tabs.get_current_tab_control()
	tab.set_reordering(true)
	tab.grab_focus()

func _on_TabLeftButton_pressed():
	_on_tab_switch_request( - 1)

func _on_TabRightButton_pressed():
	_on_tab_switch_request( + 1)

func _on_DetailPanel_block_mouse():
	mouse_blocker.visible = true
	Controls.set_disabled($BackButtonPanel, true)

func _on_DetailPanel_unblock_mouse():
	mouse_blocker.visible = false
	Controls.set_disabled($BackButtonPanel, false)

func _on_SortButton_pressed():
	var tab = inventory_tabs.get_current_tab_control()
	tab.sort()

func _on_DetailPanel_exiting_recycle_mode():
	_update_filter_button()
	recycle_button.disabled = true
	recycle_button.visible = false
	sort_button.visible = true
	sort_button.disabled = false
	$BackButtonPanel.back_text_override = ""

func _on_DetailPanel_entering_recycle_mode(label_text):
	filter_button.visible = false
	recycle_button.disabled = false
	recycle_button.visible = true
	sort_button.disabled = true
	sort_button.visible = false
	bulk_recycle_button.visible = false
	bulk_recycle_button.disabled = true
	recycle_button.text = label_text
	$BackButtonPanel.back_text_override = "UI_BUTTON_CANCEL"

func _on_RecycleButton_pressed():
	if detail_panel.recycle_box.visible:
		detail_panel.recycle_box.choose_value(detail_panel.recycle_box.value)

func _on_FilterButton_pressed():
	var tab = inventory_tabs.get_current_tab_control()
	var menu = preload("res://menus/inventory/StickerFilterMenu.tscn").instance()
	menu.filter = tab.user_filter
	MenuHelper.add_child(menu)
	var result = yield (menu.run_menu(), "completed")
	if result != null:
		tab.user_filter = result
	menu.queue_free()
	_update_filter_button()

func _on_BulkRecycleButton_pressed():
	var tab = inventory_tabs.get_current_tab_control()
	if tab.user_filter.size() == 0 or tab.filtered_count == 0:
		return
	var message = Loc.trf("UI_INVENTORY_BULK_RECYCLE_CONFIRM", {
		total = tab.filtered_count,
		stacks = tab.filtered_stacks
	})
	if yield (MenuHelper.confirm(message, 1, 1), "completed"):
		tab.bulk_recycle()
		_update_filter_button()
