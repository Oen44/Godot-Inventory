class_name InventoryModel
extends BaseInventoryModel
## Manages the inventory data structure.
##
## Handles adding, removing, and querying items.
## Saves and loads inventory state from disk.
## Saves inventory to disk using its unique ID.
## Uses binary serialization for items.

signal loaded ## Emitted after inventory is loaded from disk.
signal item_added(item: Item, slot_index: int) ## Emitted when an item is added to the inventory.
signal item_removed(slot_index: int) ## Emitted when an item is removed from the inventory.
signal item_used(inventory_item: InventoryItem) ## Emitted when an item is used (right-clicked) from the inventory.

@export var config: InventoryConfig ## Configuration for this inventory

var _quantity_selector: QuantitySelector ## Reference to the QuantitySelector UI, used for splitting stacks

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

	_quantity_selector = get_tree().get_first_node_in_group("QuantitySelector")
	if not _quantity_selector:
		push_error("InventoryModel (%s) could not find QuantitySelector in scene tree." % id)
		return

	if config.autoload:
		init()

func _exit_tree():
	InventorySystem.unregister_inventory(self)
	if not _destroyed:
		_save()

func init():
	InventorySystem.register_inventory(self)
	inventory_view.init(self)
	inventory_view.gui_input.connect(_inventory_view_input)
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

func _inventory_view_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var held_item: Item = InventorySystem.get_held_item()
		if held_item and held_item.vendor_item:
			var vendor_inventory = InventorySystem.get_inventory(held_item.parent_inventory) ## This has to be vendor
			if not vendor_inventory or vendor_inventory is not VendorInventory:
				return
			
			vendor_inventory.buy_item(held_item)
			return

func _on_slot_clicked(slot: InventorySlot, button: MouseButton, ctrl_pressed: bool, shift_pressed: bool) -> void:
	if button == MOUSE_BUTTON_LEFT:
		var held_item: Item = InventorySystem.get_held_item()

		if not held_item and shift_pressed:
			_unstack_item(slot)
			return
		
		if not held_item and ctrl_pressed:
			if _move_between_inventories(slot):
				return

		if held_item and held_item.vendor_item:
			return

		if config.contained and InventorySystem.is_holding_item():
			if held_item.parent_inventory != id and not config.whitelist.has(held_item.parent_inventory):
				return
		
		var inventory_item: InventoryItem = slot.get_inventory_item()
		var slot_id = slot.get_index()

		if inventory_item:
			if InventorySystem.is_holding_item(): ## Swap
				if stack_items(held_item, inventory_item.item):
					if held_item.quantity == 0:
						InventorySystem.drop_held_item()
					return

				InventorySystem.drop_held_item()
				remove_item_at(slot_id)

				add_item_at(held_item, slot_id)
				InventorySystem.pick_up_item(inventory_item.item)
			else: ## Pick up
				InventorySystem.pick_up_item(inventory_item.item)
				remove_item_at(slot_id)
		elif InventorySystem.is_holding_item() and config.interactable: ## Place
			add_item_at(held_item, slot_id)
			InventorySystem.drop_held_item()
	elif button == MOUSE_BUTTON_RIGHT:
		var inventory_item: InventoryItem = slot.get_inventory_item()
		if not inventory_item:
			return
		
		## Quick sell if vendor is open
		var vendor_inventory = InventorySystem.get_inventory("vendor")
		if vendor_inventory and vendor_inventory is VendorInventory and vendor_inventory.visible:
			if ctrl_pressed:
				vendor_inventory.sell_item(inventory_item.item)
				return
		
		item_used.emit(inventory_item)

func can_create_item(item_base: ItemBase, quantity: int = 1) -> bool:
	if item_base.stackable:
		var needed_slots = 0
		var remaining_quant = quantity
		for i in range(config.slots):
			if items.has(i):
				var existing_item = items[i]
				if existing_item.base.id == item_base.id and existing_item.quantity < existing_item.base.max_stacks:
					var missing_quant = existing_item.base.max_stacks - existing_item.quantity
					remaining_quant -= missing_quant
					if remaining_quant <= 0:
						return true
		
		if remaining_quant > 0:
			needed_slots = int(ceil(float(remaining_quant) / item_base.max_stacks))
		
		return needed_slots <= get_empty_slot_count()
	
	return empty_slot != -1

func can_create_item_by_id(item_id: String, quantity: int = 1) -> bool:
	var item_base = InventorySystem.get_item_base(item_id)
	if not item_base:
		push_warning("No base item found with ID: %s" % item_id)
		return false
	
	return can_create_item(item_base, quantity)

func _create_stackable_item(item_base: ItemBase, quantity: int = 1) -> bool:
	if not item_base.stackable:
		return false

	for i in range(config.slots):
		if items.has(i):
			var existing_item = items[i]
			if existing_item.base.id == item_base.id and existing_item.quantity < existing_item.base.max_stacks:
				var missing_quant = existing_item.base.max_stacks - existing_item.quantity
				var to_add = min(missing_quant, quantity)
				existing_item.add_quantity(to_add)
				quantity -= to_add
				if quantity <= 0:
					return true

	if quantity > 0:
		var items_to_create = int(ceil(float(quantity) / item_base.max_stacks))
		for i in range(items_to_create):
			if empty_slot == -1:
				return false
			
			var stack_quant = min(item_base.max_stacks, quantity)
			var inventory_item = InventoryItem.new()
			inventory_item.create_item(item_base, stack_quant)
			_add_item(inventory_item, empty_slot)
			quantity -= stack_quant

	return true

func create_item_by_id(item_id: String, quantity: int = 1) -> bool:
	var item_base = InventorySystem.get_item_base(item_id)
	if not item_base:
		push_warning("No base item found with ID: %s" % item_id)
		return false
	
	if not can_create_item(item_base, quantity):
		return false
	
	if item_base.stackable:
		return _create_stackable_item(item_base, quantity)
	
	if empty_slot == -1:
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.create_item(item_base, quantity)
	_add_item(inventory_item, empty_slot)

	return true

func create_item(item_base: ItemBase, quantity: int = 1) -> bool:
	if not can_create_item(item_base, quantity):
		return false
	
	if item_base.stackable:
		return _create_stackable_item(item_base, quantity)

	if empty_slot == -1:
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.create_item(item_base, quantity)
	_add_item(inventory_item, empty_slot)

	return true

func create_item_at(slot_index: int, item_base: ItemBase, quantity: int = 1) -> bool:
	if items.has(slot_index):
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.create_item(item_base, min(quantity, item_base.max_stacks))
	_add_item(inventory_item, slot_index)

	return true

func can_add_item(item: Item) -> bool:
	if item.base.stackable:
		var needed_slots = 0
		var remaining_quant = item.quantity
		for i in range(config.slots):
			if items.has(i):
				var existing_item = items[i]
				if existing_item.base.id == item.base.id and existing_item.quantity < existing_item.base.max_stacks:
					var missing_quant = existing_item.base.max_stacks - existing_item.quantity
					remaining_quant -= missing_quant
					if remaining_quant <= 0:
						return true
		
		if remaining_quant > 0:
			needed_slots = int(ceil(float(remaining_quant) / item.base.max_stacks))
		
		return needed_slots <= get_empty_slot_count()
	
	return empty_slot != -1

func add_item(item: Item) -> bool:
	if item.base.stackable:
		return create_item(item.base, item.quantity)

	if empty_slot == -1:
		return false
	
	var inventory_item = InventoryItem.new()
	inventory_item.set_item(item)
	_add_item(inventory_item, empty_slot, false)

	return true

func add_item_at(item: Item, slot_index: int) -> bool:
	if items.has(slot_index):
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.set_item(item)
	_add_item(inventory_item, slot_index, false)

	return true

func remove_item(item: Item) -> void:
	var slot_id = item.slot_id
	if slot_id == -1 or not items.has(slot_id):
		return
	
	remove_item_at(slot_id)

func remove_item_at(slot_index: int) -> void:
	if items.has(slot_index):
		var slot: InventorySlot = inventory_view.get_child(slot_index)
		var item: Item = items[slot_index]
		item.changed.disconnect(_on_item_changed)
		slot.remove_item()
		items.erase(slot_index)
		item_removed.emit(slot_index)
		if empty_slot == -1:
			empty_slot = slot_index
		else:
			empty_slot = min(empty_slot, slot_index)

func remove_item_by_id(item_id: String, quantity: int = 1) -> void:
	var items_to_remove: Array = []
	for slot_index in items.keys():
		var item = items[slot_index]
		if item.base.id == item_id:
			items_to_remove.append({"slot_index": slot_index, "item": item})

	for entry in items_to_remove:
		var slot_index = entry.slot_index
		var item = entry.item
		if item.quantity > quantity:
			item.remove(quantity)
			break
		else:
			remove_item_at(slot_index)
			quantity -= item.quantity
			if quantity <= 0:
				break

func remove_currency(amount: int) -> bool:
	var currency_item = InventorySystem.get_currency_item()
	if currency_item:
		remove_item_by_id(currency_item.id, amount)
		return true
	
	return false

func get_item_at(slot_index: int) -> Item:
	if items.has(slot_index):
		return items[slot_index]
	return null

func get_empty_slot_count() -> int:
	return config.slots - items.size()

func get_item_count(item_id: String) -> int:
	var count = 0
	for slot_index in items.keys():
		var item = items[slot_index]
		if item.base.id == item_id:
			count += item.quantity
	return count

func get_currency_amount() -> int:
	var currency_item = InventorySystem.get_currency_item()
	if not currency_item:
		return 0
	return get_item_count(currency_item.id)

func _unstack_item(slot: InventorySlot) -> void:
	if _quantity_selector.visible:
		return
	
	var inventory_item: InventoryItem = slot.get_inventory_item()
	if not inventory_item or not inventory_item.item.base.stackable or inventory_item.item.quantity <= 1:
		return

	var item = inventory_item.item
	if not item or not item.base.stackable or item.quantity <= 1:
		return
	
	_quantity_selector.set_item(inventory_item.item)
	_quantity_selector.confirmed.connect(_on_quantity_confirmed)
	_quantity_selector.canceled.connect(_on_quantity_canceled)
	_quantity_selector.show()

func _on_quantity_confirmed(quantity: int) -> void:
	_quantity_selector.confirmed.disconnect(_on_quantity_confirmed)
	_quantity_selector.canceled.disconnect(_on_quantity_canceled)
	_quantity_selector.hide()

	if quantity <= 0:
		return
	
	var item: Item = get_item_at(_quantity_selector.item.slot_id)
	if not item:
		return
	
	if quantity >= item.quantity:
		return
	
	item.remove(quantity)
	var new_item = item.clone(quantity)
	new_item.slot_id = -1
	new_item.parent_inventory = id
	InventorySystem.pick_up_item(new_item)

func _on_quantity_canceled() -> void:
	_quantity_selector.confirmed.disconnect(_on_quantity_confirmed)
	_quantity_selector.canceled.disconnect(_on_quantity_canceled)
	_quantity_selector.hide()

func _move_between_inventories(slot: InventorySlot) -> bool:
	var inventory_item: InventoryItem = slot.get_inventory_item()
	if not inventory_item:
		return false
	
	var item = inventory_item.item
	if not item:
		return false

	var stash_inventory = InventorySystem.get_inventory("stash")
	if not stash_inventory:
		return false
	
	if item.parent_inventory == "stash":
		remove_item(item)
		InventorySystem.get_player_inventory().add_item(item)
	elif stash_inventory.visible:
		remove_item(item)
		stash_inventory.add_item(item)

	return true

func _add_item(inventory_item: InventoryItem, slot_index: int, with_affixes: bool = true) -> void:
	inventory_view.set_item(slot_index, inventory_item)
	items[slot_index] = inventory_item.item
	inventory_item.mouse_entered.connect(InventorySystem.on_item_hover.bind(inventory_item, true))
	inventory_item.mouse_exited.connect(InventorySystem.on_item_hover.bind(inventory_item, false))

	var item = inventory_item.item

	item.changed.connect(_on_item_changed)

	if with_affixes:
		item.roll_affixes()

	item.parent_inventory = id
	item.slot_id = slot_index
	item_added.emit(item, slot_index)

	if empty_slot >= slot_index:
		empty_slot += 1
		
		if empty_slot >= config.slots:
			empty_slot = -1
			return
		
		while items.has(empty_slot):
			empty_slot += 1

			if empty_slot >= config.slots:
				empty_slot = -1
				break

func _on_item_changed(item: Item) -> void:
	if item.quantity <= 0:
		remove_item(item)

func _clear():
	for slot_index in items.keys():
		var slot: InventorySlot = inventory_view.get_child(slot_index)
		var item: Item = items[slot_index]
		slot.remove_item()
		item.changed.disconnect(_on_item_changed)
		item_removed.emit(slot_index)
	items.clear()
	empty_slot = 0

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
