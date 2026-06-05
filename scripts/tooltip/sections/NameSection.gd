class_name NameSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/NameSectionLabel.tscn"

func applies_to(_item: Item) -> bool:
	return true

func append(item: Item, tooltip: ItemTooltip) -> void:
	if tooltip.equipped_panel.visible:
		tooltip.add_line("%s (Equipped)" % item.base.name, label_path)
	else:
		tooltip.add_line(item.base.name, label_path)
