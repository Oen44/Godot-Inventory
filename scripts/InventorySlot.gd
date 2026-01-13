class_name InventorySlot
extends Control
## Represents a single slot in the inventory UI.
##
## Can hold an InventoryItem or be empty.

signal slot_clicked(slot: InventorySlot)

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(self)

func remove_item() -> void:
	if get_child_count() > 0:
		get_child(0).queue_free()

func get_inventory_item() -> InventoryItem:
	if get_child_count() > 0:
		return get_child(0) as InventoryItem
	return null

func get_item() -> InventoryItem.Item:
	var inventory_item = get_inventory_item()
	if inventory_item:
		return inventory_item.get_item()
	return null
