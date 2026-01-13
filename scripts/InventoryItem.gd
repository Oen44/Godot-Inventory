class_name InventoryItem
extends TextureRect
## Holds item data and displays its icon.
##
## Every inventory item is based on ItemBase resource.
## Per item instance data is stored here.

class Item:
	var base: ItemBase
	var quantity: int = 1

	func _init(base_item: ItemBase, qty: int = 1):
		base = base_item
		quantity = qty

	func serialize() -> Dictionary:
		var item_data: Dictionary = {
			"base_id": base.id,
			"quantity": quantity
		}

		return item_data

var item: Item = null

func create_item(item_base: ItemBase, quantity: int = 1) -> void:
	item = Item.new(item_base, quantity)
	_update_icon()

func set_item(new_item: Item) -> void:
	item = new_item
	_update_icon()

func get_item() -> Item:
	return item

func _update_icon() -> void:
	if item and item.base:
		texture = item.base.icon
	else:
		texture = null