class_name AffixDefinition
extends Resource
## An affix definition for items.

@export var enabled: bool = true ## If false, affix won't be rolled but still working for existing items
@export var hidden: bool = false ## If true, affix won't be visible in tooltips
@export var id: String
@export var description: String ## Text to show in tooltips, use # as placeholder for any value (in right order)
@export var weight: int = 100

func can_apply_to(_item: Item) -> bool:
    return true

func roll(_item: Item) -> AffixInstance:
    return null
