class_name AffixesSection
extends TooltipSection

const VALUE_CHAR = '#'

var label_path = "res://scripts/tooltip/sections/labels/AffixesSectionLabel.tscn"
var regex: RegEx

func applies_to(item: Item) -> bool:
	return item.affixes.size() > 0

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_spacer()
	for affix_instance in item.affixes:
		var affix = AffixPool.get_affix(affix_instance.id)
		if affix.hidden:
			continue
		
		var description = affix.description

		if not regex:
			regex = RegEx.new()
			regex.compile(VALUE_CHAR)

		var matches = regex.search_all(description)
		if matches.size() != affix_instance.values.size():
			push_error("Number of values does not match number of placeholders in attribute name")
			continue
		
		for value in affix_instance.values:
			description = regex.sub(description, "%s" % str(value))
		
		tooltip.add_line(description, label_path)
