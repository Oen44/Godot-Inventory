### InventoryModel
### ----------------------------------------------
### Manages the inventory data structure.
### Handles adding, removing, and querying items.
### Saves and loads inventory state from disk.
### ----------------------------------------------

class_name InventoryModel
extends Control

@export var slots: int = 20

@export_group("Optional")
@export var inventory_view: InventoryView

func _ready():
    slots = max(slots, 1)

    if not inventory_view:
        inventory_view = get_node("InventoryView")
    
    inventory_view.init(self)