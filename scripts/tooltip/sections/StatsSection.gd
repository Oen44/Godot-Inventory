class_name StatsSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/StatsSectionLabel.tscn"

var stat_id_to_display_name: Dictionary[String, String] = {
	"max_life": "+%s Life",
	"max_life_percent": "%s%% increased maximum Life",
	"defense": "%s Defense",
	"attack": "%s Attack",
}

func applies_to(item: Item) -> bool:
	return item.base.attributes.size() > 0

func append(item: Item, tooltip: ItemTooltip) -> void:
	tooltip.add_spacer()
	for stat_id in item.base.attributes.keys():
		var stat_value = item.base.attributes[stat_id]
		var display_name = stat_id_to_display_name.get(stat_id)
		if not display_name:
			continue
		
		var text = display_name % str(stat_value)
		tooltip.add_line(text, label_path)
