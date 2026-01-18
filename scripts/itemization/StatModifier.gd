class_name StatModifier
extends RefCounted
## A modifier that changes a specific stat by a certain value.

var stat_id: String
var value: Variant

func _init(_stat_id, _value):
	stat_id = _stat_id
	value = _value
