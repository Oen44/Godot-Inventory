class_name SlotSection
extends TooltipSection

var label_path = "res://scripts/tooltip/sections/labels/SlotSectionLabel.tscn"

func applies_to(item: Item) -> bool:
	return item.base.slot_type != ItemBase.SlotType.NONE

func append(item: Item, tooltip: ItemTooltip) -> void:
	var text = ""
	match item.base.slot_type:
		ItemBase.SlotType.HEAD:
			text = "Slot: Head"
		ItemBase.SlotType.CHEST:
			text = "Slot: Chest"
		ItemBase.SlotType.LEGS:
			text = "Slot: Legs"
		ItemBase.SlotType.WEAPON:
			text = "Slot: Weapon"
		ItemBase.SlotType.SHIELD:
			text = "Slot: Shield"
		ItemBase.SlotType.FEET:
			text = "Slot: Feet"
		ItemBase.SlotType.NECK:
			text = "Slot: Neck"
		ItemBase.SlotType.RING:
			text = "Slot: Ring"
		_:
			text = "Slot: Unknown"
	
	tooltip.add_line(text, label_path)