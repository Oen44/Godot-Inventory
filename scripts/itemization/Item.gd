class_name Item
extends RefCounted
## An item instance
##
## Contains a reference to its base item and unique affixes

signal changed(item: Item)

var parent_inventory: String
var slot_id: int = -1

var vendor_item: bool = false
var currency_item: ItemBase = null
var price: int = 0
var _worth: int = 0

var base: ItemBase
var id: String:
	get:
		return base.id
var quantity: int = 1

var affixes: Array[AffixInstance] = [] ## Array instead of Dictionary to preserve order
var _affix_id_to_index: Dictionary[String, int] = {} ## Maps affix IDs to their index in the affixes array for quick lookup

func _init(base_item: ItemBase, qty: int = 1):
	base = base_item
	quantity = qty
	_calculate_worth()

func set_quantity(new_quantity: int):
	quantity = new_quantity
	_calculate_worth()
	changed.emit(self)

func add_quantity(amount: int):
	set_quantity(quantity + amount)

func remove(amount: int) -> bool:
	if amount > quantity:
		return false
	
	set_quantity(quantity - amount)
	return true

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
	_calculate_worth()
	changed.emit(self)

func remove_affix(affix_id: String):
	if has_affix(affix_id):
		var index = _affix_id_to_index[affix_id]
		affixes.remove_at(index)
		_affix_id_to_index.erase(affix_id)

		for i in range(index, affixes.size()):
			var affix = affixes[i]
			_affix_id_to_index[affix.id] = i
		
		_calculate_worth()
		changed.emit(self)

func has_affix(affix_id: String) -> bool:
	return _affix_id_to_index.has(affix_id)

func get_affix(affix_id: String) -> AffixInstance:
	if has_affix(affix_id):
		return affixes[_affix_id_to_index[affix_id]]
	
	return null

func set_price(new_price: int):
	price = new_price
	_calculate_worth()
	changed.emit(self)

func _calculate_worth():
	var worth = price if price > 0 else base.base_value
	for affix in affixes:
		var multi = AffixPool.get_affix(affix.id).price_multiplier
		worth += int(max(price, base.base_value) * multi)
	_worth = worth

func get_worth() -> int:
	return _worth

func serialize() -> Dictionary:
	var item_data: Dictionary = {
		"base_id": base.id,
		"quantity": quantity
	}

	var affixes_data: Array = []
	for affix in affixes:
		affixes_data.append(affix.serialize())

	item_data["affixes"] = affixes_data

	return item_data

func deserialize(data: Dictionary) -> void:
	if data.has("affixes"):
		for affix_data in data["affixes"]:
			var affix_instance = AffixInstance.new(affix_data["id"], affix_data["values"])
			add_affix(affix_instance)

func clone(amount: int) -> Item:
	var new_item = Item.new(base, amount)
	new_item.parent_inventory = parent_inventory
	new_item.slot_id = slot_id
	new_item.vendor_item = vendor_item
	new_item.currency_item = currency_item
	for affix in affixes:
		var new_affix = AffixInstance.new(affix.id, affix.values.duplicate())
		new_item.add_affix(new_affix)
	new_item.set_price(price)
	return new_item
