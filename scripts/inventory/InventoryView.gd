class_name InventoryView
extends Container
## Displays the inventory UI.
##
## Contains slots for items and handles user interaction.

const INVENTORY_SLOT_SCENE: PackedScene = preload("res://scenes/inventory_slot.tscn")

var inventory_model: InventoryModel

func init(model: InventoryModel) -> void:
	inventory_model = model
	_populate_slots()

func _populate_slots() -> void:
	for child in get_children():
		child.queue_free()
	
	for i in inventory_model.config.slots:
		var slot_instance: InventorySlot = INVENTORY_SLOT_SCENE.instantiate()
		slot_instance.name = "Slot_%d" % i
		slot_instance.slot_clicked.connect(inventory_model._on_slot_clicked)
		add_child(slot_instance)

func set_item(slot_index: int, item: InventoryItem) -> void:
	get_child(slot_index).set_item(item)

func get_slot_at_position(point: Vector2) -> InventorySlot:
	for child in get_children():
		if child is InventorySlot and child.get_global_rect().has_point(point):
			return child
	
	return null
