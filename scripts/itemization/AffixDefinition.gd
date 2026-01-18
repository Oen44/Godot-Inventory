class_name AffixDefinition
extends Resource
## An affix definition for items.

@export var enabled: bool = true ## If disabled, affix won't be rolled but still working for existing items
@export var id: String
@export var weight: int = 100

func can_apply_to(_item: Item) -> bool:
    return true

func roll(_item: Item) -> AffixInstance:
    return null
