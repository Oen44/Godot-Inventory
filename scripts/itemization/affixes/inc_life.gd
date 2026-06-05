class_name IncLifeAffix
extends AffixDefinition

const _filter_slots = [
	ItemBase.SlotType.HEAD,
	ItemBase.SlotType.CHEST,
	ItemBase.SlotType.LEGS,
	ItemBase.SlotType.FEET,
	ItemBase.SlotType.SHIELD,
	ItemBase.SlotType.RING,
	ItemBase.SlotType.NECK,
]

@export var values: Array = [
	[4, 8]
]

func can_apply_to(item: Item) -> bool:
	return item.base.slot_type in _filter_slots

func roll(_item: Item) -> AffixInstance:
	var rolled_values = []
	for value_range in values:
		var value = randi_range(value_range[0], value_range[1])
		rolled_values.append(value)
	return AffixInstance.new(id, rolled_values)

func range(index: int) -> String:
	return "%d-%d" % [values[index][0], values[index][1]]
