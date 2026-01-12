### InventoryView
### ----------------------------------------------
### Displays the inventory UI.
### Contains slots for items and handles user interaction.
### ----------------------------------------------

class_name InventoryView
extends FlowContainer

const INVENTORY_SLOT_SCENE: PackedScene = preload("res://scenes/inventory_slot.tscn")

var inventory_model: InventoryModel

func init(model: InventoryModel) -> void:
    inventory_model = model
    _populate_slots()

func _populate_slots() -> void:
    for child in get_children():
        child.queue_free()
    
    for i in inventory_model.slots:
        var slot_instance: InventorySlot = INVENTORY_SLOT_SCENE.instantiate()
        add_child(slot_instance)
