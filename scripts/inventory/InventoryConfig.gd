class_name InventoryConfig
extends Resource

@export var slots: int = 20
@export var autoload: bool = true ## If true, inventory will automatically load on ready
@export var interactable: bool = true ## If false, items cannot be placed into this inventory, but can still be removed (for containers or loot piles).
@export var persistent: bool = true ## If true, inventory will be saved

@export_group("Containment")
@export var contained: bool = false ## If true, only items coming from this inventory can be placed back into it
@export var whitelist: Array[String] = [] ## List of inventory IDs that are allowed to place items into this inventory
