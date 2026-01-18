class_name Item
## An item instance
##
## Contains a reference to its base item and unique affixes

var base: ItemBase
var quantity: int = 1

var affixes: Array[AffixInstance] = []

func _init(base_item: ItemBase, qty: int = 1):
	base = base_item
	quantity = qty

func add_affix(affix: AffixInstance):
	affixes.append(affix)

func has_affix(affix_id: String) -> bool:
	for affix in affixes:
		if affix.definition.id == affix_id:
			return true
	return false

func get_stat_modifiers() -> Array[StatModifier]:
	var mods := []
	for a in affixes:
		mods.append_array(a.modifiers)
	return mods

func serialize() -> Dictionary:
	var item_data: Dictionary = {
		"base_id": base.id,
		"quantity": quantity
	}

	return item_data