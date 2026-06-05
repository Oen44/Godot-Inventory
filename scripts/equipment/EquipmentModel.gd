class_name EquipmentModel
extends BaseInventoryModel
## Manages equipment slots for a character.
##
## Handles equipping and unequipping items.

signal item_equipped(item: Item)
signal item_unequipped(item: Item)

@export var slots: Dictionary[ItemBase.SlotType, EquipmentSlot] = {}

var items: Dictionary[ItemBase.SlotType, Item] = {} ## Maps slot type to equipped InventoryItem

func _ready():
	InventorySystem.register_inventory(self)

	for slot_type in slots.keys():
		var slot = slots[slot_type]
		slot.slot_clicked.connect(_on_slot_clicked)

	_load()

func _exit_tree():
	InventorySystem.unregister_inventory(self)
	_save()

func _on_slot_clicked(slot: EquipmentSlot, button: MouseButton) -> void:
	var equipment_item: InventoryItem = slot.get_equipment_item()
	var slot_type = slot.slot_type

	if button == MOUSE_BUTTON_LEFT:
		if equipment_item:
			if InventorySystem.is_holding_item(): ## Swap
				var held_item = InventorySystem.get_held_item()
				if held_item.base.slot_type != slot_type:
					return
				
				if stack_items(held_item, equipment_item.item):
					if held_item.quantity == 0:
						InventorySystem.drop_held_item()
					return
				
				InventorySystem.drop_held_item()
				remove_item_at(slot_type)

				add_item_at(held_item, slot_type)
				InventorySystem.pick_up_item(equipment_item.item)
			else: ## Pick up
				InventorySystem.pick_up_item(equipment_item.item)
				remove_item_at(slot_type)
		elif InventorySystem.is_holding_item(): ## Place
			var held_item = InventorySystem.get_held_item()
			if add_item_at(held_item, slot_type):
				InventorySystem.drop_held_item()
	elif button == MOUSE_BUTTON_RIGHT and equipment_item:
		remove_item_at(slot_type)
		InventorySystem.get_player_inventory().add_item(equipment_item.item)

func equip_item(item: Item) -> int:
	if not item:
		return false
	
	if not slots.has(item.base.slot_type):
		return false
		
	if item.base.on_equip:
		var ret = item.base.on_equip.on_equip(item, self)
		if not ret:
			return false
	
	var slot = slots[item.base.slot_type]
	var equipment_item: InventoryItem = slot.get_equipment_item()
	if equipment_item: ## Swap
		remove_item_at(item.base.slot_type)
		add_item_at(item, item.base.slot_type)
		var parent_inventory = InventorySystem.get_inventory(item.parent_inventory)
		parent_inventory.remove_item(item)
		parent_inventory.add_item(equipment_item.item)
	else: ## Place
		var parent_inventory = InventorySystem.get_inventory(item.parent_inventory)
		parent_inventory.remove_item(item)
		add_item_at(item, item.base.slot_type)

	return true

func create_item_at(slot_type: ItemBase.SlotType, item_base: ItemBase, quantity: int = 1) -> bool:
	if not slots.has(slot_type):
		push_warning("EquipmentModel has no slot for type %s." % str(slot_type))
		return false
	
	if item_base.slot_type != slot_type:
		return false

	var equipment_item = InventoryItem.new()
	equipment_item.create_item(item_base, quantity)
	_add_item(equipment_item, slot_type)

	return true

func add_item_at(item: Item, slot_type: ItemBase.SlotType) -> bool:
	if items.has(slot_type):
		return false
	
	if item.base.slot_type != slot_type:
		return false

	var equipment_item = InventoryItem.new()
	equipment_item.set_item(item)
	_add_item(equipment_item, slot_type)

	return true

func remove_item_at(slot_type: ItemBase.SlotType) -> void:
	if items.has(slot_type):
		var item = items[slot_type]
		if item.base.on_unequip:
			item.base.on_unequip.on_unequip(item, self)
		item_unequipped.emit(items[slot_type])
		var slot: EquipmentSlot = slots[slot_type]
		slot.remove_item()
		items.erase(slot_type)

func get_item_at(slot_type: ItemBase.SlotType) -> Item:
	return items.get(slot_type)

func _add_item(equipment_item: InventoryItem, slot_type: ItemBase.SlotType):
	items[slot_type] = equipment_item.item
	slots[slot_type].set_item(equipment_item)
	equipment_item.mouse_entered.connect(InventorySystem.on_item_hover.bind(equipment_item, true))
	equipment_item.mouse_exited.connect(InventorySystem.on_item_hover.bind(equipment_item, false))
	item_equipped.emit(equipment_item.item)

func _save() -> void:
	var save_path = "user://%s.inv" % id
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		return

	var save_data: Dictionary = {}
	for slot_type in items.keys():
		var item: Item = items[slot_type]
		save_data[slot_type] = item.serialize()

	file.store_var(save_data)
	file.close()

func _load() -> void:
	var save_path = "user://%s.inv" % id
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return

	var save_data: Dictionary = file.get_var()
	for slot_type in save_data.keys():
		var item_data: Dictionary = save_data[slot_type]
		var item_base: ItemBase = InventorySystem.get_item_base(item_data["base_id"])
		if item_base:
			var item = Item.new(item_base, item_data["quantity"])
			item.deserialize(item_data)
			add_item_at(item, int(slot_type))
		else:
			push_warning("Base item with ID %s not found while loading equipment." % item_data["base_id"])

	file.close()
