class_name ExamplePlayer
extends Node2D
## Example player node with health and equipment components.
##
## More like a prototype than a full implementation.
## Not intended for production use.

@export var stats: Dictionary[String, Variant] = {} ## Base player stats (life, armor, speed etc.)
@export var health_component: HealthComponent

var equipment: EquipmentModel

var _modifiers: Dictionary[String, Variant] = {} ## Calculated stat modifiers from equipment and affixes

func _ready():
	## Not the best way, you should have some Game Manager to spawn player and inject dependencies like equipment model
	equipment = get_tree().get_first_node_in_group("PlayerEquipment")
	equipment.item_equipped.connect(on_item_equipped)
	equipment.item_unequipped.connect(on_item_unequipped)
	
	health_component.set_max_health(get_max_life())
	health_component.set_health(get_max_life())

func on_item_equipped(item: Item) -> void:
	for affix_instance in item.affixes:
		var affix = AffixPool.get_affix(affix_instance.id)
		if not _modifiers.has(affix.id):
			_modifiers[affix.id] = 0
		
		for value in affix_instance.values:
			_modifiers[affix.id] += value

	_update_components()

func on_item_unequipped(item: Item) -> void:
	for affix_instance in item.affixes:
		var affix = AffixPool.get_affix(affix_instance.id)
		if _modifiers.has(affix.id):
			for value in affix_instance.values:
				_modifiers[affix.id] -= value
			
			if _modifiers[affix.id] == 0:
				_modifiers.erase(affix.id)

	_update_components()

## Called from equip events, applied buffs and such
func _update_components():
	health_component.set_max_health(get_max_life())

func get_stat(stat_id: String) -> Variant:
	return stats.get(stat_id)

func get_modifier(stat_id: String) -> Variant:
	return _modifiers.get(stat_id)

## Example method to calculate max life based on base stats and modifiers.
## Calculation order:
## Base stat "max_life"
## + flat amount from max_life modifier
## + additive percentage increase from inc_life modifier
func get_max_life() -> int:
	var life = get_stat("max_life")
	if life == null:
		life = 100 ## Default base life if not defined in stats
	
	var life_bonus = get_modifier("max_life")
	if life_bonus != null:
		life += life_bonus
	
	var life_inc = get_modifier("inc_life")
	if life_inc != null:
		life *= 1.0 + (life_inc / 100.0)

	return floor(life)
