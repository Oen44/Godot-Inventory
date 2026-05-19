class_name EquipmentSlot
extends Control
## Represents a single slot in the equipment UI.
##
## Can hold an InventoryItem or be empty.

signal slot_clicked(slot: EquipmentSlot, button: MouseButton)

@export var quantity_label: Label
@export var slot_type: ItemBase.SlotType = ItemBase.SlotType.NONE

func _ready():
	quantity_label.text = ""

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(self, event.button_index)

func set_item(equipment_item: InventoryItem) -> void:
	add_child(equipment_item)
	move_child(equipment_item, 0)
	var item = equipment_item.get_item()
	if item and item.base.stackable:
		quantity_label.text = str(item.quantity)

func remove_item() -> void:
	if get_child(0) is InventoryItem:
		get_child(0).queue_free()
	quantity_label.text = ""

func get_equipment_item() -> InventoryItem:
	if get_child(0) is InventoryItem:
		return get_child(0)
	return null

func get_item() -> Item:
	var equipment_item = get_equipment_item()
	if equipment_item:
		return equipment_item.get_item()
	return null
