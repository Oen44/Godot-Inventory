class_name InventoryConfig
extends Resource

@export var slots: int = 20
@export var autoload: bool = true ## If true, inventory will automatically load on ready
@export var interactable: bool = true ## If false, items cannot be placed into this inventory, but can still be removed (for containers or loot piles).
@export var persistent: bool = true ## If true, inventory will be saved

@export_category("Containment")
@export var contained: bool = false
@export var whitelist: Array[String] = []
