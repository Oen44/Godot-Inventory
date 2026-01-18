class_name ExamplePlayer
extends Node2D
## Example player node with health and equipment components.
##
## More like a prototype than a full implementation.
## Not intended for production use.

var equipment: EquipmentModel
var health_component: HealthComponent

@export var stats: Dictionary[String, Variant] = {}

var modifiers: Dictionary[String, Variant] = {}

func _ready():
	health_component = $HealthComponent
	equipment = get_tree().get_first_node_in_group("PlayerEquipment")
	equipment.item_equipped.connect(on_item_equipped)
	equipment.item_unequipped.connect(on_item_unequipped)
	
	health_component.set_max_health(get_max_life())
	health_component.set_health(get_max_life())

func on_item_equipped(item: Item) -> void:
	for stat_id in item.base.attributes.keys():
		var stat_value = item.base.attributes[stat_id]
		if modifiers.has(stat_id):
			modifiers[stat_id] += stat_value
		else:
			modifiers[stat_id] = stat_value

	for affix in item.affixes:
		for modifier in affix.modifiers:
			var mod_stat = modifier.stat_id
			var mod_value = modifier.value
			if modifiers.has(mod_stat):
				modifiers[mod_stat] += mod_value
			else:
				modifiers[mod_stat] = mod_value

	health_component.set_max_health(get_max_life())

func on_item_unequipped(item: Item) -> void:
	for stat_id in item.base.attributes.keys():
		var stat_value = item.base.attributes[stat_id]
		if modifiers.has(stat_id):
			modifiers[stat_id] -= stat_value
	
	for affix in item.affixes:
		for modifier in affix.modifiers:
			var mod_stat = modifier.stat_id
			var mod_value = modifier.value
			if modifiers.has(mod_stat):
				modifiers[mod_stat] -= mod_value

	health_component.set_max_health(get_max_life())

func get_stat(stat_id: String) -> Variant:
	return stats.get(stat_id)

func set_modifier(stat_id: String, value: Variant) -> void:
	modifiers[stat_id] = value

func get_modifier(stat_id: String) -> Variant:
	return modifiers.get(stat_id)

func get_max_life() -> int:
	var life = get_stat("max_life")
	var life_bonus = get_modifier("max_life")
	if life_bonus != null:
		life += life_bonus
	
	var life_inc = get_modifier("max_life_percent")
	if life_inc != null:
		life *= 1.0 + (life_inc / 100.0)

	return floor(life)
