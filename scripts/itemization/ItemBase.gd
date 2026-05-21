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

@export_group("Basic Info")
@export var name: String
@export var description: String
@export var icon: Texture2D

@export_group("Properties")
@export var stackable: bool
@export var max_stacks: int = 1
@export var base_value: int = 1

@export_group("Equipment")
@export var slot_type: SlotType:
	set(value):
		slot_type = value
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

@export_group("Events")
@export var on_use: ItemEvent
@export var on_equip: ItemEvent
@export var on_unequip: ItemEvent

var id: String: get = _get_id

func _get_id() -> String:
	if id.is_empty():
		id = name.to_snake_case()
	return id

func is_valid() -> bool:
	return not name.is_empty() and icon != null

func _validate_property(property: Dictionary):
	if property.name == "armor" and slot_type not in [SlotType.HEAD, SlotType.CHEST, SlotType.LEGS, SlotType.FEET, SlotType.SHIELD]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name in ["min_damage", "max_damage", "attack_speed"] and slot_type not in [SlotType.WEAPON]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	elif property.name == "block_chance" and slot_type != SlotType.SHIELD:
		property.usage = PROPERTY_USAGE_NO_EDITOR
