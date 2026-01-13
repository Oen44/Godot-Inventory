class_name ItemBase
extends Resource
## Base item created using editor, saved as Resource.
##
## New inventory items will reference this base item.
## Attributes such as name, description, icon, and other
## properties are stored in this resource.

enum ItemAttributes {
	MIN_DAMAGE,
	MAX_DAMAGE,
	DEFENSE
}

@export_group("Basic Info")
@export var name: String
@export var description: String
@export var icon: Texture2D

@export_group("Properties")
@export var stackable: bool
@export var max_stack: int
@export var base_value: int

@export_group("Base Attributes")
@export var attributes: Dictionary[ItemAttributes, Variant] = {}

var id: String: get = _get_id

func _get_id() -> String:
	if id.is_empty():
		id = name.to_snake_case()
	
	return id

func is_valid() -> bool:
	return not name.is_empty() and icon != null
