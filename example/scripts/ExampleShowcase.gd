extends Control

@export var item_id_field: LineEdit
@export var create_item_btn: Button

@export var stash_button: Button
@export var stash_panel: Control

@export var npc1_button: Button
@export var vendor1: VendorComponent
@export var npc2_button: Button
@export var vendor2: VendorComponent
@export var vendor_inventory: VendorInventory

@export var player_health: HealthComponent
@export var health_label: Label

var player: ExamplePlayer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

	player_health.health_changed.connect(_on_health_changed)
	_on_health_changed(player_health._health, player_health._max_health)

	create_item_btn.pressed.connect(_on_create_item_pressed)

	stash_button.pressed.connect(_on_stash_pressed)
	npc1_button.pressed.connect(_on_npc1_pressed)
	npc2_button.pressed.connect(_on_npc2_pressed)

func _on_create_item_pressed() -> void:
	var item_id = item_id_field.text.strip_edges()
	if item_id.is_empty():
		push_warning("Item ID field is empty.")
		return
	
	var base_item = InventorySystem.get_item_base(item_id)
	if not base_item:
		push_warning("No base item found with ID: %s" % item_id)
		return
	
	InventorySystem.get_player_inventory().create_item(base_item, 1)

func _on_health_changed(health: int, max_health: int) -> void:
	health_label.text = "%d / %d" % [health, max_health]

func _on_stash_pressed() -> void:
	stash_panel.visible = not stash_panel.visible

func _on_npc1_pressed() -> void:
	vendor_inventory.visible = true

	if vendor_inventory.visible:
		vendor_inventory.set_vendor(vendor1)

func _on_npc2_pressed() -> void:
	vendor_inventory.visible = true

	if vendor_inventory.visible:
		vendor_inventory.set_vendor(vendor2)
