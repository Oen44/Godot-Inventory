@tool
class_name ItemBase
extends Resource
## Base item created using editor, saved as Resource.
##
## New inventory items will reference this base item.
## Attributes such as name, description, icon, and other
## properties are stored in this resource.

enum SlotType {
	NONE,
	HEAD,
	CHEST,
	LEGS,
	FEET,
	WEAPON,
	SHIELD,
	NECK,
	RING
}

enum ItemType {
	HELMET,
	BODY_ARMOR,
	LEGGINGS,
	BOOTS,
	ONE_HANDED_SWORD,
	SHIELD,
	AMULET,
	RING
}

@export_group("Basic Info")
@export var name: String
@export var description: String
@export var icon: Texture2D

@export_group("Properties")
@export var slot_type: SlotType = SlotType.NONE
@export var stackable: bool
@export var max_stacks: int = 1
@export var base_value: int

@export_group("Item Type")
@export var item_type: ItemType:
	set(value):
		item_type = value
		notify_property_list_changed()

## conditional variables (_validate_property)
## (helmets, body armors, legginds, boots, shields)
@export var armor: int
## (weapons)
@export var min_damage: int
@export var max_damage: int
@export var attack_speed: float
## (shields)
@export var block_chance: int

var id: String: get = _get_id

func _get_id() -> String:
	if id.is_empty():
		id = name.to_snake_case()
	return id

func is_valid() -> bool:
	return not name.is_empty() and icon != null

func _validate_property(property: Dictionary):
	if property.name == "armor" and item_type not in [ItemType.HELMET, ItemType.BODY_ARMOR, ItemType.LEGGINGS, ItemType.BOOTS, ItemType.SHIELD]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name in ["min_damage", "max_damage", "attack_speed"] and item_type not in [ItemType.ONE_HANDED_SWORD]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "block_chance" and item_type != ItemType.SHIELD:
		property.usage = PROPERTY_USAGE_NO_EDITOR
