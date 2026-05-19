class_name InventoryItem
extends TextureRect
## Holds item data and displays its icon.
##
## Every inventory item is based on ItemBase resource.
## Per item instance data is stored here.

var item: Item = null

func create_item(item_base: ItemBase, quantity: int = 1) -> void:
	item = Item.new(item_base, max(1, quantity))
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