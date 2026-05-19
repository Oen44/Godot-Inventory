class_name InventorySlot
extends Control
## Represents a single slot in the inventory UI.
##
## Can hold an InventoryItem or be empty.

signal slot_clicked(slot: InventorySlot, button: MouseButton, ctrl_pressed: bool, shift_pressed: bool)

@export var quantity_label: Label

func _ready():
	quantity_label.text = ""

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		slot_clicked.emit(self, event.button_index, event.ctrl_pressed, event.shift_pressed)

func set_item(inventory_item: InventoryItem) -> void:
	add_child(inventory_item)
	move_child(inventory_item, 0)
	var item = inventory_item.get_item()
	if item and item.base.stackable:
		quantity_label.text = str(item.quantity)
		item.changed.connect(_on_item_changed)

func remove_item() -> void:
	var inventory_item = get_inventory_item()
	if inventory_item:
		var item = inventory_item.get_item()
		if item and item.base.stackable:
			item.changed.disconnect(_on_item_changed)
		inventory_item.queue_free()
	quantity_label.text = ""

func get_inventory_item() -> InventoryItem:
	var inventory_item = get_child(0)
	if inventory_item is InventoryItem:
		return inventory_item
	return null

func get_item() -> Item:
	var inventory_item = get_inventory_item()
	if inventory_item:
		return inventory_item.get_item()
	return null

func _on_item_changed(item: Item):
	if item and item.base.stackable:
		quantity_label.text = str(item.quantity)
