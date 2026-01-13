extends Control

@export var inventory_system: InventorySystem
@export var item_id_field: LineEdit
@export var create_item_btn: Button

func _ready() -> void:
	create_item_btn.pressed.connect(_on_create_item_pressed)

func _on_create_item_pressed() -> void:
	var item_id = item_id_field.text.strip_edges()
	if item_id.is_empty():
		push_warning("Item ID field is empty.")
		return
	
	var base_item = inventory_system.get_item_base(item_id)
	if not base_item:
		push_warning("No base item found with ID: %s" % item_id)
		return
	
	inventory_system.player_inventory.create_item(base_item, 1)
