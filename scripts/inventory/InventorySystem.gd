class_name InventorySystem
extends Control
## Main system for controlling the inventory.
##
## Handles base items and moving items between inventories.

@export var items_path: String = "res://items/"
@export var item_tooltip: ItemTooltip
@export var player_inventory: InventoryModel

@onready var held_item: InventoryItem = $HeldItem

var items: Dictionary[String, ItemBase] = {}

func _ready():
	held_item.visible = false

func _input(event):
	if event is InputEventMouseMotion and is_holding_item():
		_move_held_item()

## Loads all ItemBase resources from the items_path directory.
func load_items():
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
					items[item_resource.id] = item_resource
				else:
					push_warning("Invalid ItemBase in %s" % item_path)
			else:
				push_warning("Failed to load ItemBase from %s" % item_path)

		file_name = dir.get_next()

	dir.list_dir_end()
	print("Loaded %d base items." % items.size())

## Retrieves a base item by its ID.
func get_item_base(item_id: String) -> ItemBase:
	return items.get(item_id)

## Picks up an item to be held by the cursor.
func pick_up_item(inventory_item: InventoryItem) -> void:
	if not inventory_item or not inventory_item.item:
		push_warning("No item to pick up.")
		return
	
	if held_item.item:
		push_warning("Already holding an item.")
		return

	held_item.item = inventory_item.item
	held_item.texture = inventory_item.texture
	held_item.visible = true
	_move_held_item()

func drop_held_item() -> void:
	held_item.item = null
	held_item.texture = null
	held_item.visible = false

func get_held_item() -> Item:
	return held_item.item

func is_holding_item() -> bool:
	return held_item.item != null && held_item.visible

func _move_held_item() -> void:
	held_item.position = get_global_mouse_position() - held_item.size / 2

func on_item_hover(inventory_item: InventoryItem, hovered: bool) -> void:
	if hovered:
		item_tooltip.inspect(inventory_item)
	else:
		item_tooltip.hide()
