extends Control
## Main system for controlling the inventory.
##
## Handles base _items and moving _items between inventories.

signal inventory_registered(inventory: InventoryModel)
signal inventory_unregistered(inventory: InventoryModel)

@export var items_path: String = "res://items/"
@export var player_inventory: String = "player_inventory"
@export var default_currency: ItemBase

@export var held_item: InventoryItem
@export var held_item_quantity: Label

var _items: Dictionary[String, ItemBase] = {}
var _currency_item: ItemBase = null

var _inventories: Dictionary[String, InventoryModel] = {}

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

func register_inventory(inventory: InventoryModel) -> void:
	if _inventories.has(inventory.id):
		push_warning("Inventory with ID %s is already registered." % inventory.id)
		return
	_inventories[inventory.id] = inventory
	inventory_registered.emit(inventory)

func unregister_inventory(inventory: InventoryModel) -> void:
	if not _inventories.has(inventory.id):
		push_warning("Inventory with ID %s is not registered." % inventory.id)
		return
	_inventories.erase(inventory.id)
	inventory_unregistered.emit(inventory)

func get_inventory(inventory_id: String) -> InventoryModel:
	return _inventories.get(inventory_id)

func get_player_inventory() -> InventoryModel:
	return get_inventory(player_inventory)

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
		ItemTooltip.hide()

## Retrieves a base item by its ID.
func get_item_base(item_id: String) -> ItemBase:
	return _items.get(item_id)

## Retrieves the default currency item.
func get_currency_item() -> ItemBase:
	return _currency_item
