class_name MaxLifeAffix
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

var min_value = 5
var max_value = 25

func can_apply_to(item: Item) -> bool:
	return item.base.slot_type in _filter_slots

func roll(_item: Item) -> AffixInstance:
	var value := randi_range(min_value, max_value)
	return AffixInstance.new(id, [value])
