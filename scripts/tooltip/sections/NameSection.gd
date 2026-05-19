class_name NameSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/NameSectionLabel.tscn"

func applies_to(_item: Item) -> bool:
	return true

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_line(item.base.name, label_path)
