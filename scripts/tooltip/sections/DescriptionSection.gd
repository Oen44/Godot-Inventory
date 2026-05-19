class_name DescriptionSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/DescriptionSectionLabel.tscn"

func applies_to(item: Item) -> bool:
	return not item.base.description.is_empty()

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_spacer()
	tooltip.add_line("[i]%s[/i]" % item.base.description, label_path)