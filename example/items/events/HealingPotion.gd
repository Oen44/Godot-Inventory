class_name HealingPotion
extends ItemEvent

@export var min_heal: int = 1
@export var max_heal: int = 6

func can_use(item: Item, _user: Node) -> bool:
	return not item.vendor_item

func on_use(item: Item, user: Node) -> bool:
	if user is not ExamplePlayer:
		return false
	
	var player = user as ExamplePlayer
	var heal_amount = randi_range(min_heal, max_heal)
	player.health_component.add_health(heal_amount)

	item.remove(1)

	return true
