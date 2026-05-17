class_name Item
## An item instance
##
## Contains a reference to its base item and unique affixes

signal changed

var parent_inventory: String
var base: ItemBase
var quantity: int = 1

var affixes: Array[AffixInstance] = [] ## Array instead of Dictionary to preserve order
var _affix_id_to_index: Dictionary[String, int] = {} ## Maps affix IDs to their index in the affixes array for quick lookup

func _init(base_item: ItemBase, qty: int = 1):
	base = base_item
	quantity = qty

func roll_affixes():
	var candidates = AffixPool.get_affixes_for(self)
	if candidates.is_empty():
		return
	
	var affix_count = randi_range(0, min(4, candidates.size()))
	for i in range(affix_count):
		var affix_instance = AffixPool.roll_affix(candidates, self)
		if affix_instance:
			add_affix(affix_instance)

func add_affix(affix: AffixInstance):
	affixes.append(affix)
	_affix_id_to_index[affix.id] = affixes.size() - 1
	changed.emit()

func remove_affix(affix_id: String):
	if has_affix(affix_id):
		var index = _affix_id_to_index[affix_id]
		affixes.remove_at(index)
		_affix_id_to_index.erase(affix_id)

		for i in range(index, affixes.size()):
			var affix = affixes[i]
			_affix_id_to_index[affix.id] = i
		
		changed.emit()

func has_affix(affix_id: String) -> bool:
	return _affix_id_to_index.has(affix_id)

func get_affix(affix_id: String) -> AffixInstance:
	if has_affix(affix_id):
		return affixes[_affix_id_to_index[affix_id]]
	
	return null

func serialize() -> Dictionary:
	var item_data: Dictionary = {
		"base_id": base.id,
		"quantity": quantity
	}

	var affixes_data: Array = []
	for affix in affixes:
		affixes_data.append({
			"id": affix.id,
			"values": affix.values
		})

	item_data["affixes"] = affixes_data

	return item_data

func deserialize(data: Dictionary) -> void:
	if data.has("affixes"):
		for affix_data in data["affixes"]:
			var affix_instance = AffixInstance.new(affix_data["id"], affix_data["values"])
			add_affix(affix_instance)
