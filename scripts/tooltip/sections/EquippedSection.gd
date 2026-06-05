class_name EquippedSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/EquippedSectionLabel.tscn"

func applies_to(_item: Item) -> bool:
	return true

func append(_item: Item, tooltip: ItemTooltip) -> void:
	if tooltip.equipped_panel.visible:
		tooltip.add_line("Equipped", label_path)
