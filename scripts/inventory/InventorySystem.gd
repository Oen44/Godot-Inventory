extends Control
## Main system for controlling the inventory.
##
## Handles base _items and moving _items between inventories.

signal inventory_registered(inventory: BaseInventoryModel) # Emitted when a new inventory is registered with the system.
signal inventory_unregistered(inventory: BaseInventoryModel) # Emitted when an inventory is unregistered from the system.

@export var items_path: String = "res://items/" # Directory where ItemBase resources are located.
@export var player_inventory: String = "player_inventory" # ID of the player's inventory.
@export var default_currency: ItemBase # Default currency item to use in the system.

@export var held_item: InventoryItem # UI element that follows the cursor when holding an item.
@export var held_item_quantity: Label # Label to show the quantity of the held item if it's stackable.

var _items: Dictionary[String, ItemBase] = {}
var _currency_item: ItemBase = null

var _inventories: Dictionary[String, BaseInventoryModel] = {}

func _enter_tree():
	_load_items()
	_currency_item = default_currency
	held_item.visible = false

func _ready():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)
	remove_child(held_item)
	canvas_layer.add_child(held_item)

func _input(event):
	if event is InputEventMouseMotion and is_holding_item():
		_move_held_item()

## Registers a new inventory with the system.
func register_inventory(inventory: BaseInventoryModel) -> void:
	if _inventories.has(inventory.id):
		push_warning("Inventory with ID %s is already registered." % inventory.id)
		return
	_inventories[inventory.id] = inventory
	inventory_registered.emit(inventory)

## Unregisters an inventory from the system.
func unregister_inventory(inventory: BaseInventoryModel) -> void:
	if not _inventories.has(inventory.id):
		push_warning("Inventory with ID %s is not registered." % inventory.id)
		return
	_inventories.erase(inventory.id)
	inventory_unregistered.emit(inventory)

## Retrieves an inventory by its ID.
func get_inventory(inventory_id: String) -> InventoryModel:
	return _inventories.get(inventory_id)

## Convenience method for accessing the player's inventory
func get_player_inventory() -> InventoryModel:
	return get_inventory(player_inventory)

## Convenience method for accessing the equipment inventory
func get_equipment() -> EquipmentModel:
	return _inventories.get("player_equipment")

## Loads all ItemBase resources from the items_path directory.
func _load_items():
	var dir = DirAccess.open(items_path)
	if not dir:
		push_error("Failed to open items directory.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			file_name = dir.get_next()
			continue

		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var item_path = items_path + file_name
			var item_resource = ResourceLoader.load(item_path)
			if item_resource and item_resource is ItemBase:
				if item_resource.is_valid():
					_items[item_resource.id] = item_resource
				else:
					push_warning("Invalid ItemBase in %s" % item_path)
			else:
				push_warning("Failed to load ItemBase from %s" % item_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	print("Loaded %d base items." % _items.size())

## Picks up an item to be held by the cursor.
func pick_up_item(item: Item) -> void:
	if not item or held_item.item:
		return

	held_item.item = item
	held_item.texture = item.base.icon
	if item.base.stackable:
		held_item_quantity.text = str(item.quantity)
	held_item.visible = true
	_move_held_item()

func drop_held_item() -> void:
	held_item.item = null
	held_item.texture = null
	held_item_quantity.text = ""
	held_item.visible = false

func get_held_item() -> Item:
	return held_item.item

func is_holding_item() -> bool:
	return held_item.item != null && held_item.visible

func _move_held_item() -> void:
	held_item.position = get_global_mouse_position() - held_item.size / 2

func on_item_hover(inventory_item: InventoryItem, hovered: bool) -> void:
	if hovered:
		ItemTooltip.inspect(inventory_item)
	else:
		ItemTooltip.close()

## Retrieves a base item by its ID.
func get_item_base(item_id: String) -> ItemBase:
	return _items.get(item_id)

## Retrieves the default currency item.
func get_currency_item() -> ItemBase:
	return _currency_item
