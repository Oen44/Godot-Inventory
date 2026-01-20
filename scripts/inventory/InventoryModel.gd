class_name InventoryModel
extends Control
## Manages the inventory data structure.
##
## Handles adding, removing, and querying items.
## Saves and loads inventory state from disk.
## Saves inventory to disk using its unique ID.
## Uses binary serialization for items.

@export var id: String = "inventory" ## Unique identifier for this inventory, used for saving.
@export var slots: int = 20

var inventory_system: InventorySystem ## Reference to the main InventorySystem
var affix_pool: AffixPool ## Reference to the AffixPool

var inventory_view: InventoryView
var items: Dictionary[int, Item] = {} ## Maps slot index to InventoryItem

func _ready():
	await get_parent().ready

	slots = max(slots, 1)
	inventory_view = _find_view(self)

	if not inventory_view:
		push_error("InventoryModel (%s) has no InventoryView assigned or found as child." % id)
		return

	inventory_system = get_tree().get_first_node_in_group("InventorySystem")
	if not inventory_system:
		push_error("InventoryModel (%s) could not find InventorySystem in scene tree." % id)
		return

	affix_pool = get_tree().get_first_node_in_group("AffixPool")
	if not affix_pool:
		push_error("InventoryModel (%s) could not find AffixPool in scene tree." % id)
		return

	inventory_view.init(self)

	_load()

func _exit_tree():
	_save()

## Recursive search for InventoryView in children.
func _find_view(search_in: Control) -> InventoryView:
	for child in search_in.get_children():
		if child is InventoryView:
			return child
		elif child is Control:
			var found_view = _find_view(child)
			if found_view:
				return found_view
	return null

func _on_slot_clicked(slot: InventorySlot) -> void:
	var item = slot.get_inventory_item()
	var slot_id = slot.get_index()
	if item:
		if inventory_system.is_holding_item(): ## Swap
			var held_item = inventory_system.get_held_item()
			inventory_system.drop_held_item()
			remove_item_at(slot_id)

			add_item_at(held_item, slot.get_index())
			inventory_system.pick_up_item(item)
		else: ## Pick up
			inventory_system.pick_up_item(item)
			remove_item_at(slot_id)
	elif inventory_system.is_holding_item(): ## Place
		var held_item = inventory_system.get_held_item()
		add_item_at(held_item, slot.get_index())
		inventory_system.drop_held_item()

func create_item(item_base: ItemBase, quantity: int = 1) -> bool:
	var empty_slot = _get_empty_slot()
	if empty_slot == -1:
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.create_item(item_base, quantity)
	inventory_view.set_item(empty_slot, inventory_item)
	_add_item(inventory_item, empty_slot)

	return true

func create_item_at(slot_index: int, item_base: ItemBase, quantity: int = 1) -> bool:
	if items.has(slot_index):
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.create_item(item_base, quantity)
	inventory_view.set_item(slot_index, inventory_item)
	_add_item(inventory_item, slot_index)

	return true

func add_item(item: Item) -> bool:
	var empty_slot = _get_empty_slot()
	if empty_slot == -1:
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.set_item(item)
	inventory_view.set_item(empty_slot, inventory_item)
	_add_item(inventory_item, empty_slot, false)

	return true

func add_item_at(item: Item, slot_index: int) -> bool:
	if items.has(slot_index):
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.set_item(item)
	inventory_view.set_item(slot_index, inventory_item)
	_add_item(inventory_item, slot_index, false)

	return true

func remove_item_at(slot_index: int) -> void:
	if items.has(slot_index):
		var slot: InventorySlot = inventory_view.get_child(slot_index)
		slot.remove_item()
		items.erase(slot_index)

func _add_item(inventory_item: InventoryItem, slot_index: int, with_affixes: bool = true) -> void:
	items[slot_index] = inventory_item.item
	inventory_item.mouse_entered.connect(inventory_system.on_item_hover.bind(inventory_item, true))
	inventory_item.mouse_exited.connect(inventory_system.on_item_hover.bind(inventory_item, false))

	var item = inventory_item.get_item()
	# Roll affixes for the item if applicable
	if with_affixes:
		var affixes = affix_pool.roll_affix_count(item)
		for i in range(affixes):
			var affix_instance = affix_pool.roll_affix(item)
			if affix_instance:
				item.add_affix(affix_instance)

func _get_empty_slot() -> int:
	for i in range(slots):
		if not items.has(i):
			return i
	return -1

func _save() -> void:
	var save_path = "user://%s.inv" % id
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		return

	var save_data: Dictionary = {}
	for slot_index in items.keys():
		var item: Item = items[slot_index]
		save_data[slot_index] = item.serialize()

	file.store_var(save_data)
	file.close()

func _load() -> void:
	var save_path = "user://%s.inv" % id
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return

	var save_data: Dictionary = file.get_var()
	for slot_index in save_data.keys():
		var item_data: Dictionary = save_data[slot_index]
		var item_base: ItemBase = inventory_system.get_item_base(item_data["base_id"])
		if item_base:
			create_item_at(slot_index, item_base, item_data["quantity"])
		else:
			push_warning("Base item with ID %s not found while loading inventory." % item_data["base_id"])

	file.close()