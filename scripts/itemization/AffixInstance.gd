class_name AffixInstance
extends RefCounted
## An instance of an affix applied to an item.

var id: String
var values: Array[Variant]

func _init(_id: String, _values: Array[Variant]):
	id = _id
	values = _values

func serialize() -> Dictionary:
	return {
		"id": id,
		"values": values
	}