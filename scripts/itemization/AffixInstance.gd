class_name AffixInstance
extends RefCounted
## An instance of an affix applied to an item.

var definition: AffixDefinition
var display_lines: Array[String]
var modifiers: Array[StatModifier]

func _init(_def, _lines, _mods):
	definition = _def
	display_lines.assign(_lines)
	modifiers.assign(_mods)
