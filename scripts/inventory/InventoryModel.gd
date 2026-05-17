class_name InventoryModel
extends Control
## Manages the inventory data structure.
##
## Handles adding, removing, and querying items.
## Saves and loads inventory state from disk.
## Saves inventory to disk using its unique ID.
## Uses binary serialization for items.

signal loaded ## Emitted after inventory is loaded from disk.
signal item_added(item: Item, slot_index: int) ## Emitted when an item is added to the inventory.
signal item_removed(slot_index: int) ## Emitted when an item is removed from the inventory.

@export var id: String = "inventory" ## Unique identifier for this inventory, used for saving.
@export var config: InventoryConfig ## Configuration for this inventory

var inventory_system: InventorySystem ## Reference to the main InventorySystem

var inventory_view: InventoryView
var items: Dictionary[int, Item] = {} ## Maps slot index to InventoryItem
var empty_slot: int = 0 ## Tracks the lowest empty slot index for efficient empty slot search

var _destroyed: bool = false

func _ready():
	if not config:
		push_error("InventoryModel (%s) has no InventoryConfig assigned." % id)
		return

	config.slots = max(config.slots, 1)
	inventory_view = _find_view(self)

	if not inventory_view:
		push_error("InventoryModel (%s) has no InventoryView assigned or found as child." % id)
		return

	inventory_system = get_tree().get_first_node_in_group("InventorySystem")
	if not inventory_system:
		push_error("InventoryModel (%s) could not find InventorySystem in scene tree." % id)
		return

	if config.autoload:
		init()

func _exit_tree():
	if not _destroyed:
		_save()

func init():
	inventory_view.init(self)
	_load()

## Used for temporary inventories, ones that can be removed completely.
## Example: party member inventory that is wiped when they leave the party.
func destroy():
	DirAccess.remove_absolute("user://%s.inv" % id)
	_destroyed = true

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
	if config.contained:
		if inventory_system.is_holding_item():
			var held_item = inventory_system.get_held_item()
			if held_item.parent_inventory != id and not config.whitelist.has(held_item.parent_inventory):
				return
	
	var inventory_item = slot.get_inventory_item()
	var slot_id = slot.get_index()
	if inventory_item:
		if inventory_system.is_holding_item(): ## Swap
			var held_item = inventory_system.get_held_item()
			inventory_system.drop_held_item()
			remove_item_at(slot_id)

			add_item_at(held_item, slot.get_index())
			inventory_system.pick_up_item(inventory_item)
		else: ## Pick up
			inventory_system.pick_up_item(inventory_item)
			remove_item_at(slot_id)
	elif inventory_system.is_holding_item() and config.interactable: ## Place
		var held_item = inventory_system.get_held_item()
		add_item_at(held_item, slot.get_index())
		inventory_system.drop_held_item()

func create_item(item_base: ItemBase, quantity: int = 1) -> bool:
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
		item_removed.emit(slot_index)
		if empty_slot == -1:
			empty_slot = slot_index
		else:
			empty_slot = min(empty_slot, slot_index)

func get_item_at(slot_index: int) -> Item:
	if items.has(slot_index):
		return items[slot_index]
	return null

func _add_item(inventory_item: InventoryItem, slot_index: int, with_affixes: bool = true) -> void:
	items[slot_index] = inventory_item.item
	inventory_item.mouse_entered.connect(inventory_system.on_item_hover.bind(inventory_item, true))
	inventory_item.mouse_exited.connect(inventory_system.on_item_hover.bind(inventory_item, false))

	var item = inventory_item.item

	if with_affixes:
		item.roll_affixes()

	item.parent_inventory = id
	item_added.emit(item, slot_index)

	empty_slot += 1
	while items.has(empty_slot):
		empty_slot += 1

		if empty_slot >= config.slots:
			empty_slot = -1
			break

func _save() -> void:
	if not config.persistent:
		return
	
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
		var item_base: ItemBase = InventorySystem.get_item_base(item_data["base_id"])
		if item_base:
			var item = Item.new(item_base, item_data["quantity"])
			item.deserialize(item_data)
			add_item_at(item, int(slot_index))
		else:
			push_warning("Base item with ID %s not found while loading inventory." % item_data["base_id"])

	file.close()
	loaded.emit()
