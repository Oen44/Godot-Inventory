class_name TooltipSection
extends RefCounted

func applies_to(_item: Item) -> bool:
	return false

func append(_item: Item, _tooltip: ItemTooltip) -> void:
	pass