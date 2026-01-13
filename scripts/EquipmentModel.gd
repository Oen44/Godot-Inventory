class_name EquipmentModel
extends Control
## Manages equipment slots for a character.
##
## Handles equipping and unequipping items.

@export var slots: Dictionary[ItemBase.SlotType, EquipmentSlot] = {}

var inventory_system: InventorySystem ## Reference to the main InventorySystem

var items: Dictionary[ItemBase.SlotType, InventoryItem.Item] = {} ## Maps slot type to equipped InventoryItem

func _ready():
	inventory_system = get_tree().get_current_scene().get_node_or_null("InventorySystem")
	if not inventory_system:
		push_error("EquipmentModel could not find InventorySystem in scene tree.")
		return

	for slot_type in slots.keys():
		var slot = slots[slot_type]
		slot.slot_clicked.connect(_on_slot_clicked)

	_load()

func _exit_tree():
	_save()

func _on_slot_clicked(slot: EquipmentSlot) -> void:
	var item = slot.get_equipment_item()
	var slot_type = slot.slot_type
	if item:
		if inventory_system.is_holding_item(): ## Swap
			var held_item = inventory_system.get_held_item()
			if held_item.base.slot_type != slot_type:
				return
			
			inventory_system.drop_held_item()
			remove_item_at(slot_type)

			add_item_at(held_item, slot_type)
			inventory_system.pick_up_item(item)
		else: ## Pick up
			inventory_system.pick_up_item(item)
			remove_item_at(slot_type)
	elif inventory_system.is_holding_item(): ## Place
		var held_item = inventory_system.get_held_item()
		if add_item_at(held_item, slot_type):
			inventory_system.drop_held_item()

func create_item_at(slot_type: ItemBase.SlotType, item_base: ItemBase, quantity: int = 1) -> bool:
	if not slots.has(slot_type):
		push_warning("EquipmentModel has no slot for type %s." % str(slot_type))
		return false
	
	if item_base.slot_type != slot_type:
		return false

	var equipment_item = InventoryItem.new()
	equipment_item.create_item(item_base, quantity)
	slots[slot_type].add_child(equipment_item)
	items[slot_type] = equipment_item.item

	return true

func add_item_at(item: InventoryItem.Item, slot_type: ItemBase.SlotType) -> bool:
	if items.has(slot_type):
		return false
	
	if item.base.slot_type != slot_type:
		return false

	var inventory_item = InventoryItem.new()
	inventory_item.set_item(item)
	items[slot_type] = inventory_item.item
	slots[slot_type].add_child(inventory_item)

	return true

func remove_item_at(slot_type: ItemBase.SlotType) -> void:
	if items.has(slot_type):
		var slot: EquipmentSlot = slots[slot_type]
		slot.remove_item()
		items.erase(slot_type)

func _save() -> void:
	var save_path = "user://player_equipment.inv"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		return

	var save_data: Dictionary = {}
	for slot_type in items.keys():
		var item: InventoryItem.Item = items[slot_type]
		save_data[slot_type] = item.serialize()

	file.store_var(save_data)
	file.close()

func _load() -> void:
	var save_path = "user://player_equipment.inv"
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return

	var save_data: Dictionary = file.get_var()
	for slot_type in save_data.keys():
		var item_data: Dictionary = save_data[slot_type]
		var item_base: ItemBase = inventory_system.get_item_base(item_data["base_id"])
		if item_base:
			create_item_at(slot_type, item_base, item_data["quantity"])
		else:
			push_warning("Base item with ID %s not found while loading equipment." % item_data["base_id"])

	file.close()