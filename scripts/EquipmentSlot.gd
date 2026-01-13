class_name EquipmentSlot
extends Control
## Represents a single slot in the equipment UI.
##
## Can hold an InventoryItem or be empty.

signal slot_clicked(slot: EquipmentSlot)

@export var slot_type: ItemBase.SlotType = ItemBase.SlotType.NONE

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(self)

func remove_item() -> void:
	if get_child_count() > 0:
		get_child(0).queue_free()

func get_equipment_item() -> InventoryItem:
	if get_child_count() > 0:
		return get_child(0)
	return null

func get_item() -> InventoryItem.Item:
	var equipment_item = get_equipment_item()
	if equipment_item:
		return equipment_item.get_item()
	return null