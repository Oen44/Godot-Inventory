class_name AffixesSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/AffixesSectionLabel.tscn"

func applies_to(item: Item) -> bool:
	return item.affixes.size() > 0

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_spacer()
	for affix in item.affixes:
		for line in affix.display_lines:
			tooltip.add_line(line, label_path)
