extends Control

@export var inventory_system: InventorySystem
@export var item_id_field: LineEdit
@export var create_item_btn: Button

@export var player_health: HealthComponent
@export var health_label: Label

var player: ExamplePlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

	player_health.health_changed.connect(_on_health_changed)
	_on_health_changed(player_health._health, player_health._max_health)

	create_item_btn.pressed.connect(_on_create_item_pressed)

func _on_create_item_pressed() -> void:
	var item_id = item_id_field.text.strip_edges()
	if item_id.is_empty():
		push_warning("Item ID field is empty.")
		return
	
	var base_item = InventorySystem.get_item_base(item_id)
	if not base_item:
		push_warning("No base item found with ID: %s" % item_id)
		return
	
	inventory_system.player_inventory.create_item(base_item, 1)

func _on_health_changed(health: int, max_health: int) -> void:
	health_label.text = "%d / %d" % [health, max_health]
